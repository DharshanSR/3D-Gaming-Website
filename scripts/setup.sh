#!/bin/bash

# 3D Gaming Website - Setup Script
# This script sets up the development environment

set -e

echo "🚀 Setting up 3D Gaming Website Development Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Check if Node.js is installed
check_nodejs() {
    print_header "Checking Node.js installation..."
    if command -v node > /dev/null 2>&1; then
        NODE_VERSION=$(node --version)
        print_status "Node.js is installed: $NODE_VERSION"
        
        # Check if version is 18 or higher
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d'.' -f1 | cut -d'v' -f2)
        if [ "$MAJOR_VERSION" -lt 18 ]; then
            print_warning "Node.js version 18 or higher is recommended. Current version: $NODE_VERSION"
        fi
    else
        print_error "Node.js is not installed. Please install Node.js 18 or higher."
        exit 1
    fi
}

# Check if Docker is installed
check_docker() {
    print_header "Checking Docker installation..."
    if command -v docker > /dev/null 2>&1; then
        DOCKER_VERSION=$(docker --version)
        print_status "Docker is installed: $DOCKER_VERSION"
        
        # Check if Docker daemon is running
        if docker info > /dev/null 2>&1; then
            print_status "Docker daemon is running"
        else
            print_warning "Docker daemon is not running. Please start Docker."
        fi
    else
        print_warning "Docker is not installed. Install Docker for containerization features."
    fi
}

# Check if kubectl is installed
check_kubectl() {
    print_header "Checking kubectl installation..."
    if command -v kubectl > /dev/null 2>&1; then
        KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client)
        print_status "kubectl is installed: $KUBECTL_VERSION"
    else
        print_warning "kubectl is not installed. Install kubectl for Kubernetes features."
    fi
}

# Install npm dependencies
install_dependencies() {
    print_header "Installing npm dependencies..."
    if [ -f "package.json" ]; then
        npm install
        print_status "Dependencies installed successfully"
    else
        print_error "package.json not found. Make sure you're in the project root directory."
        exit 1
    fi
}

# Make scripts executable
make_scripts_executable() {
    print_header "Making scripts executable..."
    chmod +x scripts/*.sh
    print_status "Scripts are now executable"
}

# Create environment files
create_env_files() {
    print_header "Creating environment files..."
    
    if [ ! -f ".env.local" ]; then
        cat > .env.local << EOF
# Development environment variables
VITE_APP_TITLE=3D Gaming Website
VITE_APP_DESCRIPTION=An immersive 3D gaming experience
VITE_API_URL=http://localhost:3001
VITE_ENV=development
EOF
        print_status "Created .env.local file"
    else
        print_status ".env.local already exists"
    fi
}

# Main setup function
main() {
    print_header "🎮 3D Gaming Website Setup"
    echo
    
    check_nodejs
    check_docker
    check_kubectl
    install_dependencies
    make_scripts_executable
    create_env_files
    
    echo
    print_header "✅ Setup completed successfully!"
    echo
    print_status "Next steps:"
    echo "  1. Run 'npm run dev' to start development server"
    echo "  2. Run './scripts/dev.sh' to start with Docker"
    echo "  3. Run './scripts/deploy-local.sh' to deploy to local Kubernetes"
    echo
    print_status "Available scripts:"
    echo "  ./scripts/dev.sh          - Start development environment"
    echo "  ./scripts/build.sh        - Build for production"
    echo "  ./scripts/deploy-local.sh - Deploy to local Kubernetes"
    echo "  ./scripts/test.sh         - Run tests and linting"
    echo
}

# Run main function
main
