PHONY: docker-build, docker-run, compile, run, clean, patch, generate_verifier, generate_calldata

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