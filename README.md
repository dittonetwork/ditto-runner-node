# Ditto Runner Node

This repository contains the backend services for the Ditto Network, including the Simulator and the Indexer. It uses Docker and Docker Compose to orchestrate the services, making setup and development straightforward.

## Architecture

The project consists of two main services, orchestrated by a root `docker-compose.yml`:

-   **`simulator`**: Responsible for executing and simulating Ditto workflows. It interacts with an Ethereum-compatible blockchain and IPFS for data storage.
-   **`indexer`**: Indexes data from the blockchain to provide a queryable API for the frontend and other services.

The project relies on two git submodules:

-   `indexer/`: Contains the source code for the indexer service.
-   `simulator/`: Contains the source code for the simulator service, including the Ditto Workflow SDK.

## Whitelisting for Reporting

Before running the node, the operator must join the [Telegram group](https://t.me/+_zH57wUkqsIzYmYy) and provide their public key. This step is necessary to enable operations and reporting.
Failure to complete this step will prevent the node from functioning properly in the live environment.

## Prerequisites

Before you begin, ensure you have the following installed on your system:

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [Make](https://www.gnu.org/software/make/) (optional, but recommended for using the provided commands)

## Getting Started

The setup process is simplified using the provided `Makefile`.

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/dittonetwork/ditto-runner-node.git
    cd ditto-runner-node
    ```

2.  **Configure Environment Variables:**

    The services are configured via a `.env` file in the root of the project. A template is provided in `env.example`. Copy this file to `.env` and populate it with your configuration values.

    ```bash
    cp env.example .env
    ```

    You must provide values for `RPC_URL_<CHAIN_ID>`, `ZERODEV_API_KEY`, and `EXECUTOR_PRIVATE_KEY` to run the application.

    The currently available chain_ids are:
    - Sepolia (chain_id: 11155111)
    - Base (chain_id: 8453)

3.  **Run the setup command:**

    This single command will initialize the git submodules, then build and start all the services in detached mode.

    ```bash
    make up
    ```

    If you don't have `make`, you can run the steps manually:
    
    ```bash
    # 1. Initialize and update the git submodules
    git submodule update --init --recursive
    
    # 2. Build and start the docker containers
    docker-compose up -d --build
    ```

## Usage

The `Makefile` provides convenient commands for managing the application stack:

-   `make up`: Starts all services. It also runs the initial setup on the first run.
-   `make down`: Stops and removes all running containers.
-   `make logs`: Tails the logs from all running services. Use `Ctrl+C` to exit.

## Configuration

The services are configured via environment variables defined in the `.env` file. Below is a detailed breakdown of the available variables.

### Common Configuration

| Variable    | Description                                          | Service(s)        |
| ----------- | ---------------------------------------------------- | ----------------- |
| `MONGO_URI` | **Required.** The connection string for MongoDB.     | `simulator`, `indexer` |
| `DB_NAME`   | **Required.** The name of the database to use.       | `simulator`, `indexer` |

### Simulator Service

| Variable | Description |
| --- | --- |
| **`RPC_URL_11155111`** | **Required.** The RPC endpoint for the Sepolia network (chain ID 11155111). |
| **`ZERODEV_API_KEY`** | **Required.** Your ZeroDev API key for the Sepolia network. |
| **`MAX_WORKERS`** | The maximum number of concurrent workers for processing jobs. |
| **`RUNNER_NODE_SLEEP`**| The sleep interval in seconds for the main runner loop. |
| **`FULL_NODE`** | A boolean (`true`/`false`) to determine if the node runs in "full" mode. |
| **`MAX_MISSING_NEXT_SIM_LIMIT`** | The threshold for how many consecutive times a workflow simulation can be missed. |
| **`MAX_BLOCK_RANGE_11155111`** | The maximum number of blocks to scan at once on the Sepolia network. |
| **`MAX_BLOCK_RANGE_1`** | The maximum number of blocks to scan at once on the Ethereum Mainnet. |
| **`EXECUTOR_PRIVATE_KEY`**| **CRITICAL.** The private key for the account that executes transactions. |
| **`IPFS_SERVICE_URL`** | **Required.** The URL for the IPFS service to store and retrieve workflow data. |
| **`WORKFLOW_CONTRACT_ADDRESS`** | **Required.** The deployed address of the master Ditto Workflow contract. |
| **`LOG_LEVEL`** | The verbosity of the logs (e.g., `info`, `debug`, `error`). |
| **`LOG_PRETTY`** | A boolean (`true`/`false`) to enable human-readable, colorized log output. |

### Indexer Service

| Variable | Description |
| --- | --- |
| **`META_FILLER_SLEEP`** | The sleep interval in seconds for the metadata filler worker. |
| **`IPFS_CONNECTOR_ENDPOINT`** | **Required.** The IPFS endpoint used to fetch metadata for indexed items. |
| **`RPC_URL_11155111`** | **Required.** The RPC endpoint for the Sepolia network for the indexer. |

## Troubleshooting

Here are some common issues and how to resolve them:

-   **Containers fail to start:**
    -   Ensure the Docker daemon is running.
    -   Check if any other service on your machine is using port `27017`, which is required by MongoDB.
    -   Run `make down` and then `make up` to try a fresh start.

-   **Errors related to RPC or IPFS in logs:**
    -   The public RPC and IPFS endpoints may be rate-limited or temporarily unavailable.
    -   **Solution:** Ensure you have correctly set your own `RPC_URL_11155111` and other required URLs in your `.env` file.

-   **`mongo-init` service fails:**
    -   The `mongo-init` service is responsible for initializing the MongoDB replica set. It can sometimes fail due to timing issues.
    -   **Solution:** Running `make down && make up` usually resolves this. The service is configured not to restart automatically, so a manual restart of the stack is needed.

-   **Submodule-related errors:**
    -   If you see errors about missing files or directories within the `simulator` or `indexer` directories, it's likely the submodules were not initialized correctly.
    -   **Solution:** Run `git submodule update --init --recursive` manually to ensure the submodules are cloned and up to date. 
