FROM jboss/wildfly:11.0.0.Final

# Add admin user
RUN /opt/jboss/wildfly/bin/add-user.sh admin admin --silent

USER root
ADD config /opt/config
RUN mkdir /opt/jdbc
ADD postgres-module.xml /opt/jdbc/postgres-module.xml

# Download postgresql.jar driver. Base OS is CentOS so we use yum
RUN yum install -y wget
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.2.jar -O /opt/jdbc/postgresql.jar
RUN cd /opt/jboss/wildfly \
	&& wget https://downloads.jboss.org/keycloak/4.0.0.Final/adapters/keycloak-oidc/keycloak-wildfly-adapter-dist-4.0.0.Final.tar.gz -O keycloak-adapter.tar.gz \
	&& tar -zxvf keycloak-adapter.tar.gz \
	&& ./bin/jboss-cli.sh --file=bin/adapter-elytron-install-offline.cli

# Add postgres datasource
RUN chmod +x /opt/config/execute.sh
RUN /opt/config/execute.sh add-postgres-datasource.cli

# cleanup
RUN rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
