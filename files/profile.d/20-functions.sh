#!/usr/bin/env bash
## User functions

## Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

## Search in history
hg() {
  history | grep -i "$1"
}

## Find file
ff() {
  find . -type f -iname "*$1*" 2>/dev/null
}

## Find dir
fd() {
  find . -type d -iname "*$1*" 2>/dev/null
}

## Search in files
fg() {
  grep -ri "$1" . --color=auto 2>/dev/null
}

## Extract archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2|*.tbz2) tar xjf "$1" ;;
      *.tar.gz|*.tgz)   tar xzf "$1" ;;
      *.tar.xz)         tar xJf "$1" ;;
      *.tar)            tar xf "$1"  ;;
      *.zip)            unzip "$1"   ;;
      *.rar)            unrar x "$1" ;;
      *.7z)             7z x "$1"    ;;
      *.gz)             gunzip "$1"  ;;
      *.bz2)            bunzip2 "$1" ;;
      *.Z)              uncompress "$1" ;;
      *.deb)            ar x "$1" ;;
      *)                echo "Unknown archive format: $1" ;;
    esac
  else
    echo "File not found: $1"
  fi
}

## Directory sizes
ds() {
  du -h --max-depth=1 "${1:-.}" | sort -h
}

## Create file backup
bak() {
  cp "$1" "$1.bak"
}

## Geolocation of an IP in several geo databases, queried in parallel
## (5 s timeout each). The databases disagree: one IP can be FI in one and
## US in another, and every site uses its own — read the whole table.
## Without arguments: every public IPv4 of the host (primary first), or the
## NAT address from ifconfig.me when the host has none.
##   ipinfo                  # this host
##   ipinfo 1.2.3.4 5.6.7.8  # any IP
##   ipinfo -s [ip]          # raw ipinfo.io JSON only
## Free tiers, manual use only (ip-api.com: 45 requests/min).
## Function bodies stay POSIX-parsable: /etc/profile.d is also sourced by sh.
_ipinfo_query() {
  local f='def row: select((.[0] // "") != "") | map(if . == null or . == "" then "-" else tostring end) | join("|");'
  local cc='{"United States":"US","Finland":"FI","Germany":"DE","Netherlands":"NL","The Netherlands":"NL",
    "United Kingdom":"GB","Estonia":"EE","Sweden":"SE","Russia":"RU","France":"FR","Czechia":"CZ",
    "Czech Republic":"CZ","Serbia":"RS","Spain":"ES","Uzbekistan":"UZ","Kazakhstan":"KZ","Poland":"PL",
    "Lithuania":"LT","Latvia":"LV","Turkey":"TR","Canada":"CA","Switzerland":"CH","Austria":"AT"}'
  case "$1" in
    ipinfo.io)
      curl -s --max-time 5 "https://ipinfo.io/$2/json" \
        | jq -r "$f"'[.country, .city, .org] | row' ;;
    ip-api.com)
      curl -s --max-time 5 "http://ip-api.com/json/$2?fields=countryCode,city,as" \
        | jq -r "$f"'[.countryCode, .city, .as] | row' ;;
    ipapi.is)
      curl -s --max-time 5 "https://api.ipapi.is/?q=$2" \
        | jq -r --argjson m "$cc" "$f"'[($m[.country // ""] // .country), .city, .asn] | row' ;;
    ipwho.is)
      curl -s --max-time 5 "https://ipwho.is/$2" \
        | jq -r "$f"'[.country_code, .city,
            (if .connection.asn then "AS\(.connection.asn) \(.connection.isp // "")" else null end)] | row' ;;
    geojs.io)
      curl -s --max-time 5 "https://get.geojs.io/v1/ip/geo/$2.json" \
        | jq -r "$f"'[.country_code, .city,
            (if .asn then "AS\(.asn) \(.organization_name // "")" else null end)] | row' ;;
  esac
}

ipinfo() {
  if [ "$1" = "-s" ]; then
    curl -s --max-time 5 "https://ipinfo.io/${2:+$2/}json" | jq
    return
  fi

  local svcs="ipinfo.io ip-api.com ipapi.is ipwho.is geojs.io"
  local ips tmp ip svc row label codes total
  ips="$*"
  if [ -z "$ips" ]; then
    ips=$(
      {
        ip -4 route get 1.1.1.1 2>/dev/null | awk -F'src ' 'NR==1{split($2,a," ");print a[1]}'
        ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/");print a[1]}'
      } | grep -Ev '^(10\.|127\.|169\.254\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[01])\.|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.)' \
        | awk 'NF && !seen[$0]++'
    )
    [ -n "$ips" ] || ips=$(curl -s -4 --max-time 5 ifconfig.me)
  fi

  tmp=$(mktemp -d) || return 1
  ## Subshell: no job-control noise from the background requests
  (
    for ip in $ips; do
      for svc in $svcs; do
        _ipinfo_query "$svc" "$ip" >"$tmp/$ip@$svc" 2>/dev/null &
      done
    done
    wait
  )

  for ip in $ips; do
    label=$(ip -4 -o addr show 2>/dev/null | awk -v ip="$ip" '{split($4,a,"/")} a[1]==ip {print $2; exit}')
    echo "$ip${label:+ ($label)}"
    for svc in $svcs; do
      row=$(head -n1 "$tmp/$ip@$svc")
      if [ -n "$row" ]; then
        echo "$row" | awk -F'|' -v s="$svc" '{printf "  %-11s %-3s %-18s %s\n", s, $1, $2, $3}'
      else
        printf '  %-11s %s\n' "$svc" "no answer"
      fi
    done
    codes=$(cat "$tmp/$ip@"* | awk -F'|' 'NF{print $1}')
    total=$(printf '%s\n' "$codes" | grep -c .)
    if [ "$total" -gt 0 ]; then
      printf '%s\n' "$codes" | sort | uniq -c | sort -rn \
        | awk -v t="$total" '{s = s (NR > 1 ? ", " : "") $2 " " $1 "/" t} END {print "  -> " s}'
    fi
  done
  rm -rf "$tmp"
}
