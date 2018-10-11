FROM solr:7.5.0

USER root
RUN apt-get update && \
    apt-get install -y dnsutils netcat && \
    rm -rf /var/lib/apt/lists/*

USER solr

RUN mkdir /opt/solr/sharedLib

ADD xml/solr.xml /opt/solr/solr.xml
ADD scripts/start.sh /opt/solr/
#ADD sharedLib/scale-plugin.jar /opt/solr/sharedLib/

CMD ["/opt/solr/start.sh"]
