ARG KEYCLOAK_VERSION=26.8.0

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak

# Base build
RUN /opt/keycloak/bin/kc.sh build

# Disable default features we don't need.
RUN /opt/keycloak/bin/kc.sh build --features-disabled="ciba,client-auth-federated,identity-brokering-api,kerberos,kubernetes-service-accounts,opentelemetry,organization,step-up-authentication-saml,twitter-broker"


FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Set our manifiesta theme
COPY themes/manifiesta /opt/keycloak/themes/manifiesta
ENV KC_THEME=manifiesta 

ENV KC_DB=postgres
ENV KC_DB_URL=jdbc:postgresql://localhost:5432/keycloak
ENV KC_DB_USERNAME=keycloak
ENV KC_DB_PASSWORD=[REPLACE-ME]
ENV KC_HOSTNAME=[REPLACE-ME]
ENV KC_PROXY_HEADERS=xforwarded
ENV KC_HTTP_ENABLED=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
