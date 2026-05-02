= #!/usr/bin/env bash
set -euo pipefail

# server-stats.sh
# Coleta estatísticas básicas de desempenho do servidor Linux.

if ! command -v awk >/dev/null 2>&1; then
  echo "Erro: 'awk' não encontrado."
  exit 1
fi

hr() { printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'; }

title() {
  hr
  echo "$1"
  hr
}

bytes_to_human() {
  # Converte KiB (como o free reporta) para algo legível
  # Entrada: KiB
  awk -v kib="$1" 'BEGIN{
    b=kib*1024;
    split("B KB MB GB TB PB",u," ");
    i=1;
    while(b>=1024 && i<6){b/=1024;i++}
    printf "%.2f %s", b, u[i]
  }'
}

# --- CPU ---
get_cpu_usage_percent() {
  # Pega a linha "%Cpu(s)" do top e calcula 100 - idle
  # Suporta variações: "id," ou "id"
  top -bn1 2>/dev/null \
    | awk '
      /%Cpu\(s\):/ {
        # Exemplo: "%Cpu(s):  2.0 us,  1.0 sy, ... 96.0 id, ..."
        for (i=1; i<=NF; i++) {
          if ($i ~ /id,?$/) { idle=$(i-1) }
        }
        if (idle == "") exit 1
        cpu=100-idle
        printf "%.1f", cpu
        exit
      }
    '
}

# --- Memória ---
get_mem_stats() {
  # free em MiB (compatível)
  # total used free shared buff/cache available
  free -m | awk '
    /^Mem:/ {
      total=$2; used=$3; free=$4; avail=$7;
      usedpct=(used/total)*100;
      freepct=(free/total)*100;
      printf "%s %s %s %s %.1f %.1f",
        total, used, free, avail, usedpct, freepct
    }
  '
}

# --- Disco ---
get_disk_stats_root() {
  # df com POSIX-ish: -P
  # Filesystem Size Used Avail Use% Mounted on
  df -P -h / | awk 'NR==2 {printf "%s %s %s %s %s", $2,$3,$4,$5,$6}'
}

# --- Top processos ---
top_cpu_processes() {
  # user pid %cpu %mem command
  ps -eo user:20,pid,%cpu,%mem,comm --sort=-%cpu | head -n 6
}

top_mem_processes() {
  ps -eo user:20,pid,%cpu,%mem,comm --sort=-%mem | head -n 6
}

# --- Extras (objetivo adicional) ---
os_info() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "${PRETTY_NAME:-$NAME}"
  else
    uname -a
  fi
}

uptime_info() {
  uptime -p 2>/dev/null || uptime
}

load_avg() {
  awk '{print $1" "$2" "$3}' /proc/loadavg
}

logged_users() {
  who | awk '{print $1}' | sort | uniq -c | sort -nr
}

failed_logins() {
  # Dependendo da distro, o arquivo pode variar.
  # Debian/Ubuntu: /var/log/auth.log
  # RHEL/CentOS: /var/log/secure
  local file=""
  if [ -f /var/log/auth.log ]; then file="/var/log/auth.log"; fi
  if [ -f /var/log/secure ]; then file="/var/log/secure"; fi

  if [ -n "$file" ] && command -v sudo >/dev/null 2>&1; then
    # Tenta ler sem estourar permissão (muitos logs exigem root)
    # Se não tiver permissão, vai avisar.
    if sudo -n true 2>/dev/null; then
      sudo grep -i "failed password" "$file" | tail -n 10 || true
    else
      echo "Sem sudo sem senha configurado; rode: sudo $0 (opcional) para ver tentativas falhas."
    fi
  else
    echo "Log de autenticação não encontrado (auth.log/secure) ou sudo ausente."
  fi
}

main() {
  title "SERVER STATS"
  echo "Host: $(hostname)"
  echo "OS: $(os_info)"
  echo "Uptime: $(uptime_info)"
  echo "Load avg (1m 5m 15m): $(load_avg)"
  echo "Data/Hora: $(date -Is)"

  title "CPU"
  cpu="$(get_cpu_usage_percent || true)"
  if [ -n "${cpu:-}" ]; then
    echo "Uso total de CPU: ${cpu}%"
  else
    echo "Não foi possível calcular CPU via 'top'."
  fi

  title "MEMÓRIA"
  read -r total used free avail usedpct freepct <<<"$(get_mem_stats)"
  echo "Total: ${total} MiB"
  echo "Usado: ${used} MiB (${usedpct}%)"
  echo "Livre: ${free} MiB (${freepct}%)"
  echo "Disponível (available): ${avail} MiB"

  title "DISCO (/)"
  read -r size usedd availd usepct mount <<<"$(get_disk_stats_root)"
  echo "Mount: ${mount}"
  echo "Total: ${size}"
  echo "Usado: ${usedd} (${usepct})"
  echo "Livre: ${availd}"

  title "TOP 5 PROCESSOS (CPU)"
  top_cpu_processes

  title "TOP 5 PROCESSOS (MEMÓRIA)"
  top_mem_processes

  title "USUÁRIOS LOGADOS (contagem por usuário)"
  logged_users || true

  title "ÚLTIMAS TENTATIVAS DE LOGIN FALHADAS (se disponível)"
  failed_logins

  hr
}

main "$@"
