#!/bin/bash

# Local test runner for Zoo Guide Agent
# This script activates the virtual environment and starts the ADK development server

set -e  # Exit on error

echo "🦁 Starting Zoo Guide Agent - Local Development Server"
echo "======================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "agent.py" ]; then
    echo "❌ Error: agent.py not found. Please run this script from the zoo_guide_agent directory."
    exit 1
fi

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Error: Virtual environment not found. Please run ./setup.sh first."
    exit 1
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found. Please copy .env.template to .env and configure it."
    exit 1
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source .venv/bin/activate

# Load environment variables
echo "📋 Loading environment variables..."
source .env

# Check authentication
echo "🔐 Checking Google Cloud authentication..."
if ! gcloud auth application-default print-access-token &>/dev/null; then
    echo "⚠️  Warning: Google Cloud authentication not configured."
    echo "   Run: gcloud auth application-default login"
    echo ""
    read -p "Do you want to authenticate now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gcloud auth application-default login
    else
        echo "❌ Cannot continue without authentication."
        exit 1
    fi
fi

echo "✅ Authenticated"
echo ""

# Start the ADK development server
echo "🚀 Starting ADK development server with UI..."
echo ""
echo "Server will be available at: http://localhost:8080"
echo "Press Ctrl+C to stop the server"
echo ""

uvx --from google-adk adk web .
