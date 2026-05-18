# Zoo Guide Agent

A multi-agent AI tour guide powered by Google's Agent Development Kit (ADK) that can answer questions about zoo animals using Wikipedia.

## Architecture

This application uses a multi-agent workflow:

1. **Greeter Agent** (`root_agent`) - Entry point that welcomes users and captures their questions
2. **Comprehensive Researcher** - Analyzes questions and searches Wikipedia for information
3. **Response Formatter** - Synthesizes research into friendly, conversational responses

## Prerequisites

- Python 3.10 or higher
- Google Cloud Project with billing enabled
- Enabled Google Cloud APIs:
  - Vertex AI API (for Gemini model access)
  - Cloud Run API (for deployment)
  - Artifact Registry API
  - Cloud Build API
  - Compute Engine API

## Setup Instructions

### 1. Clone or Navigate to Project

```bash
cd "zoo_guide_agent"
```

### 2. Set Up Virtual Environment

Using `uv` (recommended):
```bash
uv venv
source .venv/bin/activate  # On macOS/Linux
# or
.venv\Scripts\activate  # On Windows
```

Using `venv`:
```bash
python -m venv .venv
source .venv/bin/activate  # On macOS/Linux
```

### 3. Install Dependencies

Using `uv`:
```bash
uv pip install -r requirements.txt
```

Using `pip`:
```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables

Copy the template:
```bash
cp .env.template .env
```

Edit `.env` and replace with your Google Cloud details:
```bash
PROJECT_ID=your-actual-project-id
PROJECT_NUMBER=your-actual-project-number
SA_NAME=lab2-cr-service
SERVICE_ACCOUNT=${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
MODEL="gemini-2.5-flash"
```

To find your project ID and number:
```bash
gcloud projects list
gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)"
```

### 5. Authenticate with Google Cloud

For local development, set up Application Default Credentials:

```bash
gcloud auth application-default login
```

Or use a service account key:
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
```

### 6. Enable Required APIs

```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  aiplatform.googleapis.com \
  compute.googleapis.com
```

## Running Locally

### Test the Agent Code

```bash
# Activate virtual environment if not already activated
source .venv/bin/activate

# Test imports
python -c "from zoo_guide_agent import agent; print('Agent loaded successfully!')"
```

### Run with ADK CLI (Local Development Server)

```bash
# Install ADK CLI
uvx --from google-adk adk

# Run local development server with UI
uvx --from google-adk adk serve --with_ui .
```

This will start a local server (usually at http://localhost:8080) with the ADK developer UI.

## Deploying to Cloud Run

### 1. Set Up IAM Permissions

```bash
# Load environment variables
source .env

# Create service account
gcloud iam service-accounts create ${SA_NAME} \
    --display-name="Service Account for Zoo Guide Agent"

# Grant Vertex AI User role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/aiplatform.user"
```

### 2. Deploy to Cloud Run

```bash
uvx --from google-adk \
adk deploy cloud_run \
  --project=$PROJECT_ID \
  --region=europe-west1 \
  --service_name=zoo-tour-guide \
  --with_ui \
  . \
  -- \
  --labels=dev-tutorial=codelab-adk \
  --service-account=$SERVICE_ACCOUNT
```

When prompted:
- Allow creation of Artifact Registry repository: **Y**
- Allow unauthenticated invocations (for testing): **y**

The deployment will provide a URL like: `https://zoo-tour-guide-xxxxx.europe-west1.run.app`

## Testing the Agent

### Example Interactions

1. **Greeting**: 
   - Input: "Hello"
   - Expected: Welcoming message asking what you'd like to learn about

2. **Simple Query**: 
   - Input: "Tell me about lions"
   - Expected: Information about lions from Wikipedia

3. **Complex Query**: 
   - Input: "What do polar bears eat?"
   - Expected: Detailed information about polar bear diet

## Project Structure

```
zoo_guide_agent/
├── .env                 # Environment variables (not in git)
├── .env.template        # Template for environment variables
├── __init__.py          # Package initialization
├── agent.py             # Main agent implementation
├── requirements.txt     # Python dependencies
└── README.md           # This file
```

## Troubleshooting

### Import Errors
- Ensure virtual environment is activated
- Verify all dependencies are installed: `pip list | grep google-adk`

### Authentication Errors
- Check `gcloud auth list` to verify authenticated account
- Ensure Vertex AI API is enabled: `gcloud services list --enabled | grep aiplatform`
- Verify service account has correct permissions

### Model Access Errors
- Confirm your Google Cloud project has Vertex AI API enabled
- Check that the MODEL in `.env` is correctly set to "gemini-2.5-flash"

## Resources

- [Google ADK Documentation](https://cloud.google.com/vertex-ai/generative-ai/docs/adk)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)

## License

This is a tutorial project for educational purposes.
