# GitHub Actions Workflows Documentation

This project uses separate CI and CD workflows for better organization, clarity, and control over the deployment process.

## 📋 Workflow Overview

### 1. **CI Pipeline** (`ci.yml`)
**Trigger**: Every push and pull request
**Purpose**: Code quality, testing, building, and security scanning

### 2. **CD Pipeline** (`cd.yml`)
**Trigger**: Successful completion of CI pipeline
**Purpose**: Automated deployment to staging and production

### 3. **Manual Deploy** (`manual-deploy.yml`)
**Trigger**: Manual workflow dispatch
**Purpose**: On-demand deployments with custom parameters

## 🔄 CI Pipeline Workflow

### Jobs Sequence:
1. **Code Quality Checks**
   - ESLint validation
   - Prettier formatting check
   - Security audit

2. **Unit Tests**
   - Run test suite
   - Upload test results

3. **Build Application**
   - Build for production
   - Check build size
   - Upload build artifacts

4. **Docker Build & Security Scan**
   - Build and push Docker image
   - Run Trivy security scan
   - Upload security results

### Triggers:
- Push to `main`, `develop`, or `feature/*` branches
- Pull requests to `main` or `develop`

### Outputs:
- Build artifacts in `dist/`
- Docker image in GitHub Container Registry
- Security scan results in GitHub Security tab

## 🚀 CD Pipeline Workflow

### Deployment Strategy:
- **Staging**: Deploys from `develop` branch
- **Production**: Deploys from `main` branch

### Jobs Sequence:
1. **Check CI Status**
   - Verify CI pipeline success
   - Determine deployment target

2. **Deploy to Staging** (if develop branch)
   - Deploy to staging environment
   - Run staging tests
   - Send notifications

3. **Deploy to Production** (if main branch)
   - Pre-deployment checks
   - Deploy to production
   - Health checks
   - Post-deployment verification

4. **Rollback on Failure**
   - Automatic rollback if deployment fails
   - Notification of rollback

5. **Cleanup**
   - Remove old Docker images
   - Clean up Kubernetes resources

### Environment Protection:
- **Staging**: No protection rules
- **Production**: Requires manual approval (configured in GitHub)

## 🎛️ Manual Deploy Workflow

### Features:
- **Environment Selection**: Choose staging or production
- **Custom Image Tag**: Deploy specific version
- **Force Deploy**: Override validation failures
- **Manual Approval**: Required for production deployments

### Usage:
1. Go to Actions tab in GitHub
2. Select "Manual Deploy" workflow
3. Click "Run workflow"
4. Fill in parameters:
   - Environment: `staging` or `production`
   - Image Tag: Docker image tag (default: `latest`)
   - Force Deploy: Override failures (use with caution)

## 🔧 Configuration

### Environment Variables:
```yaml
REGISTRY: ghcr.io
IMAGE_NAME: ${{ github.repository }}
NODE_VERSION: '18'
```

### Required Secrets:
- `GITHUB_TOKEN`: Automatically provided by GitHub
- `KUBECONFIG`: Kubernetes cluster configuration (for external clusters)

### Environment URLs:
- **Staging**: `https://staging.gaming-website.local`
- **Production**: `https://gaming-website.com`

## 🏷️ Branch Strategy

### Branch Flow:
```
feature/xyz → develop → main
     ↓           ↓        ↓
   No Deploy   Staging  Production
```

### Deployment Rules:
- **Feature branches**: CI only, no deployment
- **Develop branch**: CI + Staging deployment
- **Main branch**: CI + Production deployment

## 📊 Monitoring and Notifications

### Success Notifications:
- ✅ CI pipeline completion
- 🚀 Successful deployments
- 📊 Build and deployment summaries

### Failure Handling:
- ❌ Failed pipeline notifications
- 🔄 Automatic rollbacks
- 🚨 Alert notifications

## 🛠️ Troubleshooting

### Common Issues:

**CI Pipeline Fails:**
```bash
# Check logs in GitHub Actions
# Fix code quality issues
npm run lint:fix
npm run format
```

**Deployment Fails:**
```bash
# Check Kubernetes cluster status
kubectl get pods -n gaming-website
kubectl get events -n gaming-website

# Manual rollback if needed
kubectl rollout undo deployment/gaming-website-deployment -n gaming-website
```

**Docker Image Not Found:**
```bash
# Check if image was built and pushed
docker manifest inspect ghcr.io/your-username/3d-gaming-website:tag

# Rebuild if necessary
make docker-build
```

### Debug Commands:
```bash
# Check workflow status
gh workflow list
gh run list --workflow=ci.yml

# View logs
gh run view --log

# Re-run failed jobs
gh run rerun <run-id>
```

## 🔐 Security Best Practices

### Implemented Security Measures:
- 🔒 Vulnerability scanning with Trivy
- 🛡️ Security audit in CI pipeline
- 🔑 Least privilege access for tokens
- 📋 SARIF security reporting
- 🏷️ Image signing and verification

### Security Checklist:
- [ ] Keep dependencies updated
- [ ] Monitor security advisories
- [ ] Regular vulnerability scans
- [ ] Review and rotate secrets
- [ ] Enable branch protection rules

## 📈 Performance Optimization

### Implemented Optimizations:
- ⚡ Docker layer caching
- 📦 Build artifact caching
- 🔄 Parallel job execution
- 🎯 Conditional deployments
- 🧹 Resource cleanup

### Monitoring:
- Build time tracking
- Deployment duration
- Resource usage metrics
- Success/failure rates

## 🎯 Best Practices

### Workflow Best Practices:
1. **Separation of Concerns**: CI and CD in separate files
2. **Environment Parity**: Same process for all environments
3. **Rollback Strategy**: Automatic rollbacks on failure
4. **Security First**: Scanning and validation at every step
5. **Observability**: Comprehensive logging and notifications

### Development Workflow:
1. Create feature branch
2. Make changes and test locally
3. Push and create pull request
4. CI runs automatically
5. Merge to develop for staging
6. Merge to main for production

---

**For more information, check the individual workflow files in `.github/workflows/`**
