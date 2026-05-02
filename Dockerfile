FROM ubuntu:20.04 AS builder

RUN apt-get update && \
    apt-get install -y build-essential curl gcc make && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LO https://github.com/polyml/polyml/archive/v5.8.tar.gz && \
    tar xf v5.8.tar.gz && \
    cd polyml-5.8 && ./configure --prefix=/tmp && make && make install


FROM cgr.dev/chainguard/wolfi-base

# Wolfi is glibc-based, so the Poly/ML binary built on Ubuntu 20.04
# above runs without a compat shim. bash for run.sh, jq for JSON
# output, libgcc/libstdc++ for the Poly/ML runtime, coreutils for
# the cat/mkdir helpers run.sh uses.
RUN apk add --no-cache bash coreutils jq libgcc libstdc++

COPY --from=builder /tmp/ /usr/

COPY . /opt/test-runner
WORKDIR /opt/test-runner
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
