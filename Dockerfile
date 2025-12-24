# Combined Arms Dedicated Server
# Multi-stage build for OpenRA Combined Arms mod
#
# Build with specific version:
#   docker build --build-arg CA_VERSION=1.08 -t camod-server .
#
# Build from a different fork:
#   docker build --build-arg CA_REPO=darkademic/CAmod --build-arg CA_VERSION=1.08-DevTest-51 -t camod-server .
#
# Default lobby options:
#   Edit server-overrides.yaml, then restart (or rebuild to bake in)
#
# Run:
#   docker run -d -p 1234:1234/tcp -p 1234:1234/udp -e Name="My Server" camod-server

# =============================================================================
# BUILD STAGE
# =============================================================================
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

# Build arguments for the mod repository and version
ARG CA_REPO=Inq8/CAmod
ARG CA_VERSION=1.08

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    make \
    curl \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Clone the repository at the specified version
RUN git clone --branch ${CA_VERSION} --depth 1 https://github.com/${CA_REPO}.git .

# Build the engine and mod (this fetches the engine first)
RUN make all

# Set the version string in mod.yaml AFTER engine is fetched
RUN make version VERSION=${CA_VERSION}

# Copy server overrides (sets default lobby options like queue type)
COPY server-overrides.yaml /src/mods/ca/rules/server-overrides.yaml

# Register server-overrides.yaml at END of Rules section (must load last to override defaults)
RUN sed -i '/^Sequences:/i\	ca|rules/server-overrides.yaml' /src/mods/ca/mod.content.yaml

# =============================================================================
# RUNTIME STAGE
# =============================================================================
FROM mcr.microsoft.com/dotnet/runtime:6.0 AS runtime

# Install python3 (required by launch-dedicated.sh for path resolution)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the entire built project structure
COPY --from=build /src/engine ./engine
COPY --from=build /src/mods ./mods
COPY --from=build /src/mod.config ./mod.config
COPY --from=build /src/launch-dedicated.sh ./launch-dedicated.sh
COPY --from=build /src/IP2LOCATION-LITE-DB1.IPV6.BIN.ZIP ./IP2LOCATION-LITE-DB1.IPV6.BIN.ZIP

# Make script executable
RUN chmod +x ./launch-dedicated.sh

# Server configuration environment variables with defaults
# (These are read by launch-dedicated.sh)
ENV Name="Dedicated Server"
ENV ListenPort=1234
ENV AdvertiseOnline=True
ENV Password=""
ENV RecordReplays=False
ENV RequireAuthentication=False
ENV ProfileIDBlacklist=""
ENV ProfileIDWhitelist=""
ENV EnableSingleplayer=False
ENV EnableSyncReports=False
ENV EnableGeoIP=True
ENV ShareAnonymizedIPs=True
ENV FloodLimitJoinCooldown=5000
ENV QueryMapRepository=True
ENV Map=""
ENV SupportDir=""

# Expose the server port (TCP and UDP)
EXPOSE 1234/tcp
EXPOSE 1234/udp

# Run the dedicated server using the official script
ENTRYPOINT ["./launch-dedicated.sh"]
