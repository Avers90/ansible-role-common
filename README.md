# ansible-role-common

Common system configuration: hostname, timezone, locale, profile.d scripts, PAM.

## Requirements

- Debian (bullseye, bookworm), Ubuntu (focal, jammy, noble, resolute)
- Collections: `ansible.posix`, `community.general`

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `common_hostname` | `{{ inventory_hostname }}` | System hostname |
| `common_timezone` | `Europe/Moscow` | Timezone |
| `common_locale` | `en_US.UTF-8` | System locale |
| `common_profile_d` | `true` | Deploy custom profile.d scripts |
| `common_pam_sshd` | `true` | Deploy custom PAM sshd config |
| `common_hosts_entries` | `[]` | Additional /etc/hosts entries |
| `common_modules_load` | `[]` | Kernel modules to load and persist in `/etc/modules-load.d/` |
| `common_sysctl` | `{}` | Sysctl kernel parameters |

## Examples

### Basic usage

```yaml
common_hostname: wg-pl-01
common_timezone: Europe/Warsaw
```

### With custom hosts

```yaml
common_hosts_entries:
  - ip: 192.168.1.10
    hostname: db-server
    aliases:
      - db
      - database
```

### With sysctl

```yaml
common_sysctl:
  net.ipv4.ip_forward: 1
  vm.swappiness: 10
```

**Important:** `common_sysctl` is a dict. Ansible does **not merge dicts** across
`group_vars` — a more specific group overrides less specific ones entirely.
If you define `common_sysctl` in both `group_vars/all/` and `group_vars/component_vless/`,
only the latter takes effect. Duplicate any shared parameters in every group that needs them.

### Kernel modules

Some sysctl keys are owned by a kernel module and only exist once that module is
loaded. `net.netfilter.nf_conntrack_*` is the common case: `nf_conntrack` is
normally pulled in implicitly by iptables, which runs **after**
`systemd-sysctl.service`. As a result those values are silently dropped on every
boot and revert to kernel defaults.

`common_modules_load` fixes the ordering — modules are written to
`/etc/modules-load.d/`, and `systemd-modules-load.service` is ordered before
`systemd-sysctl.service`:

```yaml
common_modules_load:
  - nf_conntrack

common_sysctl:
  net.netfilter.nf_conntrack_max: 131072
```

The task also loads the module immediately, so the first run does not fail on
`sysctl -p` with an unknown key.

### VPN host sysctl (recommended for WireGuard/AmneziaWG and VLESS hosts)

```yaml
common_modules_load:
  - nf_conntrack

common_sysctl:
  ## --- Server's own TCP only ---
  ## These affect connections terminated by the host (SSH, apt, DoH, Xray).
  ## Tunneled client TCP is end-to-end and never sees the server's congestion
  ## control — do not expect them to raise VPN throughput.
  net.ipv4.tcp_congestion_control: bbr
  net.core.default_qdisc: fq_codel      # AQM against bufferbloat on the WAN NIC
  net.ipv4.tcp_slow_start_after_idle: 0 # no cwnd reset on idle
  net.ipv4.tcp_mtu_probing: 1           # survive PMTUD blackholes
  net.ipv4.tcp_rmem: "4096 87380 16777216"  # autotune ceiling, allocated on demand
  net.ipv4.tcp_wmem: "4096 65536 16777216"
  # Limit unsent data in the kernel send buffer — key fix for bufferbloat during
  # large uploads through the tunnel (ping stops spiking 50ms → 1000ms)
  net.ipv4.tcp_notsent_lowat: 131072

  ## --- Forwarding / NAT (WireGuard, AmneziaWG) ---
  net.ipv4.ip_forward: 1

  ## --- UDP socket buffers ---
  ## The WireGuard/AmneziaWG kernel module creates its UDP socket in-kernel and
  ## never calls setsockopt(SO_RCVBUF), so rmem_max does NOT apply to it —
  ## rmem_default does. This is the knob that actually sizes the tunnel socket.
  net.core.rmem_default: 1048576
  net.core.wmem_default: 1048576
  net.core.rmem_max: 16777216           # ceiling for sockets that do setsockopt
  net.core.wmem_max: 16777216
  net.ipv4.udp_rmem_min: 16384
  net.ipv4.udp_wmem_min: 16384

  ## --- RX path ---
  ## Raise when /proc/net/softnet_stat shows a growing time_squeeze (column 3):
  ## NAPI is running out of budget before draining the ring.
  net.core.netdev_max_backlog: 16384
  net.core.netdev_budget: 1000
  net.core.netdev_budget_usecs: 5000

  ## --- conntrack (needs nf_conntrack in common_modules_load) ---
  ## All peers share a single MASQUERADE, so the table is the real limit.
  ## Slab entry is 256 B — 131072 entries is ~33 MB.
  net.netfilter.nf_conntrack_max: 131072
  ## Default 432000 (5 days) suits a firewall, not a NAT gateway: dead entries
  ## hold both a conntrack slot and a NAT source port.
  net.netfilter.nf_conntrack_tcp_timeout_established: 86400
  net.netfilter.nf_conntrack_tcp_timeout_close_wait: 30
  net.netfilter.nf_conntrack_tcp_timeout_fin_wait: 30
  net.netfilter.nf_conntrack_tcp_timeout_time_wait: 30
  net.netfilter.nf_conntrack_generic_timeout: 120
  net.netfilter.nf_conntrack_icmp_timeout: 15

  ## --- NAT source port pool ---
  ## Check for fixed listeners in the widened range first (`ss -tulnp`).
  net.ipv4.ip_local_port_range: "16384 65000"

  ## --- Memory ---
  vm.swappiness: 10
  vm.vfs_cache_pressure: 50
```

**Do not set `vm.min_free_kbytes`** — the kernel already derives it from total
RAM (`4 * sqrt(lowmem_kb * 16)`). A hardcoded value silently becomes wrong on
hosts with a different memory size.

Size RAM-dependent values from facts instead of hardcoding them, for example:

```yaml
# conntrack table at ~1.6% of RAM (slab entry is 256 B)
sysctl_mem_mb: "{{ ansible_facts['memtotal_mb'] | default(2048) | int }}"
sysctl_conntrack_max: >-
  {{ [[ sysctl_mem_mb | int * 64, 65536 ] | max, 1048576 ] | min }}
```

### Disable profile.d deployment

```yaml
common_profile_d: false
common_pam_sshd: false
```

## Included files

### profile.d scripts

- `00-bash-options.sh` - Bash options
- `10-aliases.sh` - Common aliases
- `20-functions.sh` - Helper functions
- `30-prompt.sh` - Custom prompt
- `40-history.sh` - History settings
- `50-colors.sh` - Colors
- `60-path.sh` - PATH configuration
- `70-git-integration.sh` - Git integration
- `80-system-specific.sh` - System specific settings
- `81-system-info.sh` - System info on login
- `90-security.sh` - Security settings

### PAM

- `pam.d/sshd` - Custom PAM config (disables MOTD)

## License

MIT
