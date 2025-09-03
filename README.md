# Ditto Runner Node

This repository contains the backend services for the Ditto Network, including the Simulator and the Indexer. It uses Docker and Docker Compose to orchestrate the services, making setup and development straightforward.

# Operator Incentives & Rules

During the Alpha phase, operators will be rewarded based on their performance in simulations. Points are distributed retrospectively and will become visible after the Alpha phase concludes.

- Reward Mechanism:
A public leaderboard available at https://app.dittonetwork.io/operators tracks the operator performance. Based on this data Ditto will determine and distribute points to the most performing operators at the end of the Alpha phase.
    
- Fairness & Validity:
Only valid simulations are counted (no duplicates, no broken reports).
    
- Stake Equivalence:
Rewards are designed to simulate staking value and add additional incentives exclusively for node operators.

## Architecture

The project consists of two main services, orchestrated by `docker-compose.yml`:

-   **`simulator`**: Responsible for executing and simulating Ditto workflows. It interacts with an Ethereum-compatible blockchain and IPFS for data storage.
-   **`indexer`**: Indexes data from the blockchain to provide a queryable API for the frontend and other services.

## Prerequisites
### Hardware 

To ensure stable performance, we recommend running the software on an instance with at least the following specifications:

Instance type: Equivalent to AWS [t3a.medium](https://costcalc.cloudoptimo.com/aws-pricing-calculator/ec2/t3a.medium) (2 vCPUs, 4 GB RAM)
Storage: 20 GB or more (SSD recommended)

### Software 
Before you begin, ensure you have the following installed on your system:

-   [Docker](https://docs.docker.com/get-docker/)
-   [Docker Compose](https://docs.docker.com/compose/install/)
-   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [Make](https://www.gnu.org/software/make/) (optional, but recommended for using the provided commands)

## Getting Started
The setup process is simplified using the provided `Makefile`.

### 1. Whitelisting for Reporting

Before running the node, each operator has to be whitelisted. Please join the [Telegram group](https://t.me/+_zH57wUkqsIzYmYy) and provide your simulator and operator addresses in the following [google form](https://forms.gle/iQcGKtY7wq66Dnxg6). 
- Simulator address: This is the public address of the EOA the operator will use to sign reports. Please generate a new key for this purpose and do not use your real operator key during the Alpha phase.
- Operator address: This is the address that holds the delegated stake on Symbiotic.

This step is necessary to enable operations and reporting. Failure to complete this step will prevent the node from functioning properly in the live environment.

### 2. Configure Environment Variables

This project uses a `.env` file to manage sensitive and environment-specific variables. You must create this file in the root of the project.

Create a file named `.env` and add the following critical variables. These are **required** for the node to operate.

```
EXECUTOR_PRIVATE_KEY=...
# Sepolia
RPC_URL_11155111=...
# Base
RPC_URL_8453=...
# Arbitrum
RPC_URL_42161=...
# Mainnet
RPC_URL_1=...
# Polygon
RPC_URL_137=...
# Optimism
RPC_URL_10=...
ZERODEV_API_KEY=...
```

-   `EXECUTOR_PRIVATE_KEY`: The private key of the wallet that will execute transactions.
-   `RPC_URL_<CHAIN_ID>`: RPC endpoints for the supported blockchains.
-   `ZERODEV_API_KEY`: Your API key from [ZeroDev](https://dashboard.zerodev.app), used for UserOperation simulations and executions.

### 3. Clone the Repository

```bash
git clone https://github.com/dittonetwork/ditto-runner-node.git
cd ditto-runner-node
```

### 4. Run the Setup Command

This single command will initialize the git submodules, then build and start all the services in detached mode.

```bash
make up
```

If you don't have `make`, you can run the steps manually:

```bash
# 2. Build and start the docker containers
docker compose up -d
```

## Configuration

The services are configured via environment variables. Critical secrets are loaded from the `.env` file, while other service-specific configurations are set directly in `docker-compose.yml`.

### `simulator` Service

This service executes and manages workflows.

| Variable | Description |
| --- | --- |
| `MONGO_URI` | **Required.** The connection string for the MongoDB instance. |
| `DB_NAME` | **Required.** The name of the database the simulator will use. |
| `EXECUTOR_PRIVATE_KEY` | **CRITICAL.** The private key for the account that executes and pays for transactions. **Never commit a real key to version control.** Set this in your `.env` file. |
| `RPC_URL_<CHAIN_ID>` | **Required.** RPC endpoints for supported blockchains. Set these in your `.env` file. |
| `ZERODEV_API_KEY` | **Required.** API key for ZeroDev for sponsoring transactions. Set this in your `.env` file. |
| `IPFS_SERVICE_URL` | **Required.** The URL for the IPFS service used to store and retrieve workflow data. |
| `MAX_WORKERS` | The maximum number of concurrent workers for processing jobs. |
| `RUNNER_NODE_SLEEP` | The sleep interval in seconds for the main runner loop. |
| `FULL_NODE` | A boolean flag (`true`/`false`) to determine if the node should run in "full" mode. |
| `MAX_MISSING_NEXT_SIM_LIMIT` | The threshold for how many consecutive times a workflow simulation can be missed before it's flagged. |
| `MAX_BLOCK_RANGE_<CHAIN_ID>` | The maximum number of blocks to scan at once on a given network, e.g., `MAX_BLOCK_RANGE_11155111` for Sepolia. |
| `IS_PROD` | A boolean flag (`true`/`false`) to indicate if the environment is production. |
| `LOG_LEVEL` | The verbosity of the application logs (e.g., `info`, `debug`, `error`). |
| `LOG_PRETTY` | A boolean flag (`true`/`false`) to enable human-readable, colorized log output. |

### `indexer` Service

This service listens for on-chain events and indexes them for fast querying.

| Variable | Description |
| --- | --- |
| `MONGO_URI` | **Required.** The connection string for the MongoDB instance. |
| `DB_NAME` | **Required.** The name of the database the indexer will use. |
| `META_FILLER_SLEEP` | The sleep interval in seconds for the metadata filler worker. |
| `IPFS_CONNECTOR_ENDPOINT` | **Required.** The IPFS endpoint used to fetch metadata for indexed items. |
| `RPC_URL_<CHAIN_ID>` | **Required.** RPC endpoints for the supported blockchains, used for fetching on-chain data. Set this in your `.env` file. |

## Usage

The `Makefile` provides convenient commands for managing the application stack:

-   `make up`: Starts all services. It also runs the initial setup on the first run.
-   `make down`: Stops and removes all running containers.
-   `make logs`: Tails the logs from all running services. Use `Ctrl+C` to exit.

## Troubleshooting

Here are some common issues and how to resolve them:

-   **Containers fail to start:**
    -   Ensure the Docker daemon is running.
    -   Check if any other service on your machine is using port `27017`, which is required by MongoDB.
    -   Run `make down` and then `make up` to try a fresh start.

-   **Errors related to RPC or IPFS in logs:**
    -   The public RPC and IPFS endpoints may be rate-limited or unavailable.
    -   **Solution:** Ensure the `RPC_URL_<CHAIN_ID>` and `ZERODEV_API_KEY` values in your `.env` file (or `docker-compose.yml`) are correct and working.

-   **`mongo-init` service fails:**
    -   The `mongo-init` service is responsible for initializing the MongoDB replica set. It can sometimes fail due to timing issues.
    -   **Solution:** Running `make down && make up` usually resolves this.
