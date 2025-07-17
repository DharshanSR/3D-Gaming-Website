#!/bin/bash

# Build Script for Production

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Build the application
build_app() {
    print_header "🏗️  Building 3D Gaming Website for Production..."
    
    print_status "Installing dependencies..."
    npm ci
    
    print_status "Building application..."
    npm run build
    
    print_status "Build completed! Files are in the 'dist' directory."
}

# Build Docker image
build_docker() {
    print_header "🐳 Building Docker Image..."
    
    IMAGE_NAME="3d-gaming-website"
    TAG=${1:-latest}
    
    print_status "Building Docker image: $IMAGE_NAME:$TAG"
    docker build -t $IMAGE_NAME:$TAG .
    
    print_status "Docker image built successfully!"
    print_status "Run with: docker run -p 3000:80 $IMAGE_NAME:$TAG"
}

# Function to show help
show_help() {
    echo "3D Gaming Website - Build Script"
    echo
    echo "Usage: $0 [OPTIONS] [TAG]"
    echo
    echo "Options:"
    echo "  --docker     Build Docker image"
    echo "  --help       Show this help message"
    echo
    echo "Arguments:"
    echo "  TAG          Docker image tag (default: latest)"
    echo
    echo "Examples:"
    echo "  $0                    Build application for production"
    echo "  $0 --docker          Build Docker image with 'latest' tag"
    echo "  $0 --docker v1.0.0   Build Docker image with 'v1.0.0' tag"
}

# Parse command line arguments
case "$1" in
    --docker)
        build_docker $2
        ;;
    --help)
        show_help
        ;;
    "")
        build_app
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
