from ubuntu:16.04

#apt-key adv --keyserver pgp.mit.edu --recv-key 6CD895FFA313E824
RUN apt-get update \
 && apt-get install -y apt-transport-https x11vnc xvfb

#add emergent repo and install
RUN echo 'deb https://grey.colorado.edu/ubuntu xenial main' >> /etc/apt/sources.list
RUN apt-get update -o Acquire::https::grey.colorado.edu::Verify-Peer=false
RUN apt-get install -y --allow-unauthenticated emergent=8.0.0-9984ubuntu1 -o Acquire::https::grey.colorado.edu::Verify-Peer=false
CMD ["x11vnc","-create","-forever"]


