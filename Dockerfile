FROM almalinux:9

RUN yum -y install https://linux.davisnetworks.com/el9/updates/mrdvt92-release-8-3.el9.mrdvt92.noarch.rpm
RUN yum -y update
RUN yum -y install epel-release
RUN /usr/bin/crb enable
#RUN yum -y install perl-PAGI
RUN yum -y install 'perl(IO::Socket::IP)' 'perl(IO::Async)' 'perl(Future)' 'perl(Future::AsyncAwait)' 'perl(HTTP::Parser::XS)' 'perl(Protocol::WebSocket)' 'perl(JSON::MaybeXS)' 'perl(URI::Escape)' 'perl(Cookie::Baker)' 'perl(Hash::MultiValue)' 'perl(HTTP::MultiPartParser)' 'perl(Test2::V0)' 'perl(Test::Future::IO::Impl)' 'perl(Net::Async::HTTP)' 'perl(Net::Async::WebSocket::Client)' 'perl(URI)' 'perl(Time::HiRes)'
RUN yum -y install /usr/bin/cpanm
RUN /usr/bin/cpanm PAGI
RUN ln -s /usr/local/bin/pagi-server /usr/bin/pagi-server

COPY app/ /app/

WORKDIR /app
CMD ["/usr/bin/pagi-server", "--host", "0.0.0.0", "--app", "/app/app.pl", "--port", "8080", "--workers", "6"]
