FROM almalinux:9

RUN yum -y install https://linux.davisnetworks.com/el9/updates/mrdvt92-release-8-3.el9.mrdvt92.noarch.rpm
RUN yum -y update
RUN yum -y install epel-release
RUN /usr/bin/crb enable
RUN yum -y install perl-PAGI #0.001011-2 CPAN release

COPY app/ /app/

WORKDIR /app
CMD ["/usr/bin/pagi-server", "--host", "0.0.0.0", "--app", "/app/app.pl", "--port", "80", "--workers", "6"]
