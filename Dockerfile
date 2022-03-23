# Multi-stage build to generate custom k6 with extension
FROM golang:1.17-alpine as builder
WORKDIR $GOPATH/src/go.k6.io/k6
ADD . .
RUN apk --no-cache add git
RUN CGO_ENABLED=0 go install go.k6.io/xk6/cmd/xk6@latest
RUN CGO_ENABLED=0 xk6 build \
    --with github.com/grafana/xk6-output-prometheus-remote=. \
    --output /tmp/k6

# Create image for running k6 with output for Prometheus Remote Write
FROM gcr.io/distroless/static:nonroot
COPY --from=builder /tmp/k6 /usr/bin/k6

WORKDIR /home/k6

ENTRYPOINT ["k6"]
