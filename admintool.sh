#!/bin/bash

# Funktion zum Überprüfen eines Dienstes
check_service() {
    service_name=$1
    if systemctl is-active --quiet $service_name; then
        echo "Der Dienst $service_name läuft."
    else
        echo "Der Dienst $service_name läuft nicht."
    fi
}

# Funktion zum Überprüfen des freien Speicherplatzes auf den Festplatten
check_disk_space() {
    echo "Freier Speicherplatz auf den Festplatten:"
    df -h --exclude-type=tmpfs --exclude-type=devtmpfs --exclude-type=squashfs
}

# Funktion zum Durchführen von apt update und apt upgrade
update_upgrade() {
    echo "Führe apt update durch..."
    sudo apt update

    echo "Führe apt upgrade durch..."
    sudo apt upgrade -y
}

# Funktion zum Überprüfen, ob Nginx installiert ist
check_nginx_installed() {
    if dpkg -l | grep -q "nginx"; then
        echo "Nginx ist installiert."
        check_service "nginx"
        check_php_installed "php-fpm"
    else
        echo "Nginx ist nicht installiert."
    fi
}

# Funktion zum Überprüfen, ob Apache installiert ist
check_apache_installed() {
    if dpkg -l | grep -q "apache2"; then
        echo "Apache ist installiert."
        check_service "apache2"
        check_php_installed "php"
    else
        echo "Apache ist nicht installiert."
    fi
}

# Funktion zum Überprüfen, ob PHP installiert ist
check_php_installed() {
    php_package=$1
    if dpkg -l | grep -q "$php_package"; then
        echo "PHP ($php_package) ist installiert."
    else
        echo "PHP ($php_package) ist nicht installiert."
    fi
}

# Funktion zum Überprüfen aller Dienste
check_all_services() {
    echo "Alle Dienste werden überprüft..."
    check_service "ssh"
    check_apache_installed
    check_nginx_installed
    check_service "docker"
}

# Funktion zum Anzeigen der aktiven systemd-Dienste
show_active_systemd_services() {
    echo "Aktive systemd-Dienste:"
    systemctl list-units --type=service --state=active
}

# Funktion zum Anzeigen der inaktiven systemd-Dienste
show_inactive_systemd_services() {
    echo "Inaktive systemd-Dienste:"
    systemctl list-units --type=service --state=inactive
}

# Funktion zum Überprüfen eines Ports für eine VPN-Domäne oder -IP
check_vpn_port() {
    read -p "Geben Sie die VPN-Domäne oder -IP-Adresse ein: " vpn_address
    read -p "Geben Sie den zu überprüfenden Port ein: " port

    echo "Überprüfe den Port $port für die VPN-Adresse $vpn_address..."

    nc -z -v -w 5 $vpn_address $port

    if [ $? -eq 0 ]; then
        echo "Der Port $port auf $vpn_address ist offen."
    else
        echo "Der Port $port auf $vpn_address ist geschlossen."
    fi
}

# Funktion zum Anzeigen der größten Ordner auf allen gemounteten Laufwerken
show_largest_folders() {
    echo "Die größten Ordner auf allen gemounteten Laufwerken sind:"
    sudo du -h --max-depth=1 --one-file-system /
}

# Banner anzeigen
echo "*************************************************"
echo "                   Admin-Tool                    "
echo "*************************************************"

# Hauptmenü
while true; do
    echo "1. Überprüfe SSH-Dienst"
    echo "2. Überprüfe Webserver (Apache oder Nginx)"
    echo "3. Überprüfe Docker-Dienst"
    echo "4. Prüfe freien Speicherplatz auf den Festplatten"
    echo "5. Führe apt update und apt upgrade durch"
    echo "6. Prüfe alle Dienste"
    echo "7. Zeige aktive systemd-Dienste an"
    echo "8. Zeige inaktive systemd-Dienste an"
    echo "9. Überprüfe Port für VPN-Domäne oder -IP"
    echo "10. Zeige größte Ordner auf allen gemounteten Laufwerken an"
    echo "11. Beenden"  # Menüpunkt 11 wurde nicht entfernt

    read -p "Wählen Sie eine Option (1-11): " choice

    case $choice in
        1)
            check_service "ssh"
            ;;
        2)
            check_apache_installed
            check_nginx_installed
            ;;
        3)
            check_service "docker"
            ;;
        4)
            check_disk_space
            ;;
        5)
            update_upgrade
            ;;
        6)
            check_all_services
            ;;
        7)
            show_active_systemd_services
            ;;
        8)
            show_inactive_systemd_services
            ;;
        9)
            check_vpn_port
            ;;
        10)
            show_largest_folders  # Aufruf der neuen Funktion
            ;;
        11)
            echo "Programm wird beendet."
            break
            ;;
        *)
            echo "Ungültige Option. Bitte wählen Sie erneut."
            ;;
    esac

    # Eine Pause für bessere Lesbarkeit hinzufügen
    read -p "Drücken Sie Enter, um fortzufahren..."
    clear  # Löscht den Bildschirm für die nächste Menüanzeige
done

