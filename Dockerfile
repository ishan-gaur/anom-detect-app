FROM openjdk:8

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y apt-utils
RUN apt-get update && apt-get install -y curl

RUN wget https://archive.apache.org/dist/kafka/1.0.0/kafka_2.11-1.0.0.tgz && \
    tar -xvzf kafka_2.11-1.0.0.tgz && \
    cat kafka_2.11-1.0.0/config/server.properties

RUN wget https://mirrors.sonic.net/apache/spark/spark-2.4.6/spark-2.4.6-bin-hadoop2.7.tgz && \
    tar -xzvf spark-2.4.6-bin-hadoop2.7.tgz

RUN cp spark-2.4.6-bin-hadoop2.7/conf/spark-env.sh.template \
    spark-2.4.6-bin-hadoop2.7/python/spark-env.sh && \
    echo "MASTER=local[2]" >> spark-2.4.6-bin-hadoop2.7/python/spark-env.sh && \
    cat spark-2.4.6-bin-hadoop2.7/python/spark-env.sh

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.3.tar.gz && \
    tar -xvzf elasticsearch-6.2.3.tar.gz

RUN apt-get update && apt-get install -y python2.7 git
RUN git clone https://github.com/pypa/setuptools.git && \
    python setuptools/bootstrap.py && \
    python setuptools/setup.py install && \
    easy_install pip && \
    pip install elasticsearch && \
    pip install --user numpy && \
    pip install --user pyspark && \
    pip install --user requests && \
    pip install --user sklearn && \
    pip install --user pandas 

RUN wget https://artifacts.elastic.co/downloads/kibana/kibana-6.2.3-linux-x86_64.tar.gz && \
    tar -xvzf kibana-6.2.3-linux-x86_64.tar.gz

RUN wget https://artifacts.elastic.co/downloads/logstash/logstash-6.2.4.tar.gz && \
    tar -xvzf logstash-6.2.4.tar.gz

RUN cat logstash-6.2.4/config/logstash.yml
RUN echo "modules:" >> logstash-6.2.4/config/logstash.yml
RUN echo "  - name: netflow" >> logstash-6.2.4/config/logstash.yml
RUN echo "    var.input.udp.port: 9997" >> logstash-6.2.4/config/logstash.yml
RUN logstash-6.2.4/bin/logstash --modules netflow --setup
