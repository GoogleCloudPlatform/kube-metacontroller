FROM gcr.io/constant-cubist-173123/app_authz_build:latest AS build

COPY . /go/src/k8s.io/metacontroller/
WORKDIR /go/src/k8s.io/metacontroller/
RUN dep ensure && go build -gcflags "all=-N -l" -a -o bin/metacontroller
RUN cp bin/metacontroller /usr/bin/
CMD ["/usr/bin/metacontroller"]
