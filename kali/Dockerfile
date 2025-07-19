FROM kalilinux/kali-rolling

LABEL maintainer="Lab de Pentesting"
LABEL description="Kali Linux seguro para laboratorio"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=America/Mexico_City

RUN echo "Configurando Kali Linux ..." && \
    apt-get update -y && \
    apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends \
    iputils-ping     netcat-traditional \
    nmap \
    metasploit-framework \
    kali-tools-exploitation \
    hydra \
    sqlmap \
    wireshark \
    john \
    git \
    python3-pip \
    python3-dev \
    libffi-dev \
    libssl-dev \
    default-jdk \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar Burp Suite Community
RUN mkdir -p /opt/burpsuite && \
    cd /opt/burpsuite && \
    wget -q "https://portswigger.net/burp/releases/download?product=community&version=latest&type=Jar" -O burpsuite.jar && \
    echo '#!/bin/sh\njava -jar /opt/burpsuite/burpsuite.jar' > /usr/local/bin/burpsuite && \
    chmod +x /usr/local/bin/burpsuite

RUN useradd -m -s /bin/bash pentester && \
    echo 'pentester:PasswordSeguro123!' | chpasswd && \
    chmod 700 /home/pentester && \
    mkdir -p /home/pentester/lab_data && \
    chown pentester:pentester /home/pentester/lab_data

WORKDIR /home/pentester
USER pentester

CMD ["/bin/bash", "-l"]
