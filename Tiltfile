# Tiltfile

# Load extensions
load('ext://helm_resource', 'helm_resource', 'helm_repo')

# Configure Helm repositories
helm_repo('bitnami', 'https://charts.bitnami.com/bitnami')
helm_repo('minio', 'https://charts.min.io/')

# PostgreSQL deployment
helm_resource(
    'postgresql',
    'bitnami/postgresql',
    namespace='prism-dev',
    flags=['--create-namespace'],
    port_forwards=['5432:5432'],
    resource_deps=[],
    labels=['infrastructure'],
    values=['''
auth:
  postgresPassword: postgres
  database: prism
primary:
  persistence:
    enabled: true
    size: 1Gi
''']
)

# Redis deployment
helm_resource(
    'redis',
    'bitnami/redis',
    namespace='prism-dev',
    port_forwards=['6379:6379'],
    resource_deps=[],
    labels=['infrastructure'],
    values=['''
auth:
  enabled: false
master:
  persistence:
    enabled: true
    size: 1Gi
replica:
  replicaCount: 0
''']
)

# MinIO deployment
helm_resource(
    'minio',
    'minio/minio',
    namespace='prism-dev',
    port_forwards=[
        '9000:9000',   # API
        '9001:9001'    # Console
    ],
    resource_deps=[],
    labels=['infrastructure'],
    values=['''
mode: standalone
rootUser: minioadmin
rootPassword: minioadmin
persistence:
  enabled: true
  size: 2Gi
consoleService:
  type: NodePort
  nodePort: 30901
''']
)
