#!/bin/bash

prefix_output() {
    local prefix="$1"
    shift
    unbuffer "$@" > >(sed "s/^/${prefix}:\t /") 2> >(sed "s/^/${prefix} (err):\t /" >&2) &
    local pid=$!
    wait $pid || { echo "There was an error with $prefix" >&2; exit 1; }
}


###
### BIND9
###
export BIND9_USER="bindlease";

prefix_output "BIND9" /usr/local/bin/docker-entrypoint.sh &


###
### Stork Agent
###

# IP address of the network interface or DNS name which stork-agent should use to receive connections from the server;
# (0.0.0.0 to listen on all interfaces).
export STORK_AGENT_HOST="${STORK_AGENT_HOST:-0.0.0.0}"

# Port number the agent should use to receive connections from the server.
export STORK_AGENT_PORT="${STORK_AGENT_PORT:-8080}"

# Enables Stork functionality only, i.e. disables Prometheus exporters.
export STORK_AGENT_LISTEN_STORK_ONLY="${STORK_AGENT_LISTEN_STORK_ONLY:-false}"

# Enables the Prometheus exporters only, i.e. disables Stork functionality.
export STORK_AGENT_LISTEN_PROMETHEUS_ONLY="${STORK_AGENT_LISTEN_PROMETHEUS_ONLY:-true}"

# Skips TLS certificate verification when stork-agent connects to Kea over TLS and Kea uses self-signed certificates.
export STORK_AGENT_SKIP_TLS_CERT_VERIFICATION="${STORK_AGENT_SKIP_TLS_CERT_VERIFICATION:-false}"

# IP address or hostname the agent should use to receive the connections from Prometheus fetching Kea statistics.
export STORK_AGENT_PROMETHEUS_KEA_EXPORTER_ADDRESS="${STORK_AGENT_PROMETHEUS_KEA_EXPORTER_ADDRESS:-0.0.0.0}"

# Port the agent should use to receive connections from Prometheus when fetching Kea statistics.
export STORK_AGENT_PROMETHEUS_KEA_EXPORTER_PORT="${STORK_AGENT_PROMETHEUS_KEA_EXPORTER_PORT:-9547}"

# How often the agent collects stats from Kea, in seconds.
export STORK_AGENT_PROMETHEUS_KEA_EXPORTER_INTERVAL="${STORK_AGENT_PROMETHEUS_KEA_EXPORTER_INTERVAL:-30}"

# Toggle collecting per subnet stats from Kea. Use to limit the data passed to Prometheus/Grafana in large networks.
export STORK_AGENT_PROMETHEUS_KEA_EXPORTER_PER_SUBNET_STATS="${STORK_AGENT_PROMETHEUS_KEA_EXPORTER_PER_SUBNET_STATS:-true}"

# IP address or hostname the agent should use to receive the connections from Prometheus fetching BIND9 statistics.
export STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_ADDRESS="${STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_ADDRESS:-0.0.0.0}"

# Port the agent should use to receive the connections from Prometheus fetching BIND9 statistics.
export STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_PORT="${STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_PORT:-9119}"

# How frequently the agent collects stats from BIND9, in seconds.
export STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_INTERVAL="${STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_INTERVAL:-30}"

# Enable the Prometheus metrics collector and /metrics HTTP endpoint.
export STORK_SERVER_ENABLE_METRICS="${STORK_SERVER_ENABLE_METRICS:-true}"

prefix_output "STORK" /usr/bin/stork-agent &


###
### Wait for all background processes to finish
###
wait
