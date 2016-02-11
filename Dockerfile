# Dockerfile for openresty
# VERSION   0.0.4

FROM ubuntu:14.04
MAINTAINER John Ewart <jewart@egencia.com>
ENV REFRESHED_AT 2016-02-09

ENV    DEBIAN_FRONTEND noninteractive
RUN    echo "deb-src http://archive.ubuntu.com/ubuntu trusty main" >> /etc/apt/sources.list
RUN    sed 's/main$/main universe/' -i /etc/apt/sources.list
RUN    apt-get update
RUN    apt-get upgrade -y
RUN    apt-get -y install wget

# Openresty (Nginx)
RUN    apt-get -y build-dep nginx
RUN    wget http://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz \
  && tar xvfz ngx_openresty-1.9.3.1.tar.gz \
  && cd ngx_openresty-1.9.3.1 \
  && ./configure --with-luajit  --with-http_addition_module --with-http_dav_module \
        --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module \
        --with-http_realip_module --with-http_stub_status_module --with-http_ssl_module \
        --with-http_sub_module --with-ipv6 --with-pcre-jit \
  && make \
  && make install \
  && rm -rf /ngx_openresty*


# Cleanup things we don't need 
RUN apt-get -q -y autoremove $(apt-cache showsrc nginx | sed -e '/Build-Depends/!d;s/Build-Depends: \|,\|([^)]*),*\|\[[^]]*\]//g' | sed -e 's/|//g' |uniq)  \
  && apt-get -q -y clean \
  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

EXPOSE 8080
CMD /usr/local/openresty/nginx/sbin/nginx -p `pwd` -c nginx.conf
