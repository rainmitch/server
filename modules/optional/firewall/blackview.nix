
{config, pkgs, ...}:

{
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
          ip saddr 192.168.0.0/24 tcp dport 8102 accept
          ip saddr 192.168.0.90/32 tcp dport 81 accept

          
        }

        chain forward {
          type filter hook forward priority 0;
          policy drop;

          # Allow established and related connections for forwarded traffic
          ct state {established, related} accept;

          # Allow ALL traffic from main0 bridge to tun0 (VPN)
          # This now covers both marked (VPN) and unmarked (local) traffic that needs forwarding.
          # Unmarked traffic will naturally route via the main routing table to ens18,
          # but it still needs to be allowed by the forward chain.
          # Since local access (e.g. 172.18.0.X to 192.168.0.Y) is still a "forwarded" packet,
          # this rule is key.
          iifname main0 oifname tun0 accept; # For VPN-bound traffic
          iifname main0 oifname ens18 accept; # For local network bound traffic
          
          # Allow traffic from vpn to external interface
          iifname tun0 oifname ens18 accept;

          # Allow traffic from external interface (ens18) to main0 bridge for the specific port
          # This is the rule that allows the DNAT'd traffic to reach the container
          iifname ens18 oifname main0 tcp dport 9001 ip daddr 172.18.0.2 ip saddr 192.168.0.10 accept;
          iifname ens18 oifname main0 tcp dport 81 ip daddr 172.18.0.4 ip saddr 192.168.0.90 accept;
          # Allow Wireguard
          iifname ens18 oifname tun0 udp dport 51820 ip saddr 192.145.124.3 accept;
          # Allow web traffic into NPM
          iifname tun0 oifname main0 tcp dport {80, 443} ip daddr 172.18.0.4 accept;
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
          
          # DNAT rule: Redirect incoming traffic on host's ens18:9001
          # from 192.168.0.10 to the container's static IP:port
          # This runs BEFORE the 'forward' filter chain.
          iifname ens18 ip saddr 192.168.0.10 tcp dport 9001 dnat to 172.18.0.2:9001;
          iifname ens18 ip saddr 192.168.0.90 tcp dport 81 dnat to 172.18.0.4:81;
          
          # Allow traffic from VPN into NPM
          iifname tun0 tcp dport {80, 443} dnat ip to 172.18.0.4;
        }

        chain postrouting {
          type nat hook postrouting priority 100;

          # SNAT/Masquerade rule: Change source IP of outbound traffic from Docker containers
          # to the host's external IP (on ens18).
          # This allows containers to access the internet.
          oifname ens18 masquerade;
          oifname tun0 meta mark 0x100 masquerade;
        }
      }
      table inet mangle {
       set local_networks {
          type ipv4_addr;
          flags interval; # Allows specifying ranges like 192.168.0.0/24
          elements = {
              192.168.0.0/24, # Your local network on ens18
              # Add other local networks if you have them, e.g.,
              # 10.0.0.0/8,
              # 172.16.0.0/12,
          }
        }
        chain prerouting {
          type filter hook prerouting priority -150; # Ensure this runs before other rules if needed
          policy accept;

          # Rule 1: Do NOT mark traffic from main0 if its destination is a local network.
          # This rule needs to be evaluated BEFORE the general marking rule.
          iifname main0 ip daddr @local_networks accept; # Policy accept means it falls through this chain without being dropped.

          # Rule 2: Mark ALL other traffic from main0 (172.18.0.0/24)
          # that is NOT destined for a local network.
          iifname main0 ip saddr 172.18.0.0/24 meta mark set 0x100 counter;
          # Mark traffic from the specific Docker container IP
          #iifname main0 ip saddr 172.18.0.4 meta mark set 0x100 counter;
        }
      }
    '';
  };
  systemd.services.docker-vpn-routing = {
    description = "Configure policy routing for Docker container via VPN";
    wantedBy = [ "network-online.target" ];
    after = [ "network-online.target" "docker.service" "nftables.service" ];
    script = ''
      # Add the default route for the specific table
      ${pkgs.iproute2}/bin/ip route add default via 192.145.124.3 dev tun0 table 200
      
      # Add the policy routing rule
      ${pkgs.iproute2}/bin/ip rule add fwmark 0x100 table 200
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; # Keep the rules active even after the script finishes
      User = "root"; # Ensure the script runs as root to manage network rules
      
      # Correct way to define cleanup actions when the service is stopped
      # This maps directly to the ExecStop directive in systemd unit files
      ExecStop = [
        "${pkgs.iproute2}/bin/ip rule del fwmark 0x100 table 200 || true"
        "${pkgs.iproute2}/bin/ip route del default dev tun0 table 200 || true"
      ];
    };
  };
}

