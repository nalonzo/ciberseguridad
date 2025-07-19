#!/bin/bash

# =============================================
# SCRIPT DE INICIALIZACION PARA KALI LINUX CONTAINER
# =============================================

echo -e "\n\033[1;34m[*] Iniciando Kali Linux Container\033[0m"

# Configurar el prompt para mostrar el nombre del contenedor
echo 'export PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]$ "' >> /home/pentester/.bashrc

# Mostrar información básica
echo -e "\n\033[1;33m[*] Información del sistema:\033[0m"
echo -e "Usuario: \033[1;36mpentester\033[0m"
echo -e "Contraseña: \033[1;36mPasswordSeguro123!\033[0m"
echo -e "Directorio persistente: \033[1;36m/home/pentester/lab_data\033[0m"

# Iniciar shell interactiva
exec /bin/bash -l
