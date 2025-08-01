package main

import (
    "flag"
    "fmt"
    "os"
    "path/filepath"
    "strings"
    "text/template"
)

var (
    serviceName = flag.String("name", "", "Name of the service to create")
    serviceType = flag.String("type", "grpc", "Type of service (grpc, http, worker)")
)

func main() {
    flag.Parse()

    if *serviceName == "" {
        fmt.Println("Error: service name is required")
        fmt.Println("Usage: go run create_service.go -name=<service-name>")
        os.Exit(1)
    }

    // Normalize service name
    normalizedName := strings.ToLower(strings.ReplaceAll(*serviceName, "_", "-"))

    fmt.Printf("🚀 Creating service: %s\n", normalizedName)

    // Create service directory
    servicePath := filepath.Join("services", normalizedName)
    if err := createServiceStructure(servicePath); err != nil {
        fmt.Printf("❌ Error: %v\n", err)
        os.Exit(1)
    }

    // Update go.work
    if err := updateGoWork(servicePath); err != nil {
        fmt.Printf("⚠️  Warning: Could not update go.work: %v\n", err)
    }

    fmt.Printf("✅ Service '%s' created successfully!\n", normalizedName)
    fmt.Println("\nNext steps:")
    fmt.Printf("1. cd %s\n", servicePath)
    fmt.Println("2. go mod init github.com/Lumina-Enterprise-Solutions/prism-erp/" + servicePath)
    fmt.Println("3. go mod tidy")
    fmt.Println("4. Implement your service logic")
}

func createServiceStructure(servicePath string) error {
    // Define directory structure
    dirs := []string{
        filepath.Join(servicePath, "cmd", "server"),
        filepath.Join(servicePath, "internal", "service"),
        filepath.Join(servicePath, "internal", "handler"),
        filepath.Join(servicePath, "deployments", "k8s"),
        filepath.Join(servicePath, "config"),
    }

    // Create directories
    for _, dir := range dirs {
        if err := os.MkdirAll(dir, 0755); err != nil {
            return fmt.Errorf("failed to create directory %s: %w", dir, err)
        }
    }

    // Create main.go
    mainContent := `package main

import (
    "fmt"
    "log"
    "net"
    "os"
    "os/signal"
    "syscall"
)

func main() {
    log.Println("Starting service...")

    // TODO: Initialize service

    // Graceful shutdown
    sigCh := make(chan os.Signal, 1)
    signal.Notify(sigCh, os.Interrupt, syscall.SIGTERM)
    <-sigCh

    log.Println("Shutting down...")
}
`

    mainPath := filepath.Join(servicePath, "cmd", "server", "main.go")
    if err := os.WriteFile(mainPath, []byte(mainContent), 0644); err != nil {
        return fmt.Errorf("failed to create main.go: %w", err)
    }

    // Create README
    readmeContent := fmt.Sprintf(`# %s

## Overview
This service is part of the Lumina Prism ERP system.

## Development
\`\`\`bash
go run cmd/server/main.go
\`\`\`

## Testing
\`\`\`bash
go test ./...
\`\`\`
`, strings.Title(strings.ReplaceAll(filepath.Base(servicePath), "-", " ")))

    readmePath := filepath.Join(servicePath, "README.md")
    if err := os.WriteFile(readmePath, []byte(readmeContent), 0644); err != nil {
        return fmt.Errorf("failed to create README.md: %w", err)
    }

    return nil
}

func updateGoWork(servicePath string) error {
    // Read current go.work
    content, err := os.ReadFile("go.work")
    if err != nil {
        return err
    }

    // Check if already exists
    if strings.Contains(string(content), servicePath) {
        return nil
    }

    // Add new service
    lines := strings.Split(string(content), "\n")
    var newLines []string
    inserted := false

    for _, line := range lines {
        newLines = append(newLines, line)
        if strings.Contains(line, "use (") && !inserted {
            newLines = append(newLines, fmt.Sprintf("    ./%s", servicePath))
            inserted = true
        }
    }

    return os.WriteFile("go.work", []byte(strings.Join(newLines, "\n")), 0644)
}
