FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY main.go .
RUN go build -o sun-cipher main.go

FROM alpine:3.18
WORKDIR /app
COPY --from=builder /app/sun-cipher .
# TODO: Student must set ENV SUN_CIPHER_ID to the correct value
CMD ["./sun-cipher"]
