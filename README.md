# Server Performance Stats

Um script Bash simples e portável para coletar rapidamente estatísticas de desempenho de servidores Linux. Ideal para DevOps, iniciantes, testes e estudos.

---

## ⚡️ Introdução

O `server-stats.sh` analisa e resume as principais informações do seu servidor, incluindo:

- **CPU:** uso total da CPU.
- **Memória:** consumo total, livre, disponível e percentual.
- **Disco:** uso do sistema de arquivos principal (`/`).
- **Top processos:** 5 que mais consomem CPU e 5 por uso de memória.
- **Extras:** versão do sistema operacional, tempo ligado (uptime), média de carga, usuários logados, tentativas de login falhadas (se disponível).

---

## 🛠 Requisitos

O script foi feito para rodar em QUALQUER Linux* com ferramentas básicas já instaladas:

- `bash` (>=4)
- `awk`, `df`, `top`, `ps`, `free`
- `sudo` (opcional, para logs restritos)

*Testado em Ubuntu, Debian, CentOS, Rocky, Fedora...

---

## 🚀 Instalação e Uso

**1. Clone o repositório ou copie o script:**
```bash
git clone https://github.com/DanielMouraoti/server-stats.sh
cd server-stats.sh
```

**2. Torne o script executável:**
```bash
chmod +x server-stats.sh
```

**3. Rode no terminal:**
```bash
./server-stats.sh
```

*_Obs:_* Para detalhes extras (ex: tentativas de login falhadas), rode com `sudo`:
```bash
sudo ./server-stats.sh
```

---

## 🖥 Exemplo de saída

```
----------------------------------------
SERVER STATS
----------------------------------------
Host: meu-servidor
OS: Ubuntu 22.04.1 LTS
Uptime: up 1 hour, 23 minutes
Load avg (1m 5m 15m): 0.09 0.10 0.12
Data/Hora: 2026-05-02T12:34:56-03:00
----------------------------------------
CPU
----------------------------------------
Uso total de CPU: 3.5%
----------------------------------------
MEMÓRIA
----------------------------------------
Total: 2000 MiB
Usado: 800 MiB (40.0%)
Livre: 900 MiB (45.0%)
Disponível (available): 1100 MiB
----------------------------------------
DISCO (/)
----------------------------------------
Mount: /
Total: 50G
Usado: 20G (40%)
Livre: 28G
----------------------------------------
TOP 5 PROCESSOS (CPU)
USER                 PID %CPU %MEM COMMAND
root                  10  2.3  1.1 myapp
...
----------------------------------------
TOP 5 PROCESSOS (MEMÓRIA)
USER                 PID %CPU %MEM COMMAND
...
----------------------------------------
USUÁRIOS LOGADOS (contagem por usuário)
      2 daniel
...
----------------------------------------
ÚLTIMAS TENTATIVAS DE LOGIN FALHADAS (se disponível)
May  2 12:10:45 meu-servidor sshd[12345]: Failed password for root from 1.2.3.4 port 5678 ssh2
...
----------------------------------------
```

---

## 🪄 Como funciona? (para iniciantes!)

- `top -bn1`: tira um “retrato” rápido do uso da CPU.
- `free -m`: mostra RAM total, usada, livre e disponível.
- `df -h /`: verifica o uso do disco raiz (`/`), em formato amigável (GB/MB).
- `ps -eo ... --sort=-%cpu | head -n 6`: lista os 5 processos que mais usam CPU, com nome de usuário e comando.
- `ps -eo ... --sort=-%mem | head -n 6`: similar ao anterior, mas para memória.
- `uname`, `cat /etc/os-release`: identificam o sistema operacional.
- `who`: lista usuários logados.
- Logs do sistema: lê tentativas de login falhadas (se permitido por permissão/sudo).

---

## 🌱 Como estender/personalizar?

Quer mais métricas?  
Basta editar o script e adicionar comandos bash conhecidos no *main()*. Exemplos:

- Temperatura da CPU (se sensor disponível):  
  `sensors | grep 'Core'`
- Conexões de rede ativas:  
  `ss -tulnp` ou `netstat -tunapl`
- Espaço de disco de todos os mounts:
  `df -h`

---

Este projeto é didático e livre!  
Sinta-se à vontade para modificar, aprimorar e compartilhar — e, se tiver dúvidas, abra um Issue ou PR!
