# Circom export to Cairo

This is still a work in progress.

## Doubts

The numbers provided by the zkey are too big for the cairo program (Cairo language cant support such numbers, which leads to output being truncated, and incompatibility with math library functions). These numbers come from the R1CS, which defines a set of equations modulo p, where F_p is the field where the values of the arithmetic circuit reside. This makes me question wether the approach of making a cairo template is correct, as the original template is based off of the groth16 protocol, for ZK-SNARK proofs, while Cairo was designed to be used with the STARK protocol. This makes me question where does my "cairo verifier" fit into the diagram, and "who", would verify it.

### Problems concerning solidity template

On the functions addition, scalar_mu and pairing, there is a block of Yul code, which is not very descriptive. This makes "translating" these functions to cairo seemingly impossible, as we cant understand what they do. It is possible to understand some of them from context, such as addition and scalar_mu, but for the pairing function there is no practical way to replicate it without knowing how the function works:

```solidity
/// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
```

## Diagram

![Flux-Diagram](Flux-Diagram.drawio.png "Flux-Diagram")

This Repository contains the following:

- verifier_groth16.cairo a work-in-progress template for cairo
- verifier_groth16.sol the original template used by snarkjs to generate a SolidityVerifier
- playground.cairo a simple example program written in cairo
- Makefile used tu compile and run the playground.cairo through the commands "make compile" and "make run", and "make generate_verifier", used to create a verifier.cairo with our template (explained below)
- Dockerfile used to create a docker image with everything ready to compile and run cairo code, and generate a verifier through snarkjs
- example_001.zkey, a validation key generated though circom from a basic circuit

## How to use it

First write and compile a circuit and compute the witness through circom, then generate a validation key through snarkjs (this process is properly explained at https://docs.circom.io/getting-started/installation/), this will yield a .zkey, which we can use to generate a solidity verifier through the command:

``` bash
snarkjs zkey export solidityverifier [name of your key].zkey [nme of the verifier produced]
```

What we can do with this is change the name of our cairo template to verifier_groth16.sol.ejs and use it ro replace the original file in snarkjs/templates, so that a "CairoVerifier" is produced instead of a Solidity one.

The Makefile has a target called "generate_verifier" that will copy our template into the templates folder and generate a verifier from the example zkey provided (example_001.zkey)

### How to test this process in a Docker container

* Create a docker container with the compiler and all the requirements:
``` bash
docker build -t circomtest .
```
* Log into the container created:
``` bash
docker run -it --rm circomtest bash
```
the prompt will be located at the `/home` directory. The file `verifier_groth16.cairo` is the template file that generates Cairo code. The provided commands are written in the `Makefile`.
* To run the generation of the verifier:
``` bash
make generate_verifier
```
it generates the file `verifier.cairo`.

If you want to test this process without docker, you should put the template file (`verifier_groth16.cairo`) in the same directory that npm puts the program files (`npm root -g` shows that directory).
