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

