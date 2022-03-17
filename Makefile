
compile: playground.cairo

	cairo-compile playground.cairo --output playground-compiled.json

run: playground-compiled.json

	cairo-run \
  --program=playground-compiled.json --print_output --print_info --relocate_prints --layout=small

clean : playground-compiled.json

	rm playground-compiled.json



#Generates a cairo verifier by replacing the original template
#Ignore if using from Dockerfile, this is meant to be used locally
generate_verifier : replace_template make_verifier

replace_template: verifier_groth16.cairo 

	cp verifier_groth16.cairo verifier_groth16.sol.ejs
	mv verifier_groth16.sol.ejs /opt/homebrew/lib/node_modules/snarkjs/templates/verifier_groth16.sol.ejs

make_verifier: multiplier2_0001.zkey

	snarkjs zkey export solidityverifier multiplier2_0001.zkey verifier.cairo

