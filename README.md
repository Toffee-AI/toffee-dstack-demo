<h1><a href="https://toffee.ai"><img src="docs/img/toffee-logo.svg" alt="Toffee Logo"></a>&nbsp;Mistral-7B LLM Deployment with dstack</h1>

A production-ready demonstration of deploying the Mistral 7B Instruct LLM using [dstack](https://dstack.ai) across
multiple cloud providers (RunPod and VastAI). This project showcases best practices for LLM hosting with minimal
dependencies and maximum flexibility.

By [Toffee AI](https://toffee.ai/) team.

## Overview

This project demonstrates how to:

- Deploy a production-grade LLM (Mistral-7B) using dstack
- Support multiple cloud backends (RunPod, VastAI) with a single configuration
- Configure and optimize SGLang for efficient inference
- Automate deployments using environment variables and templates

## Table of Contents

- [Tested Environment](#tested-environment)
- [Prerequisites](#prerequisites)
    - [1. Install dstack CLI](#1-install-dstack-cli)
    - [2. Set up dstack Server](#2-set-up-dstack-server)
    - [3. Configure dstack CLI](#3-configure-dstack-cli)
    - [4. Configure Environment Variables](#4-configure-environment-variables)
- [Quick Start](#quick-start)
    - [Render Service Configuration](#render-service-configuration)
    - [Deploy the Service](#deploy-the-service)
    - [Monitor Deployment](#monitor-deployment)
    - [Test the Service](#test-the-service)
    - [Stop the Service](#stop-the-service)
- [Configuration](#configuration)
    - [Environment Variables](#environment-variables)
    - [Customizing the Deployment](#customizing-the-deployment)
- [Project Structure](#project-structure)
- [Troubleshooting](#troubleshooting)
    - [No Capacity Available](#no-capacity-available)
    - [Out of Memory Errors](#out-of-memory-errors)
    - [Model Download Fails](#model-download-fails)
    - [Service Won't Start](#service-wont-start)
- [Advanced Usage](#advanced-usage)
    - [Viewing Service Logs](#viewing-service-logs)
    - [Accessing Service Metrics](#accessing-service-metrics)
- [Hands-On Exercises](#hands-on-exercises)
    - [Exercise 1: Adjust Health Check Probes](#exercise-1-adjust-health-check-probes)
    - [Exercise 2: Deploy with Different GPU Types](#exercise-2-deploy-with-different-gpu-types)
    - [Exercise 3: Rolling Deployments with Replicas](#exercise-3-rolling-deployments-with-replicas)
    - [Exercise 4: Optimize Context Length](#exercise-4-optimize-context-length)
    - [Exercise 5: Experiment with Model Parameters](#exercise-5-experiment-with-model-parameters)
    - [Challenge Exercise: Multi-Environment Setup](#challenge-exercise-multi-environment-setup)
- [Learn More](#learn-more)
- [License](#license)
- [Contributing](#contributing)

## Tested Environment

This project was initially developed and tested with:

- **OS**: Ubuntu 22.04 LTS
- **Shell**: Bash 5.1+
- **Python**: 3.11+
- **Docker**: 24.0+ (for local testing)

While the project should work on other Unix-like systems (macOS, other Linux distributions), the scripts and configurations have been validated on the environment above.

## Prerequisites

### 1. Install dstack CLI

Following the official [dstack CLI installation guide](https://dstack.ai/docs/installation/#set-up-the-cli):

```bash
uv tool install 'dstack[all]' -U
```

### 2. Set up dstack Server

You need a running dstack server with configured cloud backends. This demo supports both RunPod and VastAI.

#### Option A: Local dstack Server (Recommended for Testing)

1. Copy the example server configuration:
   ```bash
   mkdir -p ~/.dstack/server
   
   # Backup existing config if present:
   cp ~/.dstack/server/config.yml ~/.dstack/server/backup.config.yml || true
   
   # If no existing config, copy example:
   cp server/example.config.yaml ~/.dstack/server/config.yml
   # Otherwise, just extend existing config with new project settings from server/example.config.yaml
   ```

2. Edit `~/.dstack/server/config.yml` and replace the placeholder API keys:
    - **RunPod API Key**: Get from [RunPod Settings](https://www.runpod.io/console/user/settings)
    - **VastAI API Key**: Get from [VastAI Account](https://cloud.vast.ai/account/)

3. Start the dstack server:
   ```bash
   dstack server
   ```

   Make sure the server config was applied `[...] INFO     Applying ~/.dstack/server/config.yml...`

   The server will start on `http://127.0.0.1:3000`

#### Option B: Remote dstack Server

For live deployments, consider hosting dstack server on a cloud platform (AWS ECS, GCP, etc.). See
the [dstack documentation](https://dstack.ai/docs) for details.

### 3. Configure dstack CLI

Configure your dstack CLI to connect to your server:

```bash
dstack config \
  --project mistral-7b \
  --url http://127.0.0.1:3000 \
  --token <your_dstack_admin_token_that_you_set_in_server>
```

Confirm:

```shell 
Set 'mistral-7b' as your default project? [y/n]: n
```

P.S. If you elect not to set a default project, remember to always pass `--project mistral-7b` to dstack commands. We do
that below for reproducibility. Otherwise you can set it as default, and never worry about claiming the project again,
but then you will only be able to work with one project at a time.

### 4. Configure Environment Variables

The service configuration uses environment variables for all settings.

Start by copying the example environment file:

```bash
cp example.env .env
```

Edit `.env` to set the required envs, and overall customize your deployment. Check out `example.env` for all available
configuration options.

## Quick Start

Now that you are done with the prerequisites, you can deploy the Mistral-7B service from you local machine.

### Render Service Configuration

The service configuration template (`services/mistral-7b/dstack/template.service.yaml`) uses environment variable
substitution. Use the provided script to render a deployable configuration:

```bash
# Navigate to the service directory
cd ./services/mistral-7b

# Render the configuration using your .env file
./scripts/render-config.bash --env-file ../../.env --output ./dstack/service.yaml
```

### Deploy the Service

**🚨 COST WARNING**: GPU instances, especially high-end GPUs, can be expensive! Always stop your services when not in use to
avoid unexpected charges. The hourly costs adds up quickly if left running.

Deploy the service using the configuration you have just rendered:

```bash
# Export all environment variables from .env; this is necessary for dstack to set the envs in the `env:` section:
set -a; source ../../.env; set +a

dstack apply -f ./dstack/service.yaml --project mistral-7b
```

After you confirm the plan, dstack will:

1. Find available GPU capacity on RunPod or VastAI
2. Provision a container with the specified resources
3. Install dependencies (uv, SGLang, system packages)
4. Download and load the Mistral-7B model
5. Start the inference server

### Monitor Deployment

```bash
dstack ps --project mistral-7b --watch
```

### Test the Service

Once deployed, you can try asking the LLM a question using the standard SGLang completions endpoint:

```bash
TOKEN=<your_dstack_admin_token_that_you_set_in_server>

curl -X POST http://127.0.0.1:3000/proxy/services/mistral-7b/mistral-7b/v1/completions \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "mistralai/Mistral-7B-Instruct-v0.2",
    "prompt": "Explain quantum computing in simple terms:",
    "max_tokens": 100
  }'
```

### Stop the Service

**Stop a specific service:**

```bash
dstack stop mistral-7b --project mistral-7b
```

**Stop all running services:**

**⚠️ WARNING**:: Be cautious with this command as it will stop all services in your current dstack project.

```bash
# List all running services
dstack ps --project mistral-7b

# Stop each service individually
dstack stop <service-name> --project mistral-7b
```

**Destroy all resources (complete cleanup):**

If you want to ensure all cloud resources are terminated:

```bash
# Stop all services in the mistral-7b project
for service in $(dstack ps --project mistral-7b --format json | jq -r '.[].name'); do
    echo "Stopping ${service}..."
    dstack stop "${service}" --project mistral-7b
done
```

**Verify all resources are stopped:**

```bash
dstack ps --project mistral-7b
```

The output should show no running services. If you see any stuck or failed services, you may need to manually terminate
them through the RunPod or VastAI web console.

**Important notes:**

- dstack `stop` gracefully terminates the service and releases the cloud resources
- Stopped services do not incur compute costs
- Downloaded models and data are not preserved after stopping (will re-download on next deployment)
- For production workloads, consider setting up automatic shutdown schedules or cost alerts

## Configuration

### Environment Variables

All configuration is done through environment variables, which can be:

- Set in your shell before running `dstack apply`
- Defined in a `.env` file
- Passed when rendering the `dstack/template.service.yaml` template

#### Service Configuration

| Variable       | Default    | Description                  |
|----------------|------------|------------------------------|
| `SERVICE_NAME` | `mistral-7b` | Name of the deployed service |
| `HOST`         | `0.0.0.0`  | Server host address          |
| `PORT`         | `8080`     | Server port                  |

#### Resource Requirements

| Variable      | Default     | Description                    |
|---------------|-------------|--------------------------------|
| `CPU`         | `8..`       | Minimum CPU cores              |
| `MEMORY`      | `12GB..`    | Minimum RAM                    |
| `GPU`         | `RTX4090:1` | GPU type and count             |
| `DISK`        | `50GB..`    | Minimum disk space             |
| `SPOT_POLICY` | `on-demand` | Instance type (spot/on-demand) |

#### Dependencies

| Variable         | Default                                                    | Description                |
|------------------|------------------------------------------------------------|----------------------------|
| `UV_VERSION`     | `0.8.18`                                                   | uv package manager version |
| `SGLANG_VERSION` | `0.5.2`                                                    | SGLang version             |
| `DOCKER_IMAGE`   | `runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04` | Base Docker image          |

### Customizing the Deployment

Edit your `.env` file or export the variable:

```bash
export PORT='8081'
cd services/mistral-7b
./scripts/render-config.bash --env-file ../../.env | dstack apply -f - --project mistral-7b
```

## Project Structure

```
toffee-dstack-demo/
├── server/
│   └── example.config.yaml         # Example dstack server configuration
├── services/
│   └── mistral-7b/
│       ├── dstack/
│       │   └── template.service.yaml   # dstack service template (requires rendering)
│       └── scripts/
│           ├── setup.bash              # Dependency installation
│           ├── start.bash              # Service startup
│           └── render-config.bash      # Renders template with env vars
├── example.env                    # Example environment variables
├── .dstackignore                   # Files excluded from deployment
└── README.md                       # This file
```

## Troubleshooting

### No Capacity Available

1. Change GPU type in `.env`: `GPU="RTX4090:1"` or `GPU="A100:1"`
2. Enable spot instances in `.env`: `SPOT_POLICY="spot"`
3. Increase retry duration in `.env`: `RETRY_DURATION="24h"`
4. Check that your RunPod/VastAI API keys are valid in server config

### Out of Memory Errors

1. Reduce memory fraction: `export MEM_FRACTION_STATIC="0.7"`
2. Reduce context length: `export CONTEXT_LENGTH="1024"`
3. Use a larger GPU: `export GPU="A100:1"`

### Model Download Fails

1. Set HuggingFace token: `export HF_TOKEN="your_token"`
2. Accept model license on HuggingFace
3. Verify model ID is correct

### Service Won't Start

Check dstack logs:

```bash
dstack logs mistral-7b --project mistral-7b
```

Common issues:

- Missing HF_TOKEN for gated models
- Insufficient GPU memory
- Network connectivity issues

## Advanced Usage

### Viewing Service Logs

```bash
dstack logs mistral-7b --follow --project mistral-7b
```

### Accessing Service Metrics

SGLang exposes Prometheus metrics at `/metrics`:

```bash
curl http://<service-endpoint>/metrics
```

---

## Hands-On Exercises

Now that you have a working deployment, try these exercises to deepen your understanding of dstack and service
configuration. Each exercise builds on the core concepts and helps you learn how to customize deployments for different
scenarios.

### Exercise 1: Adjust Health Check Probes

**Objective**: Modify the service health check intervals to understand how dstack monitors service health.

**Task**:

1. Open `services/mistral-7b/dstack/template.service.yaml`
2. Locate the `probes` section (currently set to check every 10s)
3. Modify the probe configuration:
   ```yaml
   probes:
     - type: http
       url: /health
       interval: 30s    # Change from 10s to 30s
       timeout: 10s     # Change from 5s to 10s
   ```
4. Re-render and redeploy the service
5. Monitor the logs to see how the health check interval affects deployment

**Questions to consider**:

- How does increasing the interval affect deployment time?
- What happens if you set the timeout too low?
- When would you want more frequent health checks?

### Exercise 2: Deploy with Different GPU Types

**Objective**: Learn how to adapt the deployment for different GPU availability and pricing.

**Task**:

1. Edit your `.env` file and change the GPU type:
   ```bash
   # Try different GPUs
   GPU=RTX4090:1    # Consumer GPU (usually cheaper)
   # GPU=L40:1      # Alternative datacenter GPU
   # GPU=A100:1     # High-end option
   ```
2. Adjust memory fraction if needed (smaller GPUs may need lower values):
   ```bash
   MEM_FRACTION_STATIC=0.7  # For GPUs with less memory
   ```
3. Re-render, export envs, and redeploy
4. Compare performance and costs between GPU types

**Questions to consider**:

- Which GPU provides the best price/performance ratio?
- How does GPU memory affect model loading and inference?
- What happens if you try to deploy on a GPU with insufficient memory?

### Exercise 3: Rolling Deployments with Replicas

**Objective**: Learn how dstack handles scaling by incrementing replicas and observing rolling deployments.

**Task**:

1. Start with a single replica deployment (default: `REPLICAS=1`)
2. Update your `.env` file to scale up:
   ```bash
   REPLICAS=3
   ```
3. Re-render the configuration:
   ```bash
   cd services/mistral-7b
   ./scripts/render-config.bash --env-file ../../.env --output ./dstack/service.yaml
   ```
4. Apply the updated configuration:
   ```bash
   set -a; source ../../.env; set +a
   dstack apply -f ./dstack/service.yaml --project mistral-7b
   ```
5. Watch the rolling deployment in real-time:
   ```bash
   watch -n 5 'dstack ps --project mistral-7b'
   ```
6. Observe the status changes as new replicas spin up:
   - `provisioning` → `building` → `running`
7. Once all replicas are running, scale down to 1 and observe the termination process

**Questions to consider**:

- How does dstack handle the rollout of new replicas?
- What happens to existing replicas during scaling?
- How long does it take for a new replica to become `running`?
- When would you need multiple replicas in production?

### Exercise 4: Optimize Context Length

**Objective**: Understand the relationship between context length and memory usage.

**Task**:

1. Modify context length in `.env`:
   ```bash
   # Try different context lengths
   CONTEXT_LENGTH=1024   # Shorter context, less memory
   # CONTEXT_LENGTH=4096 # Longer context, more memory
   # CONTEXT_LENGTH=8192 # Maximum context (may require more GPU memory)
   ```
2. Adjust max prefill tokens accordingly:
   ```bash
   MAX_PREFILL_TOKENS=32768  # Typically 2-4x context length
   ```
3. Re-render and redeploy
4. Test with prompts of varying lengths

**Questions to consider**:

- How does context length affect memory usage?
- What's the trade-off between context length and throughput?
- When would you need longer context windows?

### Exercise 5: Experiment with Model Parameters

**Objective**: Tune SGLang performance parameters for your workload.

**Task**:

1. Modify performance settings in `.env`:
   ```bash
   # Disable torch compile for faster startup (but slower inference)
   ENABLE_TORCH_COMPILE=false

   # Change scheduling policy
   SCHEDULE_POLICY=fcfs  # First-come-first-served instead of LPM

   # Adjust conservativeness (0.0 = aggressive, 1.0 = conservative)
   SCHEDULE_CONSERVATIVENESS=0.5
   ```
2. Re-render and redeploy
3. Benchmark inference latency and throughput
4. Compare with default settings

**Questions to consider**:

- How do these parameters affect cold start time?
- What's the trade-off between startup speed and inference performance?
- Which scheduling policy works best for your use case?

### Challenge Exercise: Multi-Environment Setup

**Objective**: Create separate dev and prod configurations.

**Task**:

1. Create `.env.dev` and `.env.prod` files:
   ```bash
   # .env.dev
   SERVICE_NAME=mistral-7b-dev
   SPOT_POLICY=spot
   GPU=RTX4090:1
   REPLICAS=1

   # .env.prod
   SERVICE_NAME=mistral-7b-prod
   SPOT_POLICY=on-demand
   GPU=RTX4090:1
   REPLICAS=2
   ```
2. Deploy to both environments:
   ```bash
   # Dev deployment
   ./scripts/render-config.bash --env-file ../../.env.dev --output dev.yaml
   set -a; source ../../.env.dev; set +a
   dstack apply -f dev.yaml --project mistral-7b

   # Prod deployment
   ./scripts/render-config.bash --env-file ../../.env.prod --output prod.yaml
   set -a; source ../../.env.prod; set +a
   dstack apply -f prod.yaml --project mistral-7b
   ```
3. Manage both deployments independently

**Questions to consider**:

- How do you organize multiple environment configs?
- What should differ between dev and prod?
- How do you prevent accidentally deploying to the wrong environment?

---

## Learn More

- [dstack Documentation](https://dstack.ai/docs)
- [SGLang Documentation](https://github.com/sgl-project/sglang)
- [Mistral Model Card](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2)
- [RunPod Documentation](https://docs.runpod.io/)
- [VastAI Documentation](https://vast.ai/docs/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! We appreciate bug reports, feature suggestions, documentation improvements, and code
contributions.

Please read our [Contributing Guide](CONTRIBUTING.md) for details on:

- How to report bugs and suggest enhancements
- Development setup and workflow
- Style guidelines and best practices
- Testing your changes
- Submitting pull requests

For quick contributions, feel free to submit a Pull Request directly.
