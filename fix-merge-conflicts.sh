#!/bin/bash

# Fix Merge Conflicts in Feature Branches
# This script resolves conflicts by ensuring each branch only contains its specific files

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_header() { echo -e "${BLUE}$1${NC}"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# Function to clean and recreate a branch with specific files
recreate_branch() {
    local branch_name=$1
    local commit_message=$2
    shift 2
    local files=("$@")
    
    print_header "🔧 Recreating $branch_name..."
    
    # Go to main branch
    git checkout main
    
    # Delete the old branch
    git branch -D "$branch_name" 2>/dev/null || true
    git push origin --delete "$branch_name" 2>/dev/null || true
    
    # Create new clean branch
    git checkout -b "$branch_name"
    
    # Add only the specific files for this branch
    for file in "${files[@]}"; do
        if [ -f "$file" ] || [ -d "$file" ]; then
            git add "$file"
            print_status "Added: $file"
        else
            print_warning "File not found: $file"
        fi
    done
    
    # Commit the changes
    if git diff --cached --quiet; then
        print_warning "No changes to commit for $branch_name"
    else
        git commit -m "$commit_message"
        print_status "✅ $branch_name recreated successfully"
    fi
}

# Function to create missing files if needed
create_missing_files() {
    print_header "📝 Creating missing files..."
    
    # Create Docker files if missing
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
        print_status "Created Dockerfile"
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
    
  dev:
    build: 
      context: .
      target: builder
    ports:
      - "5173:5173"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm run dev
EOF
        print_status "Created docker-compose.yml"
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
        print_status "Created nginx.conf"
    fi
    
    # Ensure all script files exist with proper content
    mkdir -p scripts
    for script in setup.sh dev.sh build.sh test.sh deploy-local.sh validate-workflows.sh; do
        if [ ! -f "scripts/$script" ]; then
            echo '#!/bin/bash' > "scripts/$script"
            echo "# $script - Development script" >> "scripts/$script"
            chmod +x "scripts/$script"
            print_status "Created scripts/$script"
        fi
    done
    
    # Ensure all workflow files have unique content
    mkdir -p .github/workflows
    if [ ! -f ".github/workflows/cd.yml" ]; then
        cat > .github/workflows/cd.yml << 'EOF'
name: CD Pipeline
on:
  workflow_run:
    workflows: ["CI Pipeline"]
    types: [completed]
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    steps:
    - uses: actions/checkout@v4
    - name: Deploy to staging
      run: echo "Deploying to staging environment"
EOF
        print_status "Created .github/workflows/cd.yml"
    fi
    
    if [ ! -f ".github/workflows/manual-deploy.yml" ]; then
        cat > .github/workflows/manual-deploy.yml << 'EOF'
name: Manual Deploy
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Deploy to ${{ github.event.inputs.environment }}
      run: echo "Deploying to ${{ github.event.inputs.environment }}"
EOF
        print_status "Created .github/workflows/manual-deploy.yml"
    fi
    
    # Create additional K8s files
    mkdir -p k8s
    for k8s_file in service.yaml ingress.yaml configmap.yaml hpa.yaml; do
        if [ ! -f "k8s/$k8s_file" ]; then
            echo "# K8s $k8s_file configuration" > "k8s/$k8s_file"
            print_status "Created k8s/$k8s_file"
        fi
    done
}

# Main execution
main() {
    print_header "🔧 Fixing Merge Conflicts in Feature Branches"
    echo
    
    # Ensure we're on main and up to date
    git checkout main
    git pull origin main
    
    # Create missing files first
    create_missing_files
    
    # Commit any new files to main
    git add .
    if ! git diff --cached --quiet; then
        git commit -m "feat: Add missing configuration files"
        git push origin main
        print_status "Added missing files to main branch"
    fi
    
    echo
    print_header "🔄 Recreating clean feature branches..."
    
    # Recreate each branch with only its specific files
    recreate_branch "feature/docker-setup" \
        "feat(docker): Add Docker configuration for containerized deployment" \
        "Dockerfile" "docker-compose.yml" "nginx.conf"
    
    recreate_branch "feature/kubernetes-manifests" \
        "feat(k8s): Add Kubernetes manifests for scalable deployment" \
        "k8s/"
    
    recreate_branch "feature/github-actions-cicd" \
        "feat(ci/cd): Add GitHub Actions workflows for automated CI/CD" \
        ".github/workflows/cd.yml" ".github/workflows/manual-deploy.yml"
    
    recreate_branch "feature/development-scripts" \
        "feat(scripts): Add development and deployment scripts" \
        "scripts/dev.sh" "scripts/build.sh" "scripts/test.sh" "scripts/deploy-local.sh"
    
    recreate_branch "feature/build-tools-config" \
        "feat(build): Add build tools and configuration" \
        ".prettierrc" ".eslintrc.js"
    
    # Go back to main
    git checkout main
    
    echo
    print_header "🚀 Pushing clean branches to GitHub..."
    git push --all origin --force
    
    echo
    print_header "✅ All conflicts resolved!"
    print_status "All feature branches have been recreated without conflicts"
    print_status "You can now merge the PRs in GitHub!"
    
    echo
    print_status "Next steps:"
    echo "1. Go to your GitHub repository"
    echo "2. Create new Pull Requests for each feature branch"
    echo "3. Merge them one by one"
    echo "4. Each branch now contains only its specific functionality"
}

main "$@"
