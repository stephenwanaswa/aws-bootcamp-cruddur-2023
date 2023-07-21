# Week 9 — CI/CD with CodePipeline, CodeBuild and CodeDeploy

### CodePipeline 
This is a continuous delivery service that allows you to model, visualize, and automate the steps required to release your software.
### CodeBuild
This is a fully managed cloud build service that compiles, tests, and deploys your code without the need to provision or manage your own build servers.
### CodeDeploy
This is a deployment service that automates application deployments to Amazon EC2 instances, on-premises instances, serverless Lambda functions, or Amazon ECS services.

## Configure CodeBuild Project
 We use the webUI(Clickops) to create the codeBuild project. WE name the Pipeline ```cruddur-backend-flask-bake-image``` . The service role is Set to the Default New service role. We leave the other option at their defaults.

![](assets/week9/codepipeline1.jpg)


### Stage 1
We next add a source for the pipeline. We use Github (Version 2) to make the connection to our github and select the prod branch of our code for this project.  
### Stage 2
The build stage is optional. We can set it up by selecting the build provider as AWS CodeBuild, and your AWS Region. Then pick the project name from the list if it exist or create a new project. We select the managed image as the Environment image. The OS as Amazon linux 2.For the build spec we use a buildspec file below. The artifact are then stored in an s3 bucket. Then create the build stage

![](assets/week9/codepipeline2.jpg)


### Stage 3
On the deploy stage we select Amazon ECS as the deploy provider, Pick the cluster name from the dropdown list. For the service name we select the backend-flask. All other option we leave them at the default. Review the options and create the pipeline. 
 
## Create a buildspec.yml file
We create the following buildspec.yml file
``` 
# Buildspec runs in the build stage of your pipeline.
version: 0.2
phases:
  install:
    runtime-versions:
      docker: 20
    commands:
      - echo "cd into $CODEBUILD_SRC_DIR/backend"
      - cd $CODEBUILD_SRC_DIR/backend-flask
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $IMAGE_URL
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...          
      - docker build -t backend-flask .
      - "docker tag $REPO_NAME $IMAGE_URL/$REPO_NAME"
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image..
      - docker push $IMAGE_URL/$REPO_NAME
      - cd $CODEBUILD_SRC_DIR
      - echo "imagedefinitions.json > [{\"name\":\"$CONTAINER_NAME\",\"imageUri\":\"$IMAGE_URL/$REPO_NAME\"}]" > imagedefinitions.json
      - printf "[{\"name\":\"$CONTAINER_NAME\",\"imageUri\":\"$IMAGE_URL/$REPO_NAME\"}]" > imagedefinitions.json

env:
  variables:
    AWS_ACCOUNT_ID: xxxxx
    AWS_DEFAULT_REGION: us-east-1
    CONTAINER_NAME: backend-flask
    IMAGE_URL: xxxxx.dkr.ecr.us-east-1.amazonaws.com
    REPO_NAME: backend-flask:latest
artifacts:
  files:
    - imagedefinitions.json
```


Run and test the pipeline. If any stage has an error review and check the logs for any errors

![](assets/week9/codepipeline.jpg)

### REference
[Use AWS CodePipeline with AWS CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/how-to-create-pipeline.html)