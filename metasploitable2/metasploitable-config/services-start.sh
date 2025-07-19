#!/bin/bash

# Iniciar servicios
service ssh start
service vsftpd start
service apache2 start
service postfix start
service dovecot start
service smbd start
service bind9 start
service mysql start
service postgresql start
service tomcat7 start
service nessusd start
service nfs-kernel-server start

# Mantener el contenedor en ejecución
tail -f /dev/null
