# Week 1 — App Containerization

## Required Homework
1. Write a Dockerfile for each app
2. Ensure we get the apps running via individual container
3. Create a docker-compose file
4. Ensure we can orchestrate multiple containers to run side by side
5. Mount directories so we can make changes while we code

# Getting Started with Docker
I used the [docker documentation](https://docs.docker.com/) site to have a quick read through about docker. This gave we a quick glimpse of what to expect.
I then signed up and used Adrian's [Docker fundamentals course](https://learn.cantrill.io/p/docker-fundamentals) to further my knowledge on docker. 

### Containerize the Backend
Started writing the docker file for backend. Using the knowledge and skill gathered above and the week 1 bootcamp video I was able to generate the backend [docker file](/backend-flask/Dockerfile).

I built the docker image using 
```
docker build -t flask-backend ./flask-backend
```

The run is with . 
```
docker run --rm -p 4567:4567 -it -e BACKEND_URL='*' backend-flask
```

Using this I was able to pass the environmental variables for the backend

### Containerize the Frontend
I build the frontend using similar codes

### Docker Compose
 Using docker compose will make running multiple containers possible. 
 A [docker compose](/docker-compose.yml) yaml file is created in the root of the project
 we add the environmental variable and volume mounts the the docker compose.
 
 Then ran the docker compose using the code below
 ```
 docker compose up
 ```


## Homework Challenges

### Pushed and tagged an image to DockerHub
With the docker container running successfully I pushed the images to docker hub using the free tier

I first tagged the images on gitpod 

![Docker tag](/journal/assets/week1/docker%20tagging.jpg)

Then pushed logged in to my dockerhub account using ```docker login ``` then entered my username and api key.


To push the image I used ``` docker push {docker tagged image}``` 
![docker pus](/journal/assets/week1/docker%20push.jpg)



### Installed Docker on localmachine and got the same containers running
I am running on windows. I downloaded the docker executable and installed it.
I then logged in to my docker hub account and checked for the image that I pushed

![Docker Hub](/journal/assets/week1/docker%20hub.jpg)

I then used the installed docker app to pull the image by searching for it the selecting pull
![Docker pull](/journal/assets/week1/docker%20pull%20using%20app.jpg)

Finally I was able to run both docker images locally.

![Locally](/journal/assets/week1/docker%20image%20locally.jpg)


