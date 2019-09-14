FROM gpmidi/centos-5.3
MAINTAINER Jichan <development@jc-lab.net>

ADD ["CentOS-Base.repo", "cacert.pem", "/tmp/"]

# Install SCA6000 Packages
RUN mv -f /tmp/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo && \
    mv -f /tmp/cacert.pem /etc/pki/tls/certs/ca-bundle.crt && \
    yum install -y yum-plugin-ov && \
    yum install -y glibc which make gcc autoconf automake gettext m4 libtool readline-devel zlib zlib-devel tar gzip diffutils file && \
    yum remove -y curl && \
    yum update -y --exclude=filesystem --exclude=module-init*

RUN mkdir -p /usr/src/build

COPY ["curl-7.66.0.tar.gz", "openssl-1.0.2k.tar.gz", "/usr/src/build/"]

# Build OpenSSL
RUN cd /usr/src/build && \
    tar -xzf openssl-1.0.2k.tar.gz && \
    echo "6b3977c61f2aedf0f96367dcfb5c6e578cf37e7b8d913b4ecb6643c3cb88d8c0 *openssl-1.0.2k.tar.gz" | sha256sum -c - && \
    cd openssl-1.0.2k && \
    ./config -fpic shared no-idea no-md2 no-mdc2 no-rc5 no-rc4 zlib --prefix=/usr --libdir=/lib64 && make depend && make && make install_sw

# Build curl
RUN cd /usr/src/build && \
    tar -xzf curl-7.66.0.tar.gz && \
    cd curl-7.66.0 && \
    ./configure --prefix=/usr --libdir=/usr/lib64 --with-ssl --disable-static && \
    make && \
    make install

RUN yum clean all && rm -rf /usr/src/build/*

WORKDIR /
CMD ["/bin/bash"]
