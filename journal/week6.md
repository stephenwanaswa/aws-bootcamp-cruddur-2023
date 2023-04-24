# Week 6 — Deploying Containers
## Deploy an ECS Cluster using ECS Service Connect
We first create a CloudWatch log group to make it easier to troubleshoot any errors using the cli command

```
aws logs create-log-group --log-group-name cruddur
aws logs put-retention-policy --log-group-name cruddur --retention-in-days 1
```


We the create an IAM role with the necessary permissions via cli

```
aws iam create-role \
  --role-name CruddurServiceExecutionRole \
  --assume-role-policy-document file://aws/policies/service-assume-role-execution-policy.json

aws iam put-role-policy \
  --policy-name CruddurServiceExecutionPolicy \
  --role-name CruddurServiceExecutionRole \
  --policy-document file://aws/policies/service-execution-policy.json

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess \
  --role-name CruddurServiceExecutionRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy \
  --role-name CruddurServiceExecutionRole
```

We the create the role and attach the policies to it

```
aws iam create-role \
    --role-name CruddurTaskRole \
    --assume-role-policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[\"sts:AssumeRole\"],
    \"Effect\":\"Allow\",
    \"Principal\":{
      \"Service\":[\"ecs-tasks.amazonaws.com\"]
    }
  }]
}"

aws iam put-role-policy \
  --policy-name SSMAccessPolicy \
  --role-name CruddurTaskRole \
  --policy-document "{
  \"Version\":\"2012-10-17\",
  \"Statement\":[{
    \"Action\":[
      \"ssmmessages:CreateControlChannel\",
      \"ssmmessages:CreateDataChannel\",
      \"ssmmessages:OpenControlChannel\",
      \"ssmmessages:OpenDataChannel\"
    ],
    \"Effect\":\"Allow\",
    \"Resource\":\"*\"
  }]
}"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess \
  --role-name CruddurTaskRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess \
  --role-name CruddurTaskRole
```

To create the ECS cluster we use the command below

``` 
aws ecs create-cluster \
 --cluster-name cruddur \
 --service-connect-defaults namespace=cruddur


```

Log into ECR
we gain access to the ecr via aws cli using
```
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com"
```

We then create a script to automate the login process. 
[Login](/bin/ecr/login)




## Deploy serverless containers using Fargate for the Backend and Frontend Application
We create the docker images for the backend flask, python and the frontend react js

This is done using the aws cli commands below
```
aws ecr create-repository \
 --repository-name cruddur-python \
 --image-tag-mutability MUTABLE

aws ecr create-repository \
 --repository-name backend-flask \
 --image-tag-mutability MUTABLE

aws ecr create-repository \
 --repository-name frontend-react-js \
 --image-tag-mutability MUTABLE

```

With the images created we tag and push our images to ECR repo.
We first login to the repo using the bin command
[Login](/bin/ecr/login)

Then tag and push the image
### Python
```
docker tag python:3.10-slim-buster $ECR_PYTHON_URL:3.10-slim-buster
docker push $ECR_PYTHON_URL:3.10-slim-buster
```

### Backend Flask
We add a [health check](/backend-flask/bin/health-check) script and update our ```app.py``` to include it. We then use the bin script to simplify the build, tag and push of the image
```
./bin/backend/build
./bin/backend/push

```

### Frontend
We also use the scripts below to build ,tag and push the images

```
./bin/frontend/build
./bin/frontend/push
```

### Task Definitions

We create and register task definitions to define the containers and resources required to run our app.

For the [Backend](/aws/task-definitions/backend-flask.json) and we register it using the cli command

```
aws ecs register-task-definition --cli-input-json file://aws/task-definitions/backend-flask.json
```

for the [Frontend](/aws/task-definitions/frontend-react-js.json) and register via cli

```
aws ecs register-task-definition --cli-input-json file://aws/task-definitions/frontend-react-js.json
```

## Route traffic to the frontend and backend on different subdomains using Application Load Balancer

Create an Application Load Balancer in the same VPC as your ECS cluster.
We create an ALB named ``` cruddur-alb ```

we then add our domain names in Route 53 hosted zone and update our domain's name server to point to AWS.

Using the certificate manager we request a certificate for our added domain and update the CNAME record.

We map the domain names to the IP address of the ALB using DNS "A" records

Configure the ALB to listen for incoming traffic on the appropriate ports and protocols, and create target groups for the frontend and backend containers. We allow traffic on ports 4567 and 3000 and create a listener to redirect http traffic to https and another to the ``` cruddur-frontend-reactjs ``` target group


Verify that your application is accessible using the domain names you have defined.


## Securing our flask container
Since we are still in development we disable access of the app to specific IP address via the security group inbound rules.

We also disable the debugger on production. We create a separate Docker file for production without the debug option.



