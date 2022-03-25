PHONY: docker, compile, run, clean , generate_verifier, make_verifier, replace_template

docker-build: Dockerfile

	docker build -t circomtest .

docker-run: Dockerfile

	docker run -i circomtest

compile: playground.cairo

	cairo-compile playground.cairo --output playground-compiled.json

run: playground-compiled.json

	cairo-run \
  --program=playground-compiled.json --print_output --print_info --relocate_prints --layout=small

clean : playground-compiled.json

	rm playground-compiled.json

#Generates a cairo verifier by replacing the original template
generate_verifier : replace_template make_verifier

replace_template: verifier_groth16.cairo 

	cp verifier_groth16.cairo verifier_groth16.sol.ejs
	mv verifier_groth16.sol.ejs /usr/local/lib/node_modules/snarkjs/templates/verifier_groth16.sol.ejs

make_verifier: example_0001.zkey

	snarkjs zkey export solidityverifier example_0001.zkey verifier.cairo
