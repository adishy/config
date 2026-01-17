Network Setup: Tailscale + Caddy

This setup provides secure, remote access to internal services using Tailscale for the network layer and Caddy for request routing, utilizing a custom domain without complex SSL challenges.
General Architecture

    Tailscale: Creates a private mesh network. The host (crt) is identified by its Tailscale IP (100.89.59.97).

    Public DNS: An A Record for jellyfin.adishy.com points to the private Tailscale IP. This ensures the name resolves only for devices authenticated to your Tailnet.

    Caddy: Runs in a Docker container, listening on port 80. It acts as the "Traffic Controller," directing incoming requests to the correct container based on the hostname.

    Docker Network: A shared internal network (crt_service_intranet) allows Caddy to communicate with services like Jellyfin by their container name.

Request Lifecycle

    Request: A Tailscale-connected device requests http://jellyfin.adishy.com.

    Resolution: DNS resolves the domain to the private IP 100.89.59.97.

    Transport: The request travels through the encrypted Tailscale tunnel to the host.

    Reception: The host passes traffic on Port 80 to the Caddy container.

    Routing: Caddy reads the Host: jellyfin.adishy.com header and proxies the traffic to jellyfin:8096 over the internal Docker network.

    Response: Jellyfin processes the request and sends the data back through Caddy and the tunnel.

How to Extend

To add a new service (e.g., Immich):

    DNS: Add a new A Record (or CNAME) for immich.adishy.com pointing to 100.89.59.97.

    Docker: Ensure the new service container is joined to the crt_service_intranet network in its docker-compose.yml.

    Caddyfile: Update the generate_caddyfile.sh script to include a new block:
    Code snippet

    http://immich.adishy.com {
        reverse_proxy immich-server:2283
    }

    Reload: Run the generation script to update the config and reload Caddy.

Management

    Update Config: Run ./generate_caddyfile.sh.

    Logs: docker logs -f caddy to monitor traffic and troubleshoot.

    Network Check: docker network inspect crt_service_intranet to ensure containers can see each other.
