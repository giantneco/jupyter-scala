FROM debian:stretch

RUN apt update -y && \
    apt upgrade -y && \
    apt install -y \
    	python3 \
    	openjdk-8-jdk \
        build-essential \
        python3-all \	
        python3-dev \
        python3-pip \
        libncurses5-dev \
        libncursesw5-dev \
        libzmq3-dev \
        curl

RUN pip3 install --upgrade pip && \
    pip install jupyter

ENV SCALA_VERSION 2.12.7
ENV ALMOND_VERSION 0.1.10

RUN curl -L -o /usr/local/bin/coursier https://git.io/vgvpD && \
    chmod +x /usr/local/bin/coursier && \
    coursier bootstrap \ 
        -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
           sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
        -o /almond && \
    ./almond --install && \
    rm ./almond

ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT ["/usr/bin/tini", "--", "jupyter","notebook", "--port=8888", "--ip=0.0.0.0", "--no-browser", "--allow-root", "--NotebookApp.token=''"]

EXPOSE 8888:8888

USER $NB_UID
