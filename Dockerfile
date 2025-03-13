FROM golang:1.24-alpine AS build_base
RUN apk add --no-cache git
WORKDIR /tmp/echo

COPY . .
RUN go mod download

RUN GOOS=linux CGO_ENABLED=0 go build -o bootstrap .
FROM alpine:3.9
RUN apk add ca-certificates
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.0 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=build_base /tmp/echo/bootstrap /app/bootstrap

ENV PORT=8000
EXPOSE 8000

CMD ["/app/bootstrap"]