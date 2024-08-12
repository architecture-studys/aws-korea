FROM alpine:latest

WORKDIR /app
COPY ./token /app/token
RUN apk update && \
    apk add --no-cache libc6-compat libstdc++ libgcc curl openssl && \
    apk upgrade --no-cache busybox && \
    chmod +x /app/token
#     adduser -D -H -s /bin/sh token
# USER token
EXPOSE 8080

CMD ["/app/token"]