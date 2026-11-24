FROM golang:1.26-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/server .

FROM alpine:3.24
RUN apk --no-cache upgrade && apk --no-cache add tini ca-certificates && adduser -D -u 10001 app
WORKDIR /app
COPY --from=build /out/server /app/server
COPY templates /app/templates
ENV PORT=8080
EXPOSE 8080
USER 10001
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/app/server"]
