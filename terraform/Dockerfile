FROM hashicorp/terraform:latest

ARG MODULE \
    INITIALIZE \
    AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY \
    AWS_DEFAULT_REGION \
    AWS_REGION
RUN mkdir -p /terraform
    # apk add --no-cache bash vim
ADD ${MODULE} /terraform
WORKDIR /terraform

RUN [ -z ${INITIALIZE} ] || ( cp backend_init main.tf && \
    terraform init && \
    terraform apply -auto-approve -input=false -json && \
    cp backend main.tf && \
    terraform init -migrate-state -force-copy ) && \
    terraform init -backend-config="access_key=$AWS_ACCESS_KEY_ID" -backend-config="secret_key=$AWS_SECRET_ACCESS_KEY" && \
    terraform fmt && \
    terraform validate
