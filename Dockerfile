# Build stage
# FROM registry.tce.woa.com/library/centos:7.9.2009-f17ae78-20221008.amd64 as builder
FROM registry.tce.com/library/centos:7.9.2009-f17ae78-20221008.amd64 as builder
WORKDIR /go/src/testapp
COPY . /go/src/testapp
RUN TZ=Asia/Shanghai USEVENDOR=yes make binary
 
# Runtime stage
# FROM registry.tce.woa.com/library/centos:7.9.2009
FROM registry.tce.com/library/centos:7.9.2009
COPY --from=builder /go/src/testapp/bin/testapp /bin
