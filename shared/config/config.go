package config

import (
    "fmt"
    "os"
    "time"
)

// Config holds all configuration for our application
type Config struct {
    App      AppConfig
    Server   ServerConfig
    Database DatabaseConfig
    Redis    RedisConfig
    JWT      JWTConfig
}

type AppConfig struct {
    Name        string
    Environment string
    Debug       bool
}

type ServerConfig struct {
    Host string
    Port int
}

type DatabaseConfig struct {
    Host     string
    Port     int
    User     string
    Password string
    Database string
    SSLMode  string
}

type RedisConfig struct {
    Host     string
    Port     int
    Password string
    DB       int
}

type JWTConfig struct {
    Secret               string
    AccessTokenDuration  time.Duration
    RefreshTokenDuration time.Duration
}

// LoadFromEnv loads config from environment variables
func LoadFromEnv() (*Config, error) {
    cfg := &Config{
        App: AppConfig{
            Name:        getEnv("APP_NAME", "prism-service"),
            Environment: getEnv("APP_ENV", "development"),
            Debug:       getEnv("APP_DEBUG", "true") == "true",
        },
        Server: ServerConfig{
            Host: getEnv("SERVER_HOST", "0.0.0.0"),
            Port: getEnvAsInt("SERVER_PORT", 8080),
        },
        Database: DatabaseConfig{
            Host:     getEnv("DB_HOST", "localhost"),
            Port:     getEnvAsInt("DB_PORT", 5432),
            User:     getEnv("DB_USER", "postgres"),
            Password: getEnv("DB_PASSWORD", "postgres"),
            Database: getEnv("DB_NAME", "prism"),
            SSLMode:  getEnv("DB_SSLMODE", "disable"),
        },
        Redis: RedisConfig{
            Host:     getEnv("REDIS_HOST", "localhost"),
            Port:     getEnvAsInt("REDIS_PORT", 6379),
            Password: getEnv("REDIS_PASSWORD", ""),
            DB:       getEnvAsInt("REDIS_DB", 0),
        },
        JWT: JWTConfig{
            Secret:               getEnv("JWT_SECRET", "dev-secret-key"),
            AccessTokenDuration:  15 * time.Minute,
            RefreshTokenDuration: 7 * 24 * time.Hour,
        },
    }

    // Validate required fields
    if cfg.JWT.Secret == "" || cfg.JWT.Secret == "dev-secret-key" {
        return nil, fmt.Errorf("JWT_SECRET must be set in production")
    }

    return cfg, nil
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
    if value := os.Getenv(key); value != "" {
        var intVal int
        fmt.Sscanf(value, "%d", &intVal)
        return intVal
    }
    return defaultValue
}
