FROM golang:alpine AS builder

WORKDIR /app

COPY cloudflare.go cloudflare.go
COPY main.go main.go
COPY prometheus.go prometheus.go
COPY go.mod go.mod
COPY go.sum go.sum

RUN go get -d -v
RUN CGO_ENABLED=0 GOOS=linux go build --ldflags '-w -s -extldflags "-static"' -o cloudflare_exporter .

FROM alpine:3.20

RUN apk update && apk add ca-certificates curl && rm -rf /var/cache/apk/*

COPY --from=builder /app/cloudflare_exporter cloudflare_exporter

ENV CF_API_KEY=""
ENV CF_API_EMAIL=""
ENV LISTEN_ADDRESS=":8080"
ENTRYPOINT [ "./cloudflare_exporter" ]

HEALTHCHECK --interval=5s --timeout=3s --retries=3 CMD curl -f http://localhost$LISTEN_ADDRESS/health || exit 1
