FROM debian

RUN apt update && apt upgrade -y
RUN apt install -y python 
RUN apt install -y pip 
RUN apt install -y libgmp3-dev
RUN pip3 install cairo-lang
RUN apt install npm -y
RUN npm install -g snarkjs

COPY verifier_groth16.cairo  /home
COPY playground.cairo  /home
COPY example_0001.zkey /home
COPY Makefile /home

WORKDIR /home
