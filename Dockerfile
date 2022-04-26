FROM debian

RUN apt update && apt upgrade -y && \
    apt install -y python libgmp3-dev npm pip && \
    pip3 install cairo-lang && \
    npm install -g snarkjs

COPY verifier_groth16.cairo  /home
COPY playground.cairo  /home
COPY example_0001.zkey /home
COPY Makefile /home
COPY snarkjscli.patch /home

WORKDIR /home
