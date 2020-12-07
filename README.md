# Heroku-18 stack buildpack with OpenCV-3.4.2

## Install buildpack

A complete environment was created using the Dockerfile file based on the heroku stack v18 (Ubuntu 18.04 LTS) and python 2.

This includes the following:
- Opencv-3.4.2.
- Tesseract with Chinese Simplified language support


```
heroku buildpacks:add --index=1 https://github.com/nlog2n/heroku18-buildpack-opencv3.git
heroku buildpacks:add --index=2 heroku/python
```

## How to write a buildpack via Docker

The OpenCV buildpack is built via Dockerfile.

Step 1: Build docker image
```sh
$ docker build -t buildpack-opencv4 .
```

Step 2: Test Opencv in container
```sh
$ docker run -it buildpack-opencv4:latest  /bin/bash
```
This will also compress libraries into a tar file.

```py
$ python
import cv2
print(cv2.__version__)
sift = cv2.xfeatures2d.SIFT_create()
print(sift)
quit()
```

Step 3: Copy tar file out and upload
```sh
$ docker ps
# CONTAINER ID        IMAGE                          COMMAND                  CREATED
# b041b3188b36        buildpack-opencv3:latest       "/bin/bash"              10 seconds ago

$ docker cp b041b3188b36:/root/heroku18-buildpack-opencv4.5.0.tar.gz ./
```

Then upload the tar file to somewhere like
"https://www.dropbox.com/s/brh3klgvv48g1sz/heroku18-buildpack-opencv3.4.2.tar.gz?dl=0"

The heroku buildpack will try to download it from web url.


Step 4: Write heroku files into bin folder
 - compile
 - detect
 - release