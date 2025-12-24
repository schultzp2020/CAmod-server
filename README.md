# Combined Arms Dedicated Server

This guide explains how to run a Combined Arms (CAmod) dedicated server.

## Table of Contents

- [Combined Arms Dedicated Server](#combined-arms-dedicated-server)
  - [Table of Contents](#table-of-contents)
  - [Using Podman/Docker](#using-podmandocker)
    - [Quick Start](#quick-start)
    - [Building a Specific Version](#building-a-specific-version)
    - [Building from a Fork](#building-from-a-fork)
    - [Configuration](#configuration)
    - [Managing the Server](#managing-the-server)
    - [Port Forwarding](#port-forwarding)
  - [Without Podman/Docker](#without-podmandocker)
    - [Prerequisites](#prerequisites)
    - [Building from Source](#building-from-source)
    - [Running the Server](#running-the-server)
    - [Configuration Options](#configuration-options)
    - [Available Options](#available-options)
  - [Troubleshooting](#troubleshooting)
    - [Server not visible online](#server-not-visible-online)
    - [Version mismatch errors](#version-mismatch-errors)
    - [Windows: "find: No such file or directory"](#windows-find-no-such-file-or-directory)
  - [Links](#links)

---

## Using Podman/Docker

The containerized approach is the easiest way to run a dedicated server. It handles all dependencies and version management automatically.

### Quick Start

```bash
cd CAmod

# Copy the example configuration
cp .env.example .env

# Edit .env with your settings (server name, password, etc.)
nano .env

# Start the server
podman compose up -d

# View logs
podman compose logs -f

# Stop the server
podman compose down
```

### Building a Specific Version

To run a specific version of Combined Arms, set the `CA_VERSION` variable to any [git tag or branch](https://github.com/Inq8/CAmod/tags):

```bash
# Edit .env and change CA_VERSION, then rebuild
podman compose up -d --build

# Or build manually
podman build --build-arg CA_VERSION=1.07.1 -t camod-server:1.07.1 .
podman run -d -p 1234:1234/tcp -p 1234:1234/udp camod-server:1.07.1
```

### Building from a Fork

To build from a different fork (e.g., for dev/test releases), set the `CA_REPO` variable:

```bash
# Edit .env to use a different fork
CA_REPO=darkademic/CAmod
CA_VERSION=1.08-DevTest-51

# Then rebuild
podman compose up -d --build
```

Available forks:
- `Inq8/CAmod` - Official releases (default)
- `darkademic/CAmod` - Dev/test builds

### Configuration

All server settings are configured via environment variables in `.env`:

| Variable | Default | Description |
|----------|---------|-------------|
| `CA_REPO` | `Inq8/CAmod` | GitHub repository to build from |
| `CA_VERSION` | `1.08` | Git tag/branch to build |
| `Name` | `Combined Arms Server` | Server name shown in lobby |
| `ListenPort` | `1234` | Port for TCP and UDP |
| `AdvertiseOnline` | `True` | Show in master server list |
| `Password` | *(empty)* | Server password |
| `EnableSingleplayer` | `False` | Allow singleplayer mode |
| `RequireAuthentication` | `False` | Require OpenRA account |
| `RecordReplays` | `False` | Save game replays |
| `EnableGeoIP` | `True` | Show player locations |
| `QueryMapRepository` | `True` | Download missing maps |
| `ProfileIDBlacklist` | *(empty)* | Comma-separated banned IDs |
| `ProfileIDWhitelist` | *(empty)* | Comma-separated allowed IDs |

### Managing the Server

```bash
# Start in background
podman compose up -d

# View live logs
podman compose logs -f

# Restart
podman compose restart

# Stop
podman compose down

# Rebuild after changing CA_VERSION
podman compose up -d --build

# Check status
podman ps
```

### Port Forwarding

For players to connect from the internet, you must forward port **1234** (or your custom port) for both **TCP and UDP** on your router.

---

## Without Podman/Docker

You can run the server directly on Windows, Linux, or macOS without containers.

### Prerequisites

- **.NET 6.0 SDK** - [Download](https://dotnet.microsoft.com/download/dotnet/6.0)
- **Git** - [Download](https://git-scm.com/downloads)
- **Python 3** - [Download](https://www.python.org/downloads/)

**Linux additional packages:**

```bash
sudo apt install git python3 make curl unzip
```

### Building from Source

```bash
# Clone the repository
git clone https://github.com/Inq8/CAmod.git
cd CAmod

# Checkout a specific version (optional)
git checkout 1.08

# Build everything (fetches engine automatically)
# Linux/macOS:
make all
make version VERSION=1.08

# Windows (PowerShell):
.\make.cmd all
.\make.cmd version 1.08
```

### Running the Server

**Linux/macOS:**

```bash
./launch-dedicated.sh
```

**Windows (use native Command Prompt, not Git Bash):**

```cmd
launch-dedicated.cmd
```

> **Note for Git Bash users:** The Windows `.cmd` scripts may not work correctly from Git Bash due to conflicts between Windows `find` and Unix `find`. Use PowerShell or Command Prompt instead.

### Configuration Options

You can configure the server by setting environment variables before running:

**Linux/macOS:**

```bash
Name="My Server" ListenPort=1234 Password="secret" ./launch-dedicated.sh
```

**Windows (Command Prompt):**
Edit `launch-dedicated.cmd` directly to change the `set` statements at the top:

```cmd
set Name="My Server"
set ListenPort=1234
set Password="secret"
```

**Windows (PowerShell):**

```powershell
$env:Name = "My Server"
$env:ListenPort = 1234
.\launch-dedicated.cmd
```

### Available Options

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `Name` | `Dedicated Server` | Server name |
| `ListenPort` | `1234` | Server port |
| `AdvertiseOnline` | `True` | Advertise to master server |
| `Password` | *(empty)* | Server password |
| `Map` | *(empty)* | Default map (random if empty) |
| `RecordReplays` | `False` | Record game replays |
| `RequireAuthentication` | `False` | Require OpenRA login |
| `EnableSingleplayer` | `False` | Allow singleplayer |
| `EnableGeoIP` | `True` | GeoIP for player locations |
| `EnableSyncReports` | `False` | Sync reports for debugging |
| `FloodLimitJoinCooldown` | `5000` | Anti-flood cooldown (ms) |
| `QueryMapRepository` | `True` | Auto-download maps |
| `ProfileIDBlacklist` | *(empty)* | Banned profile IDs |
| `ProfileIDWhitelist` | *(empty)* | Allowed profile IDs |

---

## Troubleshooting

### Server not visible online

1. Ensure port 1234 (TCP + UDP) is forwarded on your router
2. Check your firewall allows the connection
3. Set `AdvertiseOnline=True`

### Version mismatch errors

Clients must run the exact same version as the server. After building, check `mods/ca/mod.yaml` for the `Version:` line and ensure it matches your client.

### Windows: "find: No such file or directory"

This happens when running `.cmd` files from Git Bash. Use PowerShell or Command Prompt instead.

---

## Links

- [Combined Arms on ModDB](https://www.moddb.com/mods/command-conquer-combined-arms)
- [CAmod GitHub Repository](https://github.com/Inq8/CAmod)
- [OpenRA Dedicated Server Wiki](https://github.com/OpenRA/OpenRA/wiki/Dedicated-Server)
