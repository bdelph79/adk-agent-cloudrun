#!/bin/bash

# Setup script for Zoo Guide Agent
# This script helps set up the development environment

set -e  # Exit on error

echo "🦁 Zoo Guide Agent - Setup Script"
echo "=================================="
echo ""

# Check if we're in the right directory
if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: requirements.txt not found. Please run this script from the zoo_guide_agent directory."
    exit 1
fi

# Check Python version
echo "📋 Checking Python version..."
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
echo "Found Python $PYTHON_VERSION"
echo ""

# Check if uv is installed
if command -v uv &> /dev/null; then
    echo "✅ 'uv' is installed"
    USE_UV=true
else
    echo "ℹ️  'uv' not found, will use standard venv"
    USE_UV=false
fi
echo ""

# Create virtual environment
echo "🔧 Creating virtual environment..."
if [ "$USE_UV" = true ]; then
    uv venv
else
    python3 -m venv .venv
fi
echo "✅ Virtual environment created"
echo ""

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source .venv/bin/activate
echo "✅ Virtual environment activated"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
if [ "$USE_UV" = true ]; then
    uv pip install -r requirements.txt
else
    pip install -r requirements.txt
fi
echo "✅ Dependencies installed"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found"
    if [ -f ".env.template" ]; then
        echo "📝 Creating .env from template..."
        cp .env.template .env
        echo "✅ .env file created from template"
        echo ""
        echo "⚠️  IMPORTANT: Edit .env and add your Google Cloud project details:"
        echo "   - PROJECT_ID"
        echo "   - PROJECT_NUMBER"
        echo ""
    else
        echo "❌ .env.template not found. Please create .env manually."
    fi
else
    echo "✅ .env file exists"
    echo ""
fi

# Check gcloud CLI
echo "🔍 Checking Google Cloud CLI..."
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud CLI is installed"
    CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null || echo "not-set")
    echo "   Current project: $CURRENT_PROJECT"
    echo ""
else
    echo "⚠️  gcloud CLI not found. Please install it from:"
    echo "   https://cloud.google.com/sdk/docs/install"
    echo ""
fi

# Test agent import
echo "🧪 Testing agent import..."
if python3 -c "from zoo_guide_agent import agent; print('✅ Agent imported successfully')" 2>/dev/null; then
    echo ""
else
    echo "⚠️  Could not import agent. This may be normal if Google Cloud is not configured yet."
    echo ""
fi

echo "=================================="
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Activate the virtual environment: source .venv/bin/activate"
echo "2. Configure .env with your Google Cloud details"
echo "3. Authenticate with Google Cloud: gcloud auth application-default login"
echo "4. Enable required APIs (see README.md)"
echo "5. Run the agent locally: uvx --from google-adk adk serve --with_ui ."
echo ""
