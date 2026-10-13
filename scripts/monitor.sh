set -euo pipefail

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
    exit 1
}

if [[ "$#" -ne 1 ]]; then
    error "Usage: $0 <service>"
fi

service=$1

set +e
systemctl is-active --quiet "$service"
systemctl_rc=$?
set -e

case "$systemctl_rc" in
    0) echo "active" ;;
    3) 
        echo "inactive, showing service logs:" 
        journalctl -u "$service" -n 10 || error "journalctl failed"
        
        message_count=$(awk '$1 > strftime("%Y-%m-%dT%H:%M:%S", systime() - 3600)' /var/log/syslog | grep "$service" | wc -l \
                        || error "reading /var/log/syslog failed")
        echo "found $message_count relevant messages in /var/log/syslog"
        ;;
    4) 
        error "service named $service not found"
        exit 1
        ;;
    *) 
        error "systemctl failed"
        exit 1
        ;;
esac
