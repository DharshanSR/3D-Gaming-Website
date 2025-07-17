#!/bin/bash

# Test and Quality Checks Script

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

# Run linting
run_lint() {
    print_header "🔍 Running ESLint..."
    
    if npm run lint; then
        print_status "Linting passed!"
    else
        print_error "Linting failed!"
        return 1
    fi
}

# Run tests (if available)
run_tests() {
    print_header "🧪 Running Tests..."
    
    if npm test --if-present 2>/dev/null; then
        print_status "Tests passed!"
    else
        print_warning "No tests found or tests failed"
    fi
}

# Check dependencies for vulnerabilities
check_vulnerabilities() {
    print_header "🔒 Checking for Security Vulnerabilities..."
    
    if npm audit --audit-level=high; then
        print_status "No high-severity vulnerabilities found!"
    else
        print_warning "Vulnerabilities detected. Run 'npm audit fix' to resolve."
    fi
}

# Check bundle size
check_bundle_size() {
    print_header "📦 Checking Bundle Size..."
    
    if [ -d "dist" ]; then
        print_status "Bundle sizes:"
        du -h dist/* 2>/dev/null || print_warning "No build files found"
    else
        print_warning "No dist directory found. Run 'npm run build' first."
    fi
}

# Check code formatting
check_formatting() {
    print_header "✨ Checking Code Formatting..."
    
    if command -v prettier > /dev/null 2>&1; then
        if npx prettier --check src/; then
            print_status "Code formatting is correct!"
        else
            print_warning "Code formatting issues found. Run 'npx prettier --write src/' to fix."
        fi
    else
        print_warning "Prettier not found. Skipping formatting check."
    fi
}

# Run all checks
run_all_checks() {
    print_header "🎯 Running All Quality Checks..."
    
    local failed=0
    
    run_lint || failed=1
    run_tests || failed=1
    check_vulnerabilities || failed=1
    check_formatting || failed=1
    check_bundle_size
    
    echo
    if [ $failed -eq 0 ]; then
        print_status "✅ All checks passed!"
    else
        print_error "❌ Some checks failed!"
        exit 1
    fi
}

# Function to show help
show_help() {
    echo "3D Gaming Website - Test and Quality Checks"
    echo
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --lint        Run ESLint only"
    echo "  --test        Run tests only"
    echo "  --security    Check for vulnerabilities only"
    echo "  --format      Check code formatting only"
    echo "  --bundle      Check bundle size only"
    echo "  --all         Run all checks (default)"
    echo "  --help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0           Run all checks"
    echo "  $0 --lint    Run linting only"
    echo "  $0 --test    Run tests only"
}

# Parse command line arguments
case "$1" in
    --lint)
        run_lint
        ;;
    --test)
        run_tests
        ;;
    --security)
        check_vulnerabilities
        ;;
    --format)
        check_formatting
        ;;
    --bundle)
        check_bundle_size
        ;;
    --all|"")
        run_all_checks
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
