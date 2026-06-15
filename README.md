# ansible-role-common

Common system configuration: hostname, timezone, locale, profile.d scripts, PAM.

## Requirements

- Debian (bullseye, bookworm), Ubuntu (focal, jammy, noble, resolute)
- Collection: `ansible.posix`

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `common_hostname` | `{{ inventory_hostname }}` | System hostname |
| `common_timezone` | `Europe/Moscow` | Timezone |
| `common_locale` | `en_US.UTF-8` | System locale |
| `common_profile_d` | `true` | Deploy custom profile.d scripts |
| `common_pam_sshd` | `true` | Deploy custom PAM sshd config |
| `common_hosts_entries` | `[]` | Additional /etc/hosts entries |
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

### VPN host sysctl (recommended for WireGuard and VLESS/Marzban hosts)

```yaml
common_sysctl:
  # TCP congestion control — BBR reduces latency under load
  net.ipv4.tcp_congestion_control: bbr
  # Fair queue — prevents large flows from starving small packets (ping, ACK)
  net.core.default_qdisc: fq_codel
  # Do not reset cwnd after idle — avoids slow-start on reconnects
  net.ipv4.tcp_slow_start_after_idle: 0
  # MTU probing — handles PMTUD blackholes common in VPN tunnels
  net.ipv4.tcp_mtu_probing: 1
  # Large socket buffers — BBR needs BDP-sized buffers to reach full throughput
  # at high RTT (e.g. 100Mbit × 50ms RTT = 625KB minimum)
  net.core.rmem_max: 16777216
  net.core.wmem_max: 16777216
  net.ipv4.tcp_rmem: "4096 87380 16777216"
  net.ipv4.tcp_wmem: "4096 65536 16777216"
  # Limit unsent data in kernel send buffer — key fix for bufferbloat during
  # large uploads through VPN (prevents ping from spiking 50ms → 1000ms)
  net.ipv4.tcp_notsent_lowat: 131072

  # WireGuard only — enables NAT packet forwarding between interfaces
  # net.ipv4.ip_forward: 1
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
