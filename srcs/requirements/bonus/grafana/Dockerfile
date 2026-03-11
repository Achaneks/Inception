FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    apt-transport-https \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add Grafana's official APT repository and install
RUN wget -q -O /usr/share/keyrings/grafana.key \
        https://apt.grafana.com/gpg.key && \
    echo "deb [signed-by=/usr/share/keyrings/grafana.key] \
        https://apt.grafana.com stable main" \
        > /etc/apt/sources.list.d/grafana.list && \
    apt-get update && \
    apt-get install -y grafana && \
    rm -rf /var/lib/apt/lists/*

COPY conf/grafana.ini /etc/grafana/grafana.ini
COPY tools/setup_grafana.sh /setup_grafana.sh
RUN chmod +x /setup_grafana.sh

EXPOSE 3000

ENTRYPOINT ["/setup_grafana.sh"]
