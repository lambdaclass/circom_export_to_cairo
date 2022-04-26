PHONY: docker-build, docker-run, compile, run, clean, get-lib, patch, generate_verifier, generate_calldata

docker-build: Dockerfile

	docker build -t circomtest .

docker-run: Dockerfile

	docker run -i circomtest

compile: playground.cairo

	cairo-compile playground.cairo --output playground-compiled.json

run: playground-compiled.json

	cairo-run \
  		--program=playground-compiled.json --print_output \
		--print_info --relocate_prints --layout=small

clean : playground-compiled.json

	rm playground-compiled.json

#Installs cairo-alt_bn128 library, used by the verifier
get-lib: 

	git clone https://github.com/tekkac/cairo-alt_bn128.git
	cp ./cairo-alt_bn128/alt_bn128* .
	cp ./cairo-alt_bn128/bigint.cairo .
	cp -r ./cairo-alt_bn128/utils .

#Patches snarkjs in order to add the ability to export a cairo verifier and its calldata
patch : verifier_groth16.cairo snarkjscli.patch

	cp verifier_groth16.cairo /usr/local/lib/node_modules/snarkjs/templates/verifier_groth16.cairo.ejs
	patch /usr/local/lib/node_modules/snarkjs/build/cli.cjs snarkjscli.patch

#Generates a cairo verifier by replacing the original template
generate_verifier : example_0001.zkey

	snarkjs zkey export cairoverifier example_0001.zkey verifier.cairo

#Generates the inputs for the verifier contract
generate_calldata : proof.json public.json

	snarkjs zkey export cairocalldata