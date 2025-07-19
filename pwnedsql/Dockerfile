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
