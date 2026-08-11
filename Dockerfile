FROM golang:1.26-alpine AS builder

RUN apk --update add ca-certificates && \
    addgroup -S gatus && \
    adduser -S -G gatus nonrootuser

WORKDIR /app
COPY app/go.mod app/go.sum ./
RUN go mod download
COPY app/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags "-w -s" -o gatus .



FROM scratch
COPY --from=builder /app/gatus /gatus
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY config/config.yaml /config/config.yaml



USER nonrootuser
ENV GATUS_CONFIG_PATH="/config/config.yaml"
EXPOSE 8080
ENTRYPOINT ["/gatus"]
