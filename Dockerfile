#########################
### build environment ###
#########################

# base image
FROM node:9.6.1 as builder

# install chrome for protractor tests
RUN apt-get update \
    && apt-get install -y --no-install-recommends chromium
ENV CHROME_BIN=chromium

# set working directory
RUN mkdir /usr/src/app
WORKDIR /usr/src/app

# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# install and cache app dependencies
COPY package.json /usr/src/app/package.json
RUN npm install
RUN npm install -g @angular/cli@1.7.1 --unsafe

# add app
COPY . /usr/src/app

# run tests
RUN ng test --watch=false

# generate build
RUN npm run build

##################
### production ###
##################

# base image
FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf

# copy artifact build from the 'build environment'
WORKDIR /usr/share/nginx/html
COPY --from=builder /usr/src/app/dist .

# expose port 80
EXPOSE 80

# run nginx
CMD ["/bin/bash", "-c", "exec nginx -g 'daemon off;'"]  