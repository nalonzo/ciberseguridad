
# Basado en Ubuntu 16.04 LTS (Xenial Xerus)
FROM ubuntu:16.04

# Configuración básica
ENV DEBIAN_FRONTEND=noninteractive

# Instalar paquetes necesarios
RUN apt-get update && apt-get install -y     openssh-server     vsftpd     apache2     postfix     dovecot-imapd     samba     bind9     mysql-server-5.7     postgresql     tomcat7     vnc4server     nfs-kernel-server     snmp     telnetd     tftp     php7.0     libapache2-mod-php7.0     && apt-get clean     && rm -rf /var/lib/apt/lists/*

# Crear directorio para configuraciones
RUN mkdir -p /metasploitable-config

# Copiar archivos de configuración
COPY metasploitable-config/ /metasploitable-config/

# Configurar servicios vulnerables
RUN     # SSH con contraseñas débiles     echo 'root:password' | chpasswd &&     echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && 
    # Configuración FTP     mv /metasploitable-config/vsftpd.conf /etc/vsftpd.conf && 
    # Configuración Apache/PHP     mv /metasploitable-config/phpinfo.php /var/www/html/ &&     chmod 755 /var/www/html/phpinfo.php && 
    # Configuración MySQL     service mysql start &&     mysql < /metasploitable-config/mysql-config.sql && 
    # Configuración Postgres     service postgresql start &&     sudo -u postgres psql -f /metasploitable-config/postgres-config.sql && 
    # Permisos inseguros     chmod 777 /tmp &&     chmod -R 777 /var/www && 
    # Limpieza     rm -rf /metasploitable-config

# Exponer puertos
EXPOSE 21 22 23 25 53 80 110 111 139 445 512 513 514 1524 2049 3306 5432 5900 6667

# Script para iniciar servicios
COPY metasploitable-config/services-start.sh /services-start.sh
RUN chmod +x /services-start.sh

# Iniciar servicios
CMD ["/services-start.sh"]

