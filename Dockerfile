FROM golang:alpine AS builder

RUN apk update && apk -U --no-cache add git make build-base ca-certificates && git config --global --add safe.directory '*'=

WORKDIR /app

COPY . .

RUN go mod download
ENV GOCACHE=/root/.cache/go-build
RUN --mount=type=cache,target="/root/.cache/go-build" make build

FROM alpine:3.20

RUN apk update && apk add ca-certificates curl && rm -rf /var/cache/apk/*

COPY --from=builder /app/cloudflare_exporter cloudflare_exporter

ENV LISTEN_ADDRESS=":8080"
ENTRYPOINT [ "./cloudflare_exporter" ]

HEALTHCHECK --interval=5s --timeout=3s --retries=3 CMD curl -f http://localhost$LISTEN_ADDRESS/health || exit 1
