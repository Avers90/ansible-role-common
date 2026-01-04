# ansible-role-common

Common system configuration: hostname, timezone, locale, profile.d scripts, PAM.

## Requirements

- Debian/Ubuntu
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
