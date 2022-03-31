# Getting Started

Our goal is to find out how this verifier contract (a solidity contract) is produced, and instead output a cairo verifier contract (a starknet contract). In order to do this, the snarkjs library uses a [solidity template](https://github.com/iden3/snarkjs/blob/master/templates/verifier_groth16.sol.ejs).

To learn about Circom:
* [Circom 2 Documentation](https://docs.circom.io/): Explains what is circom, how to use it from the creation of a circuit to the generation of a verifier contract (this is what we are interested in).
* [Background in Zero Knowledge Proof](https://docs.circom.io/background/background/): Helps understand a bit more about how circom works.

Our work consists of creating a cairo template, based off of this solidity template.
* [How is a solidity verifier generated? (from a validation key)](https://hackmd.io/HCGJsQgCRRSc0Y5DJqZYEw?view)): Shows the specific functions in the [snarkjs library](https://github.com/iden3/snarkjs) that contribute to the output of the solidity verifier
* [Hello, Cairo](https://www.cairo-lang.org/docs/hello_cairo/index.html): To learn about Cairo (The language in which this template is written)
* [Cairo Common Library](https://github.com/starkware-libs/cairo-lang/tree/master/src/starkware/cairo/common): Contains every function you can import from the common library
* [Cairo Playground](https://www.cairo-lang.org/playground/): Lets you compile and run cairo code online
* [Hello, StarkNet](https://www.cairo-lang.org/docs/hello_starknet/index.html): To learn about starknet contracts
* [cairo-alt_bn128 Library](https://github.com/tekkac/cairo-alt_bn128): Contains the functions needed to handle everything elliptic-curve related.

Other useful texts:

* [Cairo for Blockchain Developers](https://www.cairo-lang.org/cairo-for-blockchain-developers/): it’s a good text to learn more about cairo.
* [Create your first zero-knowledge snark circuit using circom and snarkjs](https://blog.iden3.io/first-zk-proof.html): it’s complementary reading of Circom 2 Documentation.
* [Elliptic Curve Cryptography Explainded](https://fangpenlin.com/posts/2019/10/07/elliptic-curve-cryptography-explained/): Explains how elliptic curves work (Recommended)
* [The Basics of Pairings](https://www.youtube.com/watch?v=F4x2kQTKYFY): Explains how elliptic curves work, and their use in cryptography (Not a must watch, only recommend watching the first hour if interested).
