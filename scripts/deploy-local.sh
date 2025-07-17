#!/bin/bash

# Local Kubernetes Deployment Script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_header "🔍 Checking Prerequisites..."
    
    # Check kubectl
    if ! command -v kubectl > /dev/null 2>&1; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker > /dev/null 2>&1; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Kubernetes cluster is running
    if ! kubectl cluster-info > /dev/null 2>&1; then
        print_error "Kubernetes cluster is not accessible. Make sure minikube or another cluster is running."
        exit 1
    fi
    
    print_status "All prerequisites met!"
}

# Setup Minikube if not running
setup_minikube() {
    print_header "🚀 Setting up Minikube..."
    
    if ! command -v minikube > /dev/null 2>&1; then
        print_warning "Minikube is not installed. Please install minikube for local Kubernetes development."
        return
    fi
    
    # Check if minikube is running
    if minikube status > /dev/null 2>&1; then
        print_status "Minikube is already running"
    else
        print_status "Starting Minikube..."
        minikube start --driver=docker
        print_status "Minikube started successfully"
    fi
    
    # Enable ingress addon
    print_status "Enabling ingress addon..."
    minikube addons enable ingress
    
    # Set Docker environment to use minikube's Docker daemon
    print_status "Configuring Docker environment..."
    eval $(minikube docker-env)
}

# Build Docker image in minikube
build_image() {
    print_header "🐳 Building Docker Image in Minikube..."
    
    # Set minikube docker environment
    eval $(minikube docker-env)
    
    # Build the image
    docker build -t 3d-gaming-website:latest .
    print_status "Docker image built in Minikube registry"
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_header "🚢 Deploying to Kubernetes..."
    
    # Apply namespace
    print_status "Creating namespace..."
    kubectl apply -f k8s/namespace.yaml
    
    # Apply ConfigMap
    print_status "Applying ConfigMap..."
    kubectl apply -f k8s/configmap.yaml
    
    # Apply Deployment
    print_status "Applying Deployment..."
    kubectl apply -f k8s/deployment.yaml
    
    # Apply Service
    print_status "Applying Service..."
    kubectl apply -f k8s/service.yaml
    
    # Apply Ingress
    print_status "Applying Ingress..."
    kubectl apply -f k8s/ingress.yaml
    
    # Apply HPA (optional)
    print_status "Applying HPA..."
    kubectl apply -f k8s/hpa.yaml || print_warning "HPA creation failed (metrics server might not be installed)"
    
    print_status "Deployment completed!"
}

# Wait for deployment to be ready
wait_for_deployment() {
    print_header "⏳ Waiting for Deployment to be Ready..."
    
    kubectl wait --for=condition=available --timeout=300s deployment/gaming-website-deployment -n gaming-website
    print_status "Deployment is ready!"
}

# Get service information
get_service_info() {
    print_header "📋 Service Information"
    
    print_status "Pods:"
    kubectl get pods -n gaming-website
    
    print_status "Services:"
    kubectl get svc -n gaming-website
    
    print_status "Ingress:"
    kubectl get ingress -n gaming-website
    
    # Get minikube IP and add to hosts file suggestion
    if command -v minikube > /dev/null 2>&1; then
        MINIKUBE_IP=$(minikube ip)
        print_status "Minikube IP: $MINIKUBE_IP"
        print_status "Add this to your /etc/hosts file:"
        echo "  $MINIKUBE_IP gaming-website.local"
        print_status "Then access the application at: http://gaming-website.local"
    fi
}

# Clean up deployment
cleanup() {
    print_header "🧹 Cleaning up Deployment..."
    
    kubectl delete -f k8s/ || print_warning "Some resources might not exist"
    print_status "Cleanup completed!"
}

# Function to show help
show_help() {
    echo "3D Gaming Website - Local Kubernetes Deployment"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --setup      Setup minikube and prerequisites"
    echo "  --build      Build Docker image only"
    echo "  --deploy     Deploy to Kubernetes only"
    echo "  --full       Full deployment (setup + build + deploy)"
    echo "  --status     Show deployment status"
    echo "  --cleanup    Remove deployment"
    echo "  --help       Show this help message"
    echo
    echo "Examples:"
    echo "  $0 --full    Complete setup and deployment"
    echo "  $0 --deploy  Deploy with existing image"
    echo "  $0 --status  Check deployment status"
}

# Parse command line arguments
case "$1" in
    --setup)
        check_prerequisites
        setup_minikube
        ;;
    --build)
        check_prerequisites
        build_image
        ;;
    --deploy)
        check_prerequisites
        deploy_to_k8s
        wait_for_deployment
        get_service_info
        ;;
    --full|"")
        check_prerequisites
        setup_minikube
        build_image
        deploy_to_k8s
        wait_for_deployment
        get_service_info
        ;;
    --status)
        get_service_info
        ;;
    --cleanup)
        cleanup
        ;;
    --help)
        show_help
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
