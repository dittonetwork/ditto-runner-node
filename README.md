# Ditto Runner Node

This repository contains the backend services for the Ditto Network, including the Simulator and the Indexer. It uses Docker and Docker Compose to orchestrate the services, making setup and development straightforward.

## Architecture

The project consists of two main services, orchestrated by `docker-compose.yml`:

-   **`simulator`**: Responsible for executing and simulating Ditto workflows. It interacts with an Ethereum-compatible blockchain and IPFS for data storage.
-   **`indexer`**: Indexes data from the blockchain to provide a queryable API for the frontend and other services.

The project also relies on two submodules:

-   `indexer/`: Contains the source code for the indexer service.
-   `simulator/`: Contains the source code for the simulator service, including the Ditto Workflow SDK.

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

2.  **Run the setup command:**

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

The services are configured via environment variables in `docker-compose.yml`. While default values are provided for a Sepolia testnet environment, you may need to adjust them for production, different networks, or if public endpoints become unavailable.

### `simulator` Service

This service executes and manages workflows.

| Variable                      | Description                                                                                                                              |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `MONGO_URI`                   | **Required.** The connection string for the MongoDB instance.                                                                            |
| `DB_NAME`                     | **Required.** The name of the database the simulator will use.                                                                           |
| `EXECUTOR_PRIVATE_KEY`        | **CRITICAL.** The private key for the account that executes and pays for transactions. **Never commit a real key to version control.**     |
| `RPC_URL_<CHAIN_ID>`          | **Required.** RPC endpoints for the supported blockchains. At least one is required. Example: `RPC_URL_11155111` for Sepolia.               |
| `ZERODEV_API_KEY`             | **Required.** API key for ZeroDev for sponsoring transactions.                                                                             |
| `IPFS_SERVICE_URL`            | **Required.** The URL for the IPFS service used to store and retrieve workflow data.                                                     |
| `MAX_WORKERS`                 | The maximum number of concurrent workers for processing jobs.                                                                            |
| `RUNNER_NODE_SLEEP`           | The sleep interval in seconds for the main runner loop.                                                                                  |
| `FULL_NODE`                   | A boolean flag (`true`/`false`) to determine if the node should run in "full" mode, potentially enabling more features or checks.         |
| `MAX_MISSING_NEXT_SIM_LIMIT`  | The threshold for how many consecutive times a workflow simulation can be missed before it's flagged.                                    |
| `MAX_BLOCK_RANGE_<CHAIN_ID>`  | The maximum number of blocks to scan at once on a given network, e.g., `MAX_BLOCK_RANGE_11155111` for Sepolia.                            |
| `IS_PROD`                     | A boolean flag (`true`/`false`) to indicate if the environment is production.                                                          |
| `LOG_LEVEL`                   | The verbosity of the application logs (e.g., `info`, `debug`, `error`).                                                                  |
| `LOG_PRETTY`                  | A boolean flag (`true`/`false`) to enable human-readable, colorized log output.                                                          |

### `indexer` Service

This service listens for on-chain events and indexes them for fast querying.

| Variable                    | Description                                                                                             |
| --------------------------- | ------------------------------------------------------------------------------------------------------- |
| `MONGO_URI`                 | **Required.** The connection string for the MongoDB instance.                                           |
| `DB_NAME`                   | **Required.** The name of the database the indexer will use.                                            |
| `META_FILLER_SLEEP`         | The sleep interval in seconds for the metadata filler worker, which enriches indexed data.              |
| `IPFS_CONNECTOR_ENDPOINT`   | **Required.** The IPFS endpoint used to fetch metadata for indexed items.                               |
| `RPC_URL_<CHAIN_ID>`        | **Required.** RPC endpoints for the supported blockchains, used for fetching on-chain data. Example: `RPC_URL_11155111` for Sepolia. |

## Troubleshooting

Here are some common issues and how to resolve them:

-   **Containers fail to start:**
    -   Ensure the Docker daemon is running.
    -   Check if any other service on your machine is using port `27017`, which is required by MongoDB.
    -   Run `make down` and then `make up` to try a fresh start.

-   **Errors related to RPC or IPFS in logs:**
    -   The public RPC and IPFS endpoints provided in the default configuration may be rate-limited or temporarily unavailable.
    -   **Solution:** Replace the `RPC_URL_<CHAIN_ID>` and `IPFS_SERVICE_URL` values in your `.env` file (or `docker-compose.yml`) with your own private or alternative public endpoints (e.g., from Infura, Alchemy, or QuickNode).

-   **`mongo-init` service fails:**
    -   The `mongo-init` service is responsible for initializing the MongoDB replica set. It can sometimes fail due to timing issues.
    -   **Solution:** Running `make down && make up` usually resolves this. The service is configured not to restart automatically, so a manual restart of the stack is needed.

-   **Submodule-related errors:**
    -   If you see errors about missing files or directories within the `simulator` or `indexer` directories, it's likely the submodules were not initialized correctly.
    -   **Solution:** Run `make setup` or `git submodule update --init --recursive` manually to ensure the submodules are cloned and up to date. 