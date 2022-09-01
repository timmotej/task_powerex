# Task

- Prefix all files with powerex_ from one input S3 bucket to one output S3 bucket.
- Put the prefix logic in AWS Lambda Docker Image. Code can be python/js/java,..
- Push image to ECR.
- Create S3 buckets, ECR, AWS Lambda Docker using Terraform.
- Put assignment code to github.

## How to deploy Lambda

Workflow does everything automatically. 
The new version is released from main branch. The new version is built when there is a tag `X.Y.Z` (version no, e.g. `0.2.4`)

### Deploy from local machine

1. change all necessary names of:
    - buckets (can be only `[a-z-]+`)
        - backend `backend-s3-tf-bucket` defined in:
            ```bash
            - ./terraform/backend/backend
            - ./terraform/backend/backend_init
            - ./terraform/backend/main.tf
            - ./terraform/backend/variables.tf
            - ./terraform/infrastructure/backend
            - ./terraform/infrastructure/main.tf
            - ./terraform/lambda/backend
            - ./terraform/lambda/main.tf
            ```
        - input bucket `bucket-powerex-files-input` defined in:
            ```bash
            - ./lambda/app/lambda_function.py
            - ./terraform/infrastructure/backend
            - ./terraform/infrastructure/backend_init
            - ./terraform/infrastructure/main.tf
            - ./terraform/lambda/backend
            - ./terraform/lambda/backend_init
            - ./terraform/lambda/main.tf
            ```
        - output bucket `bucket-powerex-files-output` defined in:
            ```bash
            - ./lambda/app/lambda_function.py
            - ./terraform/infrastructure/backend_init
            - ./terraform/infrastructure/backend
            - ./terraform/infrastructure/main.tf
            ```
        - ecr repository `pwx_s3_move_lambda` defined in:
            ```bash
            - ./terraform/infrastructure/backend
            - ./terraform/infrastructure/backend_init
            - ./terraform/infrastructure/main.tf
            ```
        - lambda function name `${local.prefix}_lambda_s3_move` defined in:
            ```bash
            - ./terraform/lambda/backend
            - ./terraform/lambda/backend_init
            - ./terraform/lambda/main.tf
            ```
1. define necessary env variables in your local env:
    ```bash
    export AWS_SECRET_ACCESS_KEY="secretkey"
    export AWS_ACCESS_KEY_ID="yourid"
    export AWS_REGION="region"
    ```
    and also in `aws.env` in the form:
    ```bash
    AWS_SECRET_ACCESS_KEY="secretkey"
    AWS_ACCESS_KEY_ID="yourid"
    AWS_REGION="region"
    ```
1. deploy backend with
    ```bash
    docker-compose up --build terraform_backend_init
    ```
1. deploy infrastructure with
    ```bash
    docker-compose up --build terraform_infrastructure
    ```
1. build and tag docker image for lambda function and push the image to the ECR repository with
    ```bash
    tag=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
    docker build -t $tag -f lambda/lambda.Dockerfile lambda
    docker push $tag
    ```
1. overwrite the in `docker-compose.yml` the value of `TF_VAR_image` to `$tag`
1. deploy lambda function with defined trigger to AWS
    ```bash
    docker-compose up --build terraform_lambda
    ```

## Links

### AWS Docker push

- https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html

### Lambda AWS function

- https://github.com/prabhakar2020/aws_lambda_function *structure of function*
- https://stackoverflow.com/a/32504096/10895880 *for moving objects*
- https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-images.html#get-started-invoke-function *create Lambda function with docker image*

### Terraform

#### Backend

- https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa#aeb7

#### AWS Lambda Docker

- https://hands-on.cloud/terraform-deploy-python-lambda-container-image/#h-terraform-code

#### Triggers for Lambda

- https://faun.pub/building-s3-event-triggers-for-aws-lambda-using-terraform-1d61a05b4c97


