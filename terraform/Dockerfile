FROM hashicorp/terraform:latest

ARG MODULE=infrastructure
ENV AWS_ACCESS_KEY_ID=somekey \
    AWS_SECRET_ACCESS_KEY=somesecretkey \
    AWS_DEFAULT_REGION=us-east-1

RUN mkdir -p /home/terraform && \
    apk add --no-cache bash
ADD $MODULE /home/terraform/
WORKDIR /home/terraform

RUN terraform init && \
    terraform fmt && \
    terraform validate
