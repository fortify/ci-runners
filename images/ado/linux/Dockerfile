FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl jq git ca-certificates libicu74 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /azp

COPY start.sh /azp/start.sh

RUN chmod +x /azp/start.sh

ENTRYPOINT ["/azp/start.sh"]
