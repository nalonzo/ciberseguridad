#!/bin/bash
#Este script se utilizó para crear la estructura básica de carpetas y archivos Dockerfile y docker-compose.yml
#No obstante, ya están definidas en los repositorios, por lo que no es necesaria su ejecución.
exit 0;
# =============================================
# AUTOMATED KALI LAB DEPLOYMENT SCRIPT
# =============================================
# Despliega un entorno Kali Linux modular con:
# - Contenedor Kali seguro
# - DVWA vulnerable
# - Servidor SSH vulnerable
# - Red pentest-net para comunicación

# Configuración
BASE_DIR="$(dirname "$0")"
DATA_DIR="${BASE_DIR}/kali_lab_data"
LOG_FILE="${BASE_DIR}/deployment.log"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para inicializar estructura de directorios
init_directory_structure() {
echo -e "${YELLOW}[*] Verificando estructura de directorios...${NC}"

    # Directorios principales
    local dirs=(
        "${DATA_DIR}"
        "${BASE_DIR}/kali"
        "${BASE_DIR}/dvwa"
        "${BASE_DIR}/metasploitable2"
        "${BASE_DIR}/juiceshop"
        "${BASE_DIR}/webgoat"
        "${BASE_DIR}/pwnedsql"
    )
    # Archivos requeridos
    local files=(
        "${BASE_DIR}/docker-compose.yml"
        "${BASE_DIR}/kali/Dockerfile"
        "${BASE_DIR}/dvwa/Dockerfile"
        "${BASE_DIR}/juiceshop/Dockerfile"
        "${BASE_DIR}/metasploitable2/Dockerfile"
        "${BASE_DIR}/webgoat/Dockerfile"
        "${BASE_DIR}/pwnedsql/Dockerfile"

    )

    # Crear directorios si no existen
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo -e "${GREEN}[+] Directorio creado: $dir${NC}"
        else
            echo -e "${GREEN}[✓] Directorio existente: $dir${NC}"
        fi
    done

    # Verificar archivos esenciales
    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            case "$file" in
                *docker-compose.yml*)
                    create_docker_compose
                    ;;
                *kali/Dockerfile*)
                    create_kali_dockerfile
                    ;;
                *dvwa/Dockerfile*)
                    create_dvwa_dockerfile
                    ;;
                *juiceshop/Dockerfile*)
                    create_juiceshop_dockerfile
                    ;;
                *metasploitable2/Dockerfile*)
                    create_metasploitable_dockerfile
                    ;;
                *webgoat/Dockerfile*)
                    create_webgoat_dockerfile
                    ;;
                *pwnedsql/Dockerfile*)
                    create_pwnedsql_dockerfile
                    ;;
            esac
        else
            echo -e "${GREEN}[✓] Archivo existente: $file${NC}"
        fi
    done

# Verificar archivo start.sh en directorio kali
    if [ ! -f "${BASE_DIR}/kali/start.sh" ]; then
        create_kali_start_script
    else
        echo -e "${GREEN}[✓] Archivo existente: ${BASE_DIR}/kali/start.sh${NC}"
    fi

    # Permisos seguros
    chmod 700 "${DATA_DIR}"
    echo -e "${GREEN}[+] Permisos configurados para ${DATA_DIR}${NC}"
}

# Función para crear docker-compose.yml
create_docker_compose() {
    cat > "${BASE_DIR}/docker-compose.yml" <<EOF
services:
  kali:
    build: ./kali
    container_name: kali_lab
    hostname: kali-lab
    networks:
      pentest-net:
        aliases:
          - kali
    volumes:
      - ./kali_lab_data:/home/pentester/lab_data
    environment:
      - TZ=America/Mexico_City
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4GB
    tty: true
    stdin_open: true
    privileged: true

  dvwa:
    build: ./dvwa
    container_name: dvwa
    networks:
      pentest-net:
        aliases:
          - dvwa
    ports:
      - "8080:80"
    restart: unless-stopped


  juiceshop:
    build: ./juiceshop
    container_name: juiceshop
    networks:
      pentest-net:
        aliases:
          - juiceshop
    ports:
      - "3000:3000"
    volumes:
      - ./juiceshop/config:/juiceshop/config
      - ./juiceshop/data:/juiceshop/data
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  metasploitable2:
    build: ./metasploitable2
    container_name: metasploitable2
    networks:
      pentest-net:
          aliases:
            - metasploitable2
    ports:
      - "221:21"
      - "222:22"
      - "23:23"
      - "880:80"
      - "4445:445"
      - "3308:3306"

  webgoat:
     build: ./webgoat
     container_name: webgoat
     networks:
       pentest-net:
         aliases:
           - webgoat
     ports:
       - "8082:8080"
       - "9090:9090"
     environment:
       - TZ=America/Mexico_City
     restart: unless-stopped

     volumes:
        - webgoat_data:/home/webgoat/.webgoat-8.0.0
        - webwolf_data:/home/webgoat/.webwolf-8.0.0

  pwnedsql:
     build: ./pwnedsql
     container_name: pwnedsql
     networks:
       pentest-net:
         aliases:
           - pwnedsql
     ports:
       - "3307:3306"
     environment:
       - TZ=America/Mexico_City
       - MYSQL_ROOT_PASSWORD=root123
       - MYSQL_DATABASE=vulnerable_db
       - MYSQL_USER=victim_user
       - MYSQL_PASSWORD=weakpassword
     restart: unless-stopped

     volumes:
       - pwnedsql_data:/var/lib/mysql
       - ./pwnedsql/my.cnf:/etc/mysql/conf.d/my.cnf

networks:
  pentest-net:
    driver: bridge
    internal: false

volumes:
  webgoat_data:
    driver: local
  webwolf_data:
    driver: local
  pwnedsql_data:
    driver: local
EOF
    echo -e "${GREEN}[+] Archivo docker-compose.yml creado${NC}"
}

# Funciones para crear Dockerfiles
create_kali_dockerfile() {
    cat > "${BASE_DIR}/kali/Dockerfile" <<EOF
FROM kalilinux/kali-rolling

LABEL maintainer="Lab de Pentesting"
LABEL description="Kali Linux seguro para laboratorio"

ENV DEBIAN_FRONTEND=noninteractive \\
    TZ=America/Mexico_City

RUN echo "Configurando Kali Linux ..." && \\
    apt-get update -y && \\
    apt-get full-upgrade -y && \\
    apt-get install -y --no-install-recommends \\
    iputils-ping \
    netcat-traditional \\
    nmap \\
    metasploit-framework \\
    kali-tools-exploitation \\
    hydra \\
    sqlmap \\
    wireshark \\
    john \\
    git \\
    python3-pip \\
    python3-dev \\
    libffi-dev \\
    libssl-dev \\
    default-jdk \\
    wget \\
    nano \\
    ssh-client \\
    wordlists  \\
    && apt-get clean \\
    && rm -rf /var/lib/apt/lists/*

# Instalar Burp Suite Community
RUN mkdir -p /opt/burpsuite && \\
    cd /opt/burpsuite && \\
    wget -q "https://portswigger.net/burp/releases/download?product=community&version=latest&type=Jar" -O burpsuite.jar && \\
    echo '#!/bin/sh\\njava -jar /opt/burpsuite/burpsuite.jar' > /usr/local/bin/burpsuite && \\
    chmod +x /usr/local/bin/burpsuite

RUN useradd -m -s /bin/bash pentester && \\
    echo 'pentester:PasswordSeguro' | chpasswd && \\
    chmod 700 /home/pentester && \\
    mkdir -p /home/pentester/lab_data && \\
    chown pentester:pentester /home/pentester/lab_data && \\
    echo "mipassword" | passwd --stdin root

WORKDIR /home/pentester
USER pentester

CMD ["/bin/bash", "-l"]
EOF
    echo -e "${GREEN}[+] Dockerfile para Kali creado${NC}"
}

create_kali_start_script() {
    cat > "${BASE_DIR}/kali/start.sh" <<EOF
#!/bin/bash

# =============================================
# START SCRIPT FOR KALI LINUX CONTAINER
# =============================================

echo -e "\n\033[1;34m[*] Iniciando Kali Linux Container\033[0m"

# Configurar el prompt para mostrar el nombre del contenedor
echo 'export PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "' >> /home/pentester/.bashrc

# Mostrar información básica
echo -e "\n\033[1;33m[*] Información del sistema:\033[0m"
echo -e "Usuario: \033[1;36mpentester\033[0m"
echo -e "Contraseña: \033[1;36mPasswordSeguro123!\033[0m"
echo -e "root: \033[1;36mipassword\033[0m"
echo -e "Directorio persistente: \033[1;36m/home/pentester/lab_data\033[0m"

# Iniciar shell interactiva
exec /bin/bash -l
EOF

    chmod +x "${BASE_DIR}/kali/start.sh"
    echo -e "${GREEN}[+] Script start.sh creado en directorio kali${NC}"
}

check_connectivity() {
    echo -e "\n${YELLOW}[*] Verificando conectividad entre contenedores...${NC}"

    local kali_container=$KALI_CONTAINER
    local timeout=20
    local elapsed=0

    # Esperar a que los contenedores estén completamente inicializados
    while [ $elapsed -lt $timeout ]; do
        if docker exec $kali_container ping -c 1 dvwa >/dev/null 2>&1; then
            break
        fi
        sleep 1
        ((elapsed++))
    done

    # Realizar verificaciones
    echo -e "${YELLOW}[*] Probando conectividad:${NC}"

    if docker exec $kali_container ping -c 2 dvwa >/dev/null 2>&1; then
        echo -e "  DVWA: ${GREEN}OK${NC} (responde a ping)"
    else
        echo -e "  DVWA: ${RED}FALLÓ${NC} (no responde)"
    fi

    if docker exec $kali_container nc -zv dvwa 80 >/dev/null 2>&1; then
        echo -e "  Web DVWA: ${GREEN}OK${NC} (puerto 80 accesible)"
    else
        echo -e "  Web DVWA: ${RED}FALLÓ${NC} (puerto 80 no accesible)"
    fi

    if docker exec $kali_container nc -zv sshd 22 >/dev/null 2>&1; then
        echo -e "  SSH: ${GREEN}OK${NC} (puerto 22 accesible)"
    else
        echo -e "  SSH: ${RED}FALLÓ${NC} (puerto 22 no accesible)"
    fi

# Verificación adicional para Juice Shop
    if nc -zv localhost 3000 >/dev/null 2>&1; then
        echo -e "  Juice Shop: ${GREEN}OK${NC} (http://localhost:3000)"
    else
        echo -e "  Juice Shop: ${RED}FALLÓ${NC} (no accesible en puerto 3000)"
    fi

    # Verificación interna desde Kali
    if docker exec $kali_container nc -zv juiceshop 3000 >/dev/null 2>&1; then
        echo -e "  Juice Shop (interno): ${GREEN}OK${NC} (puerto 3000 accesible)"
    else
        echo -e "  Juice Shop (interno): ${RED}FALLÓ${NC} (puerto 3000 no accesible)"
    fi

    # Verificación adicional de servicios expuestos
    echo -e "\n${YELLOW}[*] Verificando servicios expuestos en host:${NC}"

    if nc -zv localhost 8080 >/dev/null 2>&1; then
        echo -e "  DVWA Web: ${GREEN}OK${NC} (http://localhost:8080)"
    else
        echo -e "  DVWA Web: ${RED}FALLÓ${NC} (no accesible en puerto 8080)"
    fi

    if nc -zv localhost 2222 >/dev/null 2>&1; then
        echo -e "  SSH: ${GREEN}OK${NC} (accesible en puerto 2222)"
    else
        echo -e "  SSH: ${RED}FALLÓ${NC} (no accesible en puerto 2222)"
    fi

    if nc -zv localhost 8082 >/dev/null 2>&1; then
        echo -e "  WebGoat: ${GREEN}OK${NC} (http://localhost:8082/WebGoat)"
    else
        echo -e "  WebGoat: ${RED}FALLÓ${NC} (no accesible en puerto 8082)"
    fi

    if nc -zv localhost 9090 >/dev/null 2>&1; then
        echo -e "  WebWolf: ${GREEN}OK${NC} (http://localhost:9090)"
    else
        echo -e "  WebWolf: ${RED}FALLÓ${NC} (no accesible en puerto 9090)"
    fi
    if nc -zv localhost 3307 >/dev/null 2>&1; then
        echo -e "  PwnedSQL: ${GREEN}OK${NC} (mysql://localhost:3307)"
    else
        echo -e "  PwnedSQL: ${RED}FALLÓ${NC} (no accesible en puerto 3307)"
    fi
}

create_dvwa_dockerfile() {
    cat > "${BASE_DIR}/dvwa/Dockerfile" <<EOF
FROM vulnerables/web-dvwa

LABEL maintainer="Lab de Pentesting"
LABEL description="DVWA para laboratorio de pentesting"

EXPOSE 80
EOF
    echo -e "${GREEN}[+] Dockerfile para DVWA creado${NC}"
}

# Función para crear Dockerfile de Juice Shop (Versión Corregida)
create_juiceshop_dockerfile() {
# Crear Dockerfile corregido
    cat > "${BASE_DIR}/juiceshop/Dockerfile" <<'EOF'

FROM bkimminich/juice-shop:v13.3.0

ENV DEBIAN_FRONTEND=noninteractive
LABEL maintainer="Lab de JuiceShop"
LABEL description="juiceShop para laboratorio de pentesting"

EXPOSE 3000
CMD ["npm", "start"]

EOF
    echo -e "${GREEN}[+] Dockerfile de Juice Shop${NC}"
}


create_metasploitable_dockerfile() {
    cat > "${BASE_DIR}/metasploitable2/Dockerfile" <<EOF

# Basado en Ubuntu 16.04 LTS (Xenial Xerus)
FROM ubuntu:16.04

# Configuración básica
ENV DEBIAN_FRONTEND=noninteractive

# Instalar paquetes necesarios
RUN apt-get update && apt-get install -y \
    openssh-server \
    vsftpd \
    apache2 \
    postfix \
    dovecot-imapd \
    samba \
    bind9 \
    mysql-server-5.7 \
    postgresql \
    tomcat7 \
    vnc4server \
    nfs-kernel-server \
    snmp \
    telnetd \
    tftp \
    php7.0 \
    libapache2-mod-php7.0 \
    upx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio para configuraciones
RUN mkdir -p /metasploitable-config

# Copiar archivos de configuración
COPY metasploitable-config/ /metasploitable-config/

# Configurar servicios vulnerables
RUN \
    # SSH con contraseñas débiles \
    echo 'root:password' | chpasswd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \

    # Configuración FTP \
    mv /metasploitable-config/vsftpd.conf /etc/vsftpd.conf && \

    # Configuración Apache/PHP \
    mv /metasploitable-config/phpinfo.php /var/www/html/ && \
    chmod 755 /var/www/html/phpinfo.php && \

    # Configuración MySQL \
    service mysql start && \
    mysql < /metasploitable-config/mysql-config.sql && \

    # Configuración Postgres \
    service postgresql start && \
    sudo -u postgres psql -f /metasploitable-config/postgres-config.sql && \

    # Permisos inseguros \
    chmod 777 /tmp && \
    chmod -R 777 /var/www && \

    # Limpieza \
    rm -rf /metasploitable-config

# Exponer puertos
EXPOSE 21 22 23 25 53 80 110 111 139 445 512 513 514 1524 2049 3306 5432 5900 6667

# Script para iniciar servicios
COPY metasploitable-config/services-start.sh /services-start.sh
RUN chmod +x /services-start.sh

# Iniciar servicios
CMD ["/services-start.sh"]

EOF
    echo -e "${GREEN}[+] Dockerfile para SSH vulnerable creado${NC}"
}

create_webgoat_dockerfile() {
    mkdir -p "${BASE_DIR}/webgoat"

    cat > "${BASE_DIR}/webgoat/Dockerfile" <<'EOF'
FROM webgoat/goatandwolf:latest

LABEL maintainer="Pentest Team"
LABEL description="WebGoat - A deliberately insecure web application"

ENV WEBGOAT_PORT=8080 \
    WEBWOLF_PORT=9090 \
    JAVA_OPTS="-Xmx512m -Dhsqldb.reconfig_logging=false"


# Limpiar y recrear directorios de la base de datos
RUN rm -rf /home/webgoat/.webgoat-* && \
    mkdir -p /home/webgoat/.webgoat-8.0.0 /home/webgoat/.webwolf-8.0.0 && \
    chown -R webgoat:webgoat /home/webgoat

# Asegurar permisos del script de inicio
RUN chmod +x /home/webgoat/start.sh && \
    chown webgoat:webgoat /home/webgoat/start.sh


EXPOSE $WEBGOAT_PORT $WEBWOLF_PORT

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD curl -f http://localhost:$WEBGOAT_PORT/WebGoat/login || exit 1

# Usuario no privilegiado
USER webgoat

WORKDIR /home/webgoat

# Punto de entrada (usando el script oficial)
ENTRYPOINT ["/bin/bash", "-c", "/home/webgoat/start.sh"]

EOF

    echo -e "${GREEN}[+] Dockerfile para WebGoat creado${NC}"
}

create_pwnedsql_dockerfile() {
    mkdir -p "${BASE_DIR}/pwnedsql"

    # Crear Dockerfile
    cat > "${BASE_DIR}/pwnedsql/Dockerfile" <<'EOF'
FROM mysql:5.7.35

LABEL maintainer="Pentest Team"
LABEL description="MySQL Vulnerable para prácticas de inyección SQL"

# Eliminar configuraciones obsoletas
RUN sed -i '/secure-auth/d' /etc/mysql/my.cnf && \
    echo "[mysqld]\ndefault-authentication-plugin = mysql_native_password" >> /etc/mysql/conf.d/auth.cnf

COPY vulnerable-db.sql /docker-entrypoint-initdb.d/
COPY my.cnf /etc/mysql/conf.d/

ENV MYSQL_ROOT_PASSWORD=root123 \
    MYSQL_DATABASE=vulnerable_db \
    MYSQL_USER=victim_user \
    MYSQL_PASSWORD=weakpassword

EXPOSE 3306

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s \
    CMD mysqladmin ping -uroot -proot123 || exit 1
EOF

    # Crear configuración MySQL
    cat > "${BASE_DIR}/pwnedsql/my.cnf" <<'EOF'
[mysqld]
secure-file-priv = ""
local-infile = 1
log_warnings = 2
default-authentication-plugin = mysql_native_password
skip-name-resolve
EOF

    # Crear base de datos vulnerable
    cat > "${BASE_DIR}/pwnedsql/vulnerable-db.sql" <<'EOF'
CREATE DATABASE IF NOT EXISTS vulnerable_db;

USE vulnerable_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    password VARCHAR(50),
    email VARCHAR(100),
    credit_card VARCHAR(20),
    is_admin TINYINT(1)
);

INSERT INTO users VALUES
(1, 'admin', 'supersecret', 'admin@example.com', '4111111111111111', 1),
(2, 'alice', 'alice123', 'alice@example.com', '5555555555554444', 0),
(3, 'bob', 'password', 'bob@example.com', '378282246310005', 0);

DELIMITER //
CREATE PROCEDURE vulnerable_proc(IN userid INT)
BEGIN
    SET @sql = CONCAT('SELECT * FROM users WHERE id = ', userid);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

GRANT ALL PRIVILEGES ON *.* TO 'victim_user'@'%' IDENTIFIED BY 'weakpassword';
FLUSH PRIVILEGES;
EOF

    echo -e "${GREEN}[+] Configuración de PwnedSQL/MySQL creada${NC}"
}

# Función para limpieza
cleanup() {
    echo -e "${YELLOW}[*] Limpiando contenedores existentes...${NC}"
    docker-compose down -v >> "${LOG_FILE}" 2>&1
    docker network rm pentest-net >> "${LOG_FILE}" 2>&1
    echo -e "${GREEN}[+] Limpieza completada${NC}"
}

# Función para verificar dependencias
check_dependencies() {
    local missing=0

    if ! command -v docker &> /dev/null; then
        echo -e "${RED}[!] Docker no está instalado${NC}"
        missing=1
    fi

    if ! command -v wget &> /dev/null; then
        echo -e "${RED}[!] wget no está instalado${NC}"
        missing=1
    fi

    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}[!] docker-compose no está instalado${NC}"
        missing=1
    fi

    if [ $missing -eq 1 ]; then
        echo -e "${YELLOW}Instale las dependencias faltantes y vuelva a intentar${NC}"
        exit 1
    fi

    echo -e "${GREEN}[✓] Todas las dependencias están instaladas${NC}"
}

# Función para mostrar información del despliegue
show_info() {
    echo -e "\n${GREEN}[+] Despliegue completado con éxito!${NC}"
    echo -e "${GREEN}=============================================${NC}"
    echo -e "${GREEN}Contenedores desplegados:${NC}"
    echo -e "Kali Linux: ${GREEN}kali_lab${NC}"
    echo -e "DVWA: ${GREEN}dvwa${NC} (http://localhost:8080)"
    echo -e "Juice Shop: ${GREEN}juiceshop${NC} (http://localhost:3000)"
    echo -e "Metasploitable2: ${GREEN}metasploitable2${NC} (root/password)"
    echo -e "WebGoat: ${GREEN}http://localhost:8082/WebGoat${NC}"
    echo -e "WebWolf: ${GREEN}http://localhost:9090${NC}"
    echo -e "Credenciales: guest/guest o webgoat/webgoat"
    echo -e "PwnedSQL: ${GREEN}mysql://localhost:3307 (root/root123)${NC}"
    echo -e "Base de datos vulnerable: vulnerable_db (victim_user/weakpassword)"

    # Realizar verificaciones de conectividad
#    check_connectivity

    echo -e "\n${GREEN}Conexión a los contenedores:${NC}"
    echo -e "Acceder a Kali: ${GREEN}docker exec -it kali_lab bash${NC}"
    echo -e "\n${GREEN}Credenciales:${NC}"
    echo -e "Kali Linux: pentester/PasswordSeguro123!"
    echo -e "DVWA: admin/password"
    echo -e "juiceSHOP: Usuario: admin@juiceshop.local Contraseña: admin123"
    echo -e "Metasploit: root/password"
    echo -e "${GREEN}=============================================${NC}"
    echo -e "${YELLOW}Detalles completos en: ${LOG_FILE}${NC}"
}

# Función principal
main(){
    echo -e "${GREEN}[*] Iniciando despliegue del laboratorio Kali Linux...${NC}"
    echo "Inicio de despliegue: $(date)" > "${LOG_FILE}"

    # Verificar dependencias
    check_dependencies

    # Inicializar estructura
    init_directory_structure

    # Limpieza inicial
    cleanup

    # Construir e iniciar los contenedores
    echo -e "${YELLOW}[*] Construyendo e iniciando los contenedores...${NC}"
    docker-compose build >> "${LOG_FILE}" 2>&1
    docker-compose up -d >> "${LOG_FILE}" 2>&1
    # Pequeña pausa para permitir que los contenedores se inicien completamente
#    sleep 5

    # Mostrar información
    show_info
}

# Manejo de argumentos
case "$1" in
    --clean)
        cleanup
        exit 0
        ;;
    --init)
        init_directory_structure
        exit 0
        ;;
    *)
        main
        ;;
esac
