#!/bin/bash

# Complete Branch Organization for 3D Gaming Website
# This script organizes all components into separate branches

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_header() { echo -e "${BLUE}$1${NC}"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Go to main and ensure clean state
prepare_main() {
    print_header "🔄 Preparing main branch..."
    git checkout main
    git add . || true
    git stash push -m "Backup before branch organization" || true
}

# Create branch for Docker files
create_docker_branch() {
    print_header "🐳 Creating Docker branch..."
    git checkout -b feature/docker-setup 2>/dev/null || git checkout feature/docker-setup
    git stash pop || true
    
    # Create Docker files if they don't exist
    if [ ! -f "Dockerfile" ]; then
        cat > Dockerfile << 'EOF'
# Multi-stage build for React Vite application
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
EOF
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    build: .
    ports:
      - "3000:80"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
EOF
    fi
    
    if [ ! -f "nginx.conf" ]; then
        cat > nginx.conf << 'EOF'
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        
        location / {
            try_files $uri $uri/ /index.html;
        }
        
        location /health {
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF
    fi
    
    git add Dockerfile docker-compose.yml nginx.conf
    git commit -m "feat(docker): Add Docker configuration for containerized deployment"
    print_status "✅ Docker branch created"
}

# Create branch for Kubernetes files
create_k8s_branch() {
    print_header "☸️ Creating Kubernetes branch..."
    git checkout main
    git checkout -b feature/kubernetes-manifests 2>/dev/null || git checkout feature/kubernetes-manifests
    
    # Ensure k8s directory exists with files
    mkdir -p k8s
    
    if [ ! -f "k8s/namespace.yaml" ]; then
        cat > k8s/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: gaming-website
  labels:
    name: gaming-website
EOF
    fi
    
    if [ ! -f "k8s/deployment.yaml" ]; then
        cat > k8s/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gaming-website-deployment
  namespace: gaming-website
spec:
  replicas: 3
  selector:
    matchLabels:
      app: gaming-website
  template:
    metadata:
      labels:
        app: gaming-website
    spec:
      containers:
      - name: gaming-website
        image: ghcr.io/dharshans/3d-gaming-website:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF
    fi
    
    git add k8s/
    git commit -m "feat(k8s): Add Kubernetes manifests for scalable deployment"
    print_status "✅ Kubernetes branch created"
}

# Create branch for GitHub Actions
create_workflows_branch() {
    print_header "🚀 Creating GitHub Actions branch..."
    git checkout main
    git checkout -b feature/github-actions-cicd 2>/dev/null || git checkout feature/github-actions-cicd
    
    mkdir -p .github/workflows
    
    if [ ! -f ".github/workflows/ci.yml" ]; then
        cat > .github/workflows/ci.yml << 'EOF'
name: CI Pipeline
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test-and-build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'
    - run: npm ci
    - run: npm run lint
    - run: npm run build
EOF
    fi
    
    git add .github/
    git commit -m "feat(ci/cd): Add GitHub Actions workflows for automated CI/CD"
    print_status "✅ GitHub Actions branch created"
}

# Create branch for scripts
create_scripts_branch() {
    print_header "📜 Creating Scripts branch..."
    git checkout main
    git checkout -b feature/development-scripts 2>/dev/null || git checkout feature/development-scripts
    
    mkdir -p scripts
    
    if [ ! -f "scripts/setup.sh" ]; then
        cat > scripts/setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Setting up 3D Gaming Website..."
npm install
echo "✅ Setup complete!"
EOF
        chmod +x scripts/setup.sh
    fi
    
    git add scripts/
    git commit -m "feat(scripts): Add development and deployment scripts"
    print_status "✅ Scripts branch created"
}

# Create branch for build tools
create_build_tools_branch() {
    print_header "🔧 Creating Build Tools branch..."
    git checkout main
    git checkout -b feature/build-tools-config 2>/dev/null || git checkout feature/build-tools-config
    
    if [ ! -f "Makefile" ]; then
        cat > Makefile << 'EOF'
.PHONY: help dev build test

help:
	@echo "Available commands:"
	@echo "  dev     - Start development server"
	@echo "  build   - Build for production"
	@echo "  test    - Run tests"

dev:
	npm run dev

build:
	npm run build

test:
	npm run lint
EOF
    fi
    
    git add Makefile package*.json .prettierrc
    git commit -m "feat(build): Add build tools and configuration"
    print_status "✅ Build tools branch created"
}

# Create branch for code quality fixes
create_quality_branch() {
    print_header "✨ Creating Code Quality branch..."
    git checkout main
    git checkout -b feature/code-quality-fixes 2>/dev/null || git checkout feature/code-quality-fixes
    
    git add src/components/
    git commit -m "feat(quality): Fix ESLint issues and improve code quality"
    print_status "✅ Code quality branch created"
}

# Create branch for documentation
create_docs_branch() {
    print_header "📚 Creating Documentation branch..."
    git checkout main
    git checkout -b feature/comprehensive-documentation 2>/dev/null || git checkout feature/comprehensive-documentation
    
    git add README.md
    git commit -m "feat(docs): Add comprehensive project documentation"
    print_status "✅ Documentation branch created"
}

# Main execution
main() {
    print_header "🎮 3D Gaming Website - Complete Branch Organization"
    echo
    
    prepare_main
    
    create_docker_branch
    create_k8s_branch  
    create_workflows_branch
    create_scripts_branch
    create_build_tools_branch
    create_quality_branch
    create_docs_branch
    
    print_header "🎉 All branches created successfully!"
    echo
    print_status "Created branches:"
    git branch | grep "feature/"
    echo
    print_status "Next steps:"
    echo "1. Push all branches: git push --all origin"
    echo "2. Create pull requests in GitHub"
    echo "3. Or merge locally: git checkout main && git merge feature/docker-setup"
}

main "$@"
