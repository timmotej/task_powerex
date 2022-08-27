FROM hashicorp/terraform:latest

#ARG MODULE=infrastructure \
#    INITIALIZE=""
#
ARG MODULE \
    INITIALIZE \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_DEFAULT_REGION \
    AWS_REGION
RUN mkdir -p /home/terraform && \
    apk add --no-cache bash vim
ADD $MODULE /home/terraform/
WORKDIR /home/terraform

RUN [ -z ${INITIALIZE} ] || ( cp backend_init main.tf && \
    env && \
    terraform init && \
    terraform apply -auto-approve -input=false -json && \
    cp backend main.tf && \
    terrafor init -migrate-state -force-copy ) && \
    terraform init -backend-config="access_key=$AWS_ACCESS_KEY_ID" -backend-config="secret_key=$AWS_SECRET_ACCESS_KEY" && \
    terraform fmt && \
    terraform validate
