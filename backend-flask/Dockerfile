FROM python:3.10-slim-buster

#Inside Container
#Make a New Folder inside container
WORKDIR /backend-flask

#Outside container -.> inside container
#This contains the libraries wasnt to install to tun the app
COPY requirements.txt requirements.txt


#Inside Container
#Installs the python libraries used for the app
RUN pip3 install -r requirements.txt

#Outisde Container -> inside Container
# .MEans everything in the current directory
#first . /Vanckend-flask (Outside conatiner)
#Second . /backend-flask(inside container)
COPY . .

#Set enviromanent variable inside the container and remain set when running
ENV FLASK_ENV=development

EXPOSE ${PORT}

#python3 -m flask run --host=0.0.0.0 --port=4567
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]