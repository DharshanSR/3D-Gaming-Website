#!/bin/bash

# Branch Organization Script for 3D Gaming Website
# This script creates organized branches for different components

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

# Function to create and commit to a branch
create_branch_with_files() {
    local branch_name=$1
    local commit_message=$2
    shift 2
    local files=("$@")
    
    print_header "🌿 Creating branch: $branch_name"
    
    # Switch to main first
    git checkout main
    
    # Create new branch
    git checkout -b "$branch_name"
    
    # Add specified files
    print_status "Adding files: ${files[*]}"
    git add "${files[@]}"
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        print_warning "No changes to commit for $branch_name"
    else
        # Commit changes
        git commit -m "$commit_message"
        print_status "✅ Committed to $branch_name"
    fi
    
    echo
}

# Function to create branches for all components
create_all_branches() {
    print_header "🚀 Creating Organized Branch Structure for 3D Gaming Website"
    echo
    
    # Save current changes to avoid losing them
    print_status "Stashing current changes..."
    git stash push -m "Backup all changes for branch organization" || true
    
    # Go back to main branch
    git checkout main
    
    # Apply stashed changes
    print_status "Applying stashed changes..."
    git stash pop || true
    
    # 1. Docker Branch
    create_branch_with_files \
        "feature/docker-setup" \
        "feat(docker): Add comprehensive Docker configuration

- Multi-stage production Dockerfile with Nginx
- Development Dockerfile with hot reload
- Docker Compose for dev and prod environments
- Optimized nginx configuration with security headers
- .dockerignore for efficient builds

Features:
✅ Multi-platform support (amd64/arm64)
✅ Health checks and monitoring
✅ Security headers and optimization
✅ Development environment with hot reload
✅ Production-ready with Nginx reverse proxy" \
        "Dockerfile" "Dockerfile.dev" "docker-compose.yml" "nginx.conf" ".dockerignore"
    
    # 2. Kubernetes Branch
    create_branch_with_files \
        "feature/kubernetes-manifests" \
        "feat(k8s): Add complete Kubernetes deployment manifests

- Namespace isolation for the application
- Deployment with 3 replicas and rolling updates
- Service for internal communication
- Ingress for external access with SSL support
- HPA for automatic scaling based on CPU/memory
- ConfigMap for nginx configuration

Features:
✅ Production-ready Kubernetes setup
✅ Auto-scaling with HPA
✅ Health checks and readiness probes
✅ Resource limits and requests
✅ SSL/TLS termination support
✅ Configurable environment settings" \
        "k8s/"
    
    # 3. GitHub Actions Workflows Branch
    create_branch_with_files \
        "feature/github-actions-cicd" \
        "feat(ci/cd): Add comprehensive GitHub Actions workflows

- Separate CI pipeline for code quality and testing
- CD pipeline with automated staging/production deployment
- Manual deployment workflow with environment selection
- Security scanning with Trivy
- Multi-platform Docker builds
- Workflow documentation and validation

Features:
✅ Separate CI/CD workflows for better organization
✅ Automated testing and quality checks
✅ Security vulnerability scanning
✅ Environment-based deployment strategy
✅ Manual deployment with approval gates
✅ Comprehensive workflow documentation" \
        ".github/"
    
    # 4. Development Scripts Branch
    create_branch_with_files \
        "feature/development-scripts" \
        "feat(scripts): Add development and deployment scripts

- Setup script for environment configuration
- Development server startup script
- Production build script with Docker support
- Testing and quality check script
- Local Kubernetes deployment script
- Workflow validation script

Features:
✅ One-command environment setup
✅ Easy development server startup
✅ Automated testing and linting
✅ Local Kubernetes deployment
✅ Docker build and run automation
✅ GitHub Actions workflow validation" \
        "scripts/"
    
    # 5. Build Tools Branch (Makefile, configs)
    create_branch_with_files \
        "feature/build-tools-config" \
        "feat(build): Add build tools and configuration

- Comprehensive Makefile with 15+ commands
- Prettier configuration for code formatting
- Updated package.json with new scripts
- ESLint fixes for code quality

Features:
✅ Easy-to-use Makefile commands
✅ Automated code formatting with Prettier
✅ Enhanced npm scripts
✅ Code quality improvements
✅ Development workflow optimization" \
        "Makefile" ".prettierrc" "package.json" "package-lock.json"
    
    # 6. Code Quality Fixes Branch
    create_branch_with_files \
        "feature/code-quality-fixes" \
        "feat(quality): Fix ESLint issues and improve code quality

- Add PropTypes validation for React components
- Remove unused React imports
- Fix component prop validation warnings
- Ensure code follows best practices

Features:
✅ PropTypes validation for all components
✅ Clean ESLint output with zero errors
✅ Better component documentation
✅ Improved code maintainability" \
        "src/components/Contact.jsx" "src/components/Features.jsx" "src/components/RoundedCorners.jsx"
    
    # 7. Documentation Branch
    create_branch_with_files \
        "feature/comprehensive-documentation" \
        "feat(docs): Add comprehensive project documentation

- Updated README with complete setup guide
- GitHub Actions workflow documentation
- Docker and Kubernetes usage instructions
- Development workflow documentation
- Troubleshooting and best practices

Features:
✅ Complete setup and usage guide
✅ CI/CD pipeline documentation
✅ Docker and Kubernetes instructions
✅ Development best practices
✅ Troubleshooting guide" \
        "README.md"
    
    # Show branch summary
    print_header "📋 Branch Summary"
    echo
    print_status "Created branches:"
    git branch | grep "feature/"
    echo
    print_status "Current branch: $(git branch --show-current)"
    echo
}

# Function to show what to do next
show_next_steps() {
    print_header "🎯 Next Steps"
    echo
    print_status "1. Review each branch:"
    echo "   git checkout feature/docker-setup && git log --oneline"
    echo "   git checkout feature/kubernetes-manifests && git log --oneline"
    echo "   git checkout feature/github-actions-cicd && git log --oneline"
    echo "   git checkout feature/development-scripts && git log --oneline"
    echo "   git checkout feature/build-tools-config && git log --oneline"
    echo "   git checkout feature/code-quality-fixes && git log --oneline"
    echo "   git checkout feature/comprehensive-documentation && git log --oneline"
    echo
    print_status "2. Push branches to GitHub:"
    echo "   git push -u origin feature/docker-setup"
    echo "   git push -u origin feature/kubernetes-manifests"
    echo "   git push -u origin feature/github-actions-cicd"
    echo "   git push -u origin feature/development-scripts"
    echo "   git push -u origin feature/build-tools-config"
    echo "   git push -u origin feature/code-quality-fixes"
    echo "   git push -u origin feature/comprehensive-documentation"
    echo
    print_status "3. Create Pull Requests in this order:"
    echo "   1. feature/code-quality-fixes → main"
    echo "   2. feature/build-tools-config → main"
    echo "   3. feature/docker-setup → main"
    echo "   4. feature/kubernetes-manifests → main"
    echo "   5. feature/development-scripts → main"
    echo "   6. feature/github-actions-cicd → main"
    echo "   7. feature/comprehensive-documentation → main"
    echo
    print_status "4. Or merge all at once:"
    echo "   ./scripts/merge-all-branches.sh"
    echo
}

# Function to create merge script
create_merge_script() {
    cat > scripts/merge-all-branches.sh << 'EOF'
#!/bin/bash

# Merge All Branches Script

set -e

echo "🔀 Merging all feature branches into main..."

# Switch to main
git checkout main

# Merge branches in logical order
branches=(
    "feature/code-quality-fixes"
    "feature/build-tools-config"
    "feature/docker-setup"
    "feature/kubernetes-manifests"
    "feature/development-scripts"
    "feature/github-actions-cicd"
    "feature/comprehensive-documentation"
)

for branch in "${branches[@]}"; do
    echo "Merging $branch..."
    git merge "$branch" --no-ff -m "Merge $branch into main"
done

echo "✅ All branches merged successfully!"
echo "🚀 Ready to push to GitHub!"
EOF

    chmod +x scripts/merge-all-branches.sh
    print_status "Created merge script: scripts/merge-all-branches.sh"
}

# Main function
main() {
    print_header "🎮 3D Gaming Website - Branch Organization"
    echo
    
    # Create all branches
    create_all_branches
    
    # Create merge script
    create_merge_script
    
    # Show next steps
    show_next_steps
}

# Show help
show_help() {
    echo "3D Gaming Website - Branch Organization Script"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --help       Show this help message"
    echo "  --list       List all created branches"
    echo "  --merge      Merge all branches into main"
    echo
    echo "Examples:"
    echo "  $0           Create all organized branches"
    echo "  $0 --list    List all feature branches"
    echo "  $0 --merge   Merge all branches into main"
}

# Parse command line arguments
case "${1:-}" in
    --help)
        show_help
        ;;
    --list)
        git branch | grep "feature/"
        ;;
    --merge)
        ./scripts/merge-all-branches.sh
        ;;
    "")
        main
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
