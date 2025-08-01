# Prism ERP - Lumina Enterprise Solutions

## 🏢 About

Prism ERP is a modern, cloud-native Enterprise Resource Planning platform developed by Lumina Enterprise Solutions. Built with microservices architecture and designed for scalability, security, and developer productivity.

## 🚀 Quick Start

```bash
# Prerequisites: Go 1.21+, Docker, kind, helm, tilt

# Clone repository
git clone git@github.com:Lumina-Enterprise-Solutions/prism-erp.git
cd prism-erp

# Setup development environment
make setup

# Start all services
make up

# Access services
# - API Gateway: http://localhost:8080
# - MinIO Console: http://localhost:9001
```

## 🏗️ Architecture

- **Microservices**: Modular services communicating via gRPC
- **API Gateway**: REST to gRPC translation
- **Database**: PostgreSQL with migration support
- **Storage**: MinIO (S3-compatible)
- **Message Queue**: RabbitMQ for async processing
- **Orchestration**: Kubernetes (kind for local dev)

## 📚 Documentation

- [Development Setup](docs/development-setup.md)
- [Architecture Overview](docs/architecture.md)
- [API Reference](docs/api-reference.md)

## 📄 License

Copyright © 2024 Lumina Enterprise Solutions. All rights reserved.
