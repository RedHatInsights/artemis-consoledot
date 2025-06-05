FROM registry.access.redhat.com/ubi9/ubi:9.6-1747219013 AS build
USER 0
ARG ARTEMIS_VERSION=2.32.0

# Download and extract Artemis
RUN mkdir -p /opt/apache-artemis \
  && curl https://archive.apache.org/dist/activemq/activemq-artemis/${ARTEMIS_VERSION}/apache-artemis-${ARTEMIS_VERSION}-bin.tar.gz -o apache-artemis-bin.tar.gz \
  && tar -xzf apache-artemis-bin.tar.gz -C /opt/apache-artemis \
  && mv /opt/apache-artemis/apache-artemis-2.32.0/* /opt/apache-artemis/

# Runtime
FROM registry.access.redhat.com/ubi9/openjdk-17
COPY --from=build /opt/apache-artemis /opt/apache-artemis
LABEL maintainer="Red Hat, Inc."
LABEL version="ubi9"
USER 0

ENV ARTEMIS_HOME=/opt/apache-artemis
ENV ARTEMIS_RUNTIME=/var/lib/artemis
ENV ARTEMIS_USER=guest
ENV ARTEMIS_PASSWORD=guest

# Install python3
RUN microdnf install -y \
    python3 \
    python3-pip \
    gcc \
    python3-devel

RUN pip3 install python-qpid-proton

WORKDIR ${ARTEMIS_RUNTIME}
RUN chmod -R g+rwX ${ARTEMIS_RUNTIME}

# Create Artemis broker instance
RUN cd /opt/apache-artemis/bin \
  && ./artemis create ${ARTEMIS_RUNTIME} \
    --user ${ARTEMIS_USER} \
    --password ${ARTEMIS_PASSWORD} \
    --allow-anonymous

# Runtime stage - minimal openjdk runtime + python
RUN chmod -R g+rwX ${ARTEMIS_RUNTIME}

# Copy custom files
COPY utils/* ${ARTEMIS_RUNTIME}/utils/

EXPOSE 61616 8161 5672

CMD ["./bin/artemis", "run"]
