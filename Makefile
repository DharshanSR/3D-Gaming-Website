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
