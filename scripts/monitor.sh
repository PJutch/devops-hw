service=$1

systemctl is-active --quiet "$service"

case "$?" in
    0) echo "active" ;;
    3) 
        echo "inactive, showing service logs:" 
        journalctl -u apache2.service -n 10
        
        message_count=$(awk '$1 > strftime("%Y-%m-%dT%H:%M:%S", systime() - 3600)' /var/log/syslog | grep "$service" | wc -l)
        echo "found $message_count relevant messages in /var/log/syslog"
        ;;
    4) 
        echo "service named $service not found"
        exit 1
        ;;
    *) 
        echo "systemctl failed"
        exit 1
        ;;
esac
