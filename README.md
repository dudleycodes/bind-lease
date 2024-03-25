# Bind-Lease

A docker image for running a DHCP and DNS server. Only supports IPv4.

## Contents

Components are primarily open-source projects by [Internet Systems Consortium (ISC)](https://www.isc.org/):

* [BIND 9 - Versatile, classic, complete name server software](https://www.isc.org/bind/)
* [Kea DHCP - Modern, open source DHCPv4 & DHCPv6 server](https://www.isc.org/kea/)
* [STORK Agent](https://stork.isc.org/)

## Motivation

I wanted to run DHCP and DNS servers on my home network, in Docker containers, with the ability to export Prometheus
metrics. After surveying the available servers I decided on *BIND9* and *Kea* by the ISC. Normally, I dislike running
multiple services in a single container, but given the integrations between the two, I made the decision to host them
in a single container.

## Usage
