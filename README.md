## Dockerfile kf7032_22s_b

#This repo contains the Dockerfile for kf7032_22s_b.

KF7032: "Cloud Computing and Big Data" is an MSc level module taught at Northumbria University, UK. The module uses this Dockerfile so that there is a single software environment across platforms including AWS and Azure.

Run this docker container by pulling the image from docker Hub. e.g on Windows:
docker run -it --rm -p 8888:8888 -v C:\Users\jeremy:/notebooks/working jeremyellman/kf7032_22s_b:latest

The dockerfile is only needed should you wish to build your own version of the container, would like to see its exact components.

