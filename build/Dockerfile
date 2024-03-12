FROM debian:10

#获取cron下载资源列表
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list  # Now archived

#cron下载
RUN apt-get update && apt-get -y install cron \
    && apt-get -y install vim \
    && apt-get -y install jq \
    && mkdir -p /home/workspace

ADD stup.sh /etc/init.d/stup.sh 

COPY ./src /home/workspace/monitor

#将启动cron的脚本放在/ect/init.d/目录下，开机自启动cron，ENTRYPOINT执行脚本
ENTRYPOINT ["/etc/init.d/stup.sh"]

ENV EDITOR=/usr/bin/vim

WORKDIR /home/workspace/monitor
