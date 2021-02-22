FROM ubuntu:18.04
MAINTAINER Meng Wang <wangm0855@gmail.com>
LABEL Description="UCSC Genome Browser database"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y wget rsync \
    mysql-server \
    mysql-client-5.7 mysql-client-core-5.7 \
    libmysqlclient-dev && \
    apt-get clean

RUN mkdir /data && mkdir /var/run/mysqld

RUN { \
        echo '[mysqld]'; \
        echo 'skip-host-cache'; \
        echo 'skip-name-resolve'; \
        echo 'datadir = /data'; \
        echo 'local-infile = 1'; \
        echo 'default-storage-engine = MYISAM'; \
        echo 'bind-address = 0.0.0.0'; \
    } > /etc/mysql/my.cnf

RUN mysqld --initialize-insecure && chown -R mysql:mysql /data /var/run/mysqld

RUN wget http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql

RUN mysqld -u root & \
    sleep 6s &&\
    echo "CREATE USER 'admin'@'%' IDENTIFIED BY 'admin'; GRANT ALL ON *.* TO 'admin'@'%'; FLUSH PRIVILEGES" | mysql && \
    echo "create database hgcentral" | mysql && \
    echo "create database hgFixed" | mysql && \
    echo "create database hg38" | mysql && \
    mysql -D hgcentral < hgcentral.sql && \
    rm hgcentral.sql

RUN rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/chromInfo.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/chromInfo.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/chromInfo.frm /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/cytoBandIdeo.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/cytoBandIdeo.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/cytoBandIdeo.frm /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/grp.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/grp.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/grp.frm /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/hgFindSpec.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/hgFindSpec.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/hgFindSpec.frm /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/trackDb.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/trackDb.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/trackDb.frm /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/gold.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/gold.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/gold.frm /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/gap.MYD /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/gap.MYI /data/hg38 && \
    rsync -avzP  rsync://hgdownload.cse.ucsc.edu/mysql/hg38/gap.frm /data/hg38 && \
    chown -R mysql.mysql /data/hg38

EXPOSE 3306

CMD ["mysqld", "-u", "root"]

