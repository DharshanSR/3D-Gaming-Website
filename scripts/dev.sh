#!/bin/bash

# Development Environment Startup Script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to start development server
start_dev_server() {
    print_header "🚀 Starting Development Server..."
    
    # Check if we should use Docker
    if [ "$1" == "--docker" ]; then
        print_status "Starting with Docker Compose..."
        docker-compose --profile dev up --build
    else
        print_status "Starting Vite development server..."
        npm run dev
    fi
}

# Function to show help
show_help() {
    echo "3D Gaming Website - Development Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --docker     Start development server using Docker"
    echo "  --help       Show this help message"
    echo
    echo "Examples:"
    echo "  $0           Start regular development server"
    echo "  $0 --docker  Start with Docker Compose"
}

# Parse command line arguments
case "$1" in
    --docker)
        start_dev_server --docker
        ;;
    --help)
        show_help
        ;;
    "")
        start_dev_server
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
