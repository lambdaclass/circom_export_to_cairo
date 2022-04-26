FROM debian

RUN apt update && apt upgrade -y && \
    apt install -y python libgmp3-dev npm pip && \
    pip3 install cairo-lang && \
    npm install -g snarkjs && \
    git clone https://github.com/tekkac/cairo-alt_bn128.git && \
    cp /cairo-alt_bn128/alt_bn128* /home && \
    cp /cairo-alt_bn128/bigint.cairo /home && \
    cp -r /cairo-alt_bn128/utils /home

COPY verifier_groth16.cairo  /home
COPY playground.cairo  /home
COPY example-data/example_0001.zkey /home
COPY example-data/public.json /home
COPY example-data/proof.json /home
COPY Makefile /home
COPY snarkjscli.patch /home
    
WORKDIR /home
