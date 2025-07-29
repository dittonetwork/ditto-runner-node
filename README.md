# Ditto Runner Node

This repository contains the backend services for the Ditto Network, a decentralized automation platform. The services include the **Simulator** for workflow execution and the **Indexer** for on-chain data retrieval. The entire system is orchestrated using Docker and Docker Compose to ensure a consistent and straightforward development environment.

## Architecture

The Ditto Runner Node is composed of two primary services, managed by `docker-compose.yml`, which work together to execute and monitor workflows.

-   **`simulator`**: This is the core execution engine. It is responsible for fetching, interpreting, and running Ditto workflows. It connects to an Ethereum-compatible blockchain to submit transactions and interacts with IPFS for storing and retrieving workflow definitions.

-   **`indexer`**: This service monitors the blockchain for events related to Ditto workflows. It indexes this data into a MongoDB database, providing a fast, queryable API for frontends and other services that need to display workflow history, status, and other on-chain information.

The project also includes two git submodules:

-   `indexer/`: Contains the Python-based indexer service.
-   `simulator/`: Contains the TypeScript-based simulator service and the Ditto Workflow SDK.

## Prerequisites

Before you begin, ensure you have the following tools installed and configured on your system:

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [Make](https://www.gnu.org/software/make/) (optional, but recommended for streamlined commands)

## Getting Started

Follow these steps to set up and run the Ditto Runner Node.

### 1. Clone the Repository

First, clone the repository to your local machine.

```bash
git clone https://github.com/dittonetwork/ditto-runner-node.git
cd ditto-runner-node
```

### 2. Initialize Submodules

The project relies on git submodules for its main services. Initialize them with the following command:

```bash
git submodule update --init --recursive
```

### 3. Configure Environment Variables

The services are configured using environment variables. To get started, copy the provided example file to a new `.env` file.

```bash
cp .env.example .env
```

Next, open the `.env` file in your editor and fill in the required values. At a minimum, you **must** provide the `EXECUTOR_PRIVATE_KEY`.

**CRITICAL**: The `EXECUTOR_PRIVATE_KEY` is a sensitive credential. Never commit your `.env` file or hardcode private keys in version control.

### 4. Build and Run the Services

With the configuration in place, you can build and start all services using a single `make` command. This command will build the Docker images and start the containers in detached mode.

```bash
make up
```

If you do not have `make` installed, you can run the equivalent Docker Compose command directly:

```bash
docker-compose up -d --build
```

The initial startup may take a few minutes as Docker downloads images and builds the service containers.

## Usage

The provided `Makefile` simplifies the management of the Docker stack.

-   `make up`: Builds and starts all services.
-   `make down`: Stops and removes all running containers, networks, and volumes.
-   `make logs`: Tails the logs from all running services. Press `Ctrl+C` to exit.
-   `make ps`: Lists all running containers for this project.

## Configuration

All service configuration is managed through the `.env` file. The default values are set for a Sepolia testnet environment. For production or other networks, you will need to adjust these values accordingly.

### Common Configuration

These variables are shared between the `simulator` and `indexer` services.

| Variable       | Description                                                                 | Default Value                           |
| -------------- | --------------------------------------------------------------------------- | --------------------------------------- |
| `MONGO_URI`    | **Required.** The connection string for the MongoDB instance.               | `mongodb://mongo:27017/?replicaSet=rs0` |
| `DB_NAME`      | **Required.** The name of the database the services will use.               | `indexer`                               |
| `LOG_LEVEL`    | The verbosity of application logs (e.g., `info`, `debug`, `error`).         | `info`                                  |
| `LOG_PRETTY`   | A boolean (`true`/`false`) to enable human-readable, colorized log output.  | `true`                                  |

### `simulator` Service

This service executes and manages workflows.

| Variable                      | Description                                                                                                                              | Default Value                                                |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `EXECUTOR_PRIVATE_KEY`        | **CRITICAL.** The private key for the account that executes transactions. **Must be provided.**                                            | (none)                                                       |
| `CHAIN_ID`                    | **Required.** The chain ID of the target network.                                                                                        | `11155111` (Sepolia)                                         |
| `RPC_URL`                     | **Required.** The primary RPC endpoint for the blockchain.                                                                               | `https://rpc.sepolia.org`                                    |
| `DEFAULT_RPC_URL_SEPOLIA`     | **Required.** A zerodev RPC URL for Sepolia.                                                                                             | (See `.env.example`)                                         |
| `IPFS_SERVICE_URL`            | **Required.** The URL for the IPFS service to store and retrieve workflow data.                                                          | `https://ipfs-service.develop.dittonetwork.io`               |
| `WORKFLOW_CONTRACT_ADDRESS`   | **Required.** The deployed address of the master Ditto Workflow contract.                                                                | `0x5CE...ECE6`                                               |
| `MAX_WORKERS`                 | The maximum number of concurrent workers for processing jobs.                                                                            | `1`                                                          |
| `RUNNER_NODE_SLEEP`           | The sleep interval in seconds for the main runner loop.                                                                                  | `60`                                                         |
| `FULL_NODE`                   | A boolean (`true`/`false`) to determine if the node should run in "full" mode.                                                           | `false`                                                      |
| `MAX_MISSING_NEXT_SIM_LIMIT`  | The threshold for how many times a workflow simulation can be missed before it's flagged.                                                | `100`                                                        |
| `MAX_BLOCK_RANGE_11155111`    | The maximum number of blocks to scan at once on Sepolia (chain ID 11155111).                                                              | `10000`                                                      |
| `MAX_BLOCK_RANGE_1`           | The maximum number of blocks to scan at once on Ethereum Mainnet (chain ID 1).                                                           | `2000`                                                       |

### `indexer` Service

This service listens for on-chain events and indexes them.

| Variable                    | Description                                                                        | Default Value                                                |
| --------------------------- | ---------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| `RPC_11155111`              | **Required.** The RPC endpoint for the Sepolia network (chain ID 11155111).         | `https://rpc.sepolia.org`                                    |
| `IPFS_CONNECTOR_ENDPOINT`   | **Required.** The IPFS endpoint used to fetch metadata for indexed items.          | `https://ipfs-service.develop.dittonetwork.io/ipfs/read`     |
| `META_FILLER_SLEEP`         | The sleep interval in seconds for the metadata filler worker.                      | `2`                                                          |

## Troubleshooting

Here are some common issues and how to resolve them:

-   **Containers Fail to Start:**
    -   Ensure the Docker daemon is running on your system.
    -   Check that no other service is using port `27017`, which is required by the MongoDB container.
    -   Run `make down` and then `make up` to perform a clean restart.

-   **RPC or IPFS Errors in Logs:**
    -   The default public RPC and IPFS endpoints may be rate-limited or temporarily unavailable.
    -   **Solution:** Replace the RPC and IPFS URLs in your `.env` file with your own private endpoints from a provider like [Infura](https://infura.io), [Alchemy](https://www.alchemy.com), or [QuickNode](https://www.quicknode.com).

-   **`mongo-init` Service Fails or Exits:**
    -   The `mongo-init` service initializes the MongoDB replica set and is designed to run only once. It may fail due to timing issues on the first startup.
    -   **Solution:** This is often not a critical error if the replica set is already initialized. Running `make down && make up` will usually resolve any underlying issues.

-   **Submodule-Related Errors:**
    -   If you encounter errors about missing files or directories within the `simulator` or `indexer` folders, the git submodules may not have been initialized correctly.
    -   **Solution:** Run `git submodule update --init --recursive` to ensure the submodules are properly cloned and up to date. 