
{config, pkgs, ...}:

{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
  # Disable the NixOS firewall in favor of nftables
  networking.firewall.enable = false;
  networking.nftables = {
    enable = true;
    ruleset = ''
      table inet filter {
        chain input {
          type filter hook input priority 0;
          policy drop;
	  # Allow established and related connections (crucial for normal internet use!)
          ct state { established, related } accept
          
          # Allow loopback traffic
          iifname lo accept
          # Allow ssh from 192.168.0.90/32
          ip saddr 192.168.0.90/32 tcp dport 22 accept
          # Allow ssh from 192.168.0.91/32
          ip saddr 192.168.0.91/32 tcp dport 22 accept

          # Allow portainer for 192.168.0.10/32
          ip saddr 192.168.0.10/32 tcp dport 9001 accept
          # Allow nfs from for 192.168.0.90
          #ip saddr 192.168.0.90/32 tcp dport {111, 2049, 4000, 4001, 4002, 20048} counter log accept
          #ip saddr 192.168.0.90/32 udp dport {111, 2049, 4000, 4001, 4002, 20048} counter log accept
        }

        chain forward {
          type filter hook forward priority 0;
          policy drop;

          # Allow established and related connections for forwarded traffic
          ct state {established, related} accept;

          # Allow traffic from main0 bridge to external interface (for container outbound)
          iifname main0 oifname end0 accept;

          # Allow traffic from external interface (end0) to main0 bridge for the specific port
          # This is the rule that allows the DNAT'd traffic to reach the container
          iifname end0 oifname main0 tcp dport 9001 ip daddr 172.18.0.2 ip saddr 192.168.0.10 accept;

          # Drop all other forwarded traffic by default (policy drop)
        }
        
        chain output {
          type filter hook output priority 0;
          policy accept;
        }
      }

      table inet nat {
        chain prerouting {
          type nat hook prerouting priority 0;
          
          # DNAT rule: Redirect incoming traffic on host's end0:9001
          # from 192.168.0.10 to the container's static IP:port
          # This runs BEFORE the 'forward' filter chain.
          iifname end0 ip saddr 192.168.0.10 tcp dport 9001 dnat to 172.18.0.2:9001;
        }

        chain postrouting {
          type nat hook postrouting priority 100;

          # SNAT/Masquerade rule: Change source IP of outbound traffic from Docker containers
          # to the host's external IP (on end0).
          # This allows containers to access the internet.
          oifname end0 masquerade;
        }
      }
    '';
  };
}
