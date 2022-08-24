FROM hashicorp/terraform:latest

ENV AWS_ACCESS_KEY_ID=somekey \
    AWS_SECRET_ACCESS_KEY=somesecretkey \
    AWS_DEFAULT_REGION=us-east-1

RUN mkdir -p /home/tf/proj && \
    apk add --no-cache bash
WORKDIR /home/tf/proj
ADD main.tf /home/tf/proj/

RUN terraform init && \
    terraform fmt && \
    terraform validate
