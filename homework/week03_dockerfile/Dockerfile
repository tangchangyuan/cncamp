FROM golang:1.16-alpine AS builder

WORKDIR /go/project

ENV GOPROXY https://goproxy.cn

COPY . /go/project

RUN go build -o /bin/cncap/project

FROM alpine:3.10 AS final

WORKDIR /go/cncap

COPY --from=builder /bin/cncap/project /go/cncap/project

ENTRYPOINT ["./project"]