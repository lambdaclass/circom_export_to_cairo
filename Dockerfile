FROM debian

RUN apt update && apt upgrade -y
RUN apt install -y python 
RUN apt install -y pip 
RUN apt install -y libgmp3-dev
RUN pip3 install cairo-lang

COPY verifier_groth16.cairo  /home
COPY playground.cairo  /home
COPY Makefile /home

WORKDIR /home
