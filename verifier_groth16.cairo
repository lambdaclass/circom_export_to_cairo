#This is a template for cairo based on verifier_groth16.sol.ejs on snarkjs/templates

%builtins range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.uint256 import uint256_unsigned_div_rem
from starkware.cairo.common.uint256 import uint256_eq
from starkware.cairo.common.uint256 import uint256_sub
from starkware.cairo.common.uint256 import uint256_add
from starkware.cairo.common.uint256 import uint256_mul
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.bool import FALSE
#TODO: investigate library syntax
#TODO: find out what I can use in cairo to replace libraries
#TODO: learn more about starknet contracts


#Auxiliary functions

#Returns number as Uint256
func getUint256{range_check_ptr}(number : felt) -> (r : Uint256):

    let (high : felt, low : felt) = split_felt(number)

    return(Uint256(low, high))

end

#Creates a G1Point off of the received numbers: G1Point(x,y)
func BuildG1Point{range_check_ptr : felt}(x : felt, y : felt) -> (r: G1Point):

         let p : G1Point = BuildG1Point(1,2)
        return (p)

end
        
#Creates a G2Point off of the received numbers : G2Point([a,b],[c,d])
func BuildG2Point{range_check_ptr : felt}(a : felt, b : felt, c : felt, d : felt) -> (r : G2Point):

    let (arr1 : Uint256*) = alloc()
    let (arr2 : Uint256*) = alloc()

    let A : Uint256 = getUint256(a)
    assert arr1[0] = A

    let B : Uint256 = getUint256(b)
    assert arr1[1] = B

    let C : Uint256 = getUint256(c)
    assert arr2[0] = C
        
    let D : Uint256 = getUint256(d)
    assert arr2[1] = D

    return (G2Point(arr1, arr2))

end


#Start of Library Pairing

	struct G1Point:

		member X: Uint256
		member Y: Uint256
	end

    #Encoding of field elements is: X[0] * z + X[1]
	struct G2Point:

		member X: Uint256*
		member Y: Uint256*
	end


	#returns G1Point generator
	func P1() -> (r : G1Point):
	
		return (G1Point(Uint256(0,1), Uint256(0,2)))

	end

	#returns G2Point generator
	func P2{range_check_ptr : felt}() -> (r : G2Point):

		let p : G2Point = BuildG2Point(11559732032986387107991004021392285783925812861821192530917403151452391805634,
                                       10857046999023057135944570762232829481370756359578518086990519993285655852781,
                                       4082367875863433681332203403145435568316851327593401208105741076214120093531,
                                       8495653923123431417604973247489272438418190587263600148770280649306958101930)
		return(p)

	end

	#returns negated G1Point{range_check_ptr}(addition of a G1Point and a negated G1Point should be zero)
	func negate{range_check_ptr : felt}(p : G1Point) -> (r: G1Point):
        alloc_locals

		let q : Uint256 = getUint256(21888242871839275222246405745257275088696311157297823662689037894645226208583)

        let comp_a : felt = uint256_eq(p.X, Uint256(0,0))
		if comp_a == TRUE:

            let comp_b : felt = uint256_eq(p.X, Uint256(0,0))
			if comp_b == TRUE:
        
            	return (G1Point(Uint256(0,0),Uint256(0,0)))
            end
        
        end
        
        let ( _ , local var) = uint256_unsigned_div_rem(p.Y, q)
        let res : Uint256 = uint256_sub(q, var)

        return (G1Point(p.X, res))
end

     #returns sum of two G1Point
    func addition{range_check_ptr : felt}(p1 : G1Point, p2: G1Point) -> (r : G1Point):
        alloc_locals

        let q : Uint256 = getUint256(21888242871839275222246405745257275088696311157297823662689037894645226208583)

        let x : Uint256 = uint256_sub(p1.X, p2.X)
        let (var : Uint256, _ ) = uint256_add(p1.Y, p2.Y)
        let y : Uint256 = uint256_unsigned_div_rem(var, q)

        return(G1Point(x, y))

        #Ignored previous template implementation and went by definition of addition (p + (-p) = p)
    	#let (input : Uint256*) = alloc()
    	#assert input[0] = p1.X
    	#assert input[1] = p2.X
    	#assert input[2] = p1.Y
    	#assert input[3] = p2.Y
    	#let success = ???
    	#TODO: investigate what the next block of code does
        #TODO: complete func

    end

    #returns the product of a G1Point p and a scalar s
  func scalar_mu{range_check_ptr : felt}(p : G1Point, s : felt) -> (r : G1Point):

        assert_nn(s) #TODO check that this not a problem (felt size check)
        if s == 0 :
            return (G1Point(Uint256(0,0), Uint256(0,0)))
        end
        if s == 1:
            return (p)
        end
            let p2 : G1Point = addition(p, p)
            let result : G1Point = scalar_mu(p2, s - 1)

            return(result)
        
        #Ignored previous template implementation and went by definition of scalar multiplication (2*p = p+p)
    	#let (input : felt) = alloc()
    	#assert input[0] = p.X
    	#assert input[1] = p.Y
    	#assert input[2] = s
    	#TODO: investigate what the next block of code does
        #TODO: complete func

    end


    #returns the result of computing the pairing check
    func pairing(p1 : G1Point*, p2: G2Point*) -> (r : felt):

        # Sum of everything should be 0

        #TODO: find out how to calculate the lengh of an array
    	#TODO: investigate what the next block of code does
        #TODO: complete func

    end


    #pairing chack for two pairs
    #TODO: test once I have pairing ready
    func pairingProd2(a1 : G1Point, a2 : G2Point, 
    				  b1 : G1Point, b2 : G2Point) -> (r : felt)

    	let (p1 : G1Point*) = alloc()
    	let (p2 : G2Point*) = alloc()

    	assert p1[0] = a1
    	assert p1[1] = b1

    	assert p2[0] = a2
    	assert p2[1] = b2

    	return (pairing(p1,p2))

    end

    #pairing check for three pairs
    #TODO: test once I have pairing ready
    func pairingProd3(a1 : G1Point, a2 : G2Point, 
    				  b1 : G2Point, b2 : G2Point,
    				  c1 : G1Point, c2 : G2Point) -> (r : felt)

    	let (p1 : G1Point*) = alloc()
    	let (p2 : G2Point*) = alloc()

    	assert p1[0] = a1
    	assert p1[1] = b1
    	assert p1[2] = c1

    	assert p2[0] = a2
    	assert p2[1] = b2
    	assert p2[2] = c2

    	return (pairing(p1, p2))
    end

    #pairing check for four pairs
    #TODO: test once I have pairing ready
    func pairingProd3(a1 : G1Point, a2 : G2Point, 
    				  b1 : G2Point, b2 : G2Point,
    				  c1 : G1Point, c2 : G2Point,
    				  d1 : G1Point, d2 : G2Point) -> (r : felt)
    	let (p1 : G1Point*) = alloc()
    	let (p2 : G2Point*) = alloc()

    	assert p1[0] = a1
    	assert p1[1] = b1
    	assert p1[2] = c1
    	assert p1[3] = d1

    	assert p2[0] = a2
    	assert p2[1] = b2
    	assert p2[2] = c2
    	assert p2[3] = d2

    	return (pairing(p1, p2))
    end

#TODO: Investigate contract syntax

#Start of verifier Contract


	struct VerifyingKey:
        
        member alfa1 : G1Point      
        member beta2 : G2Point      
        member gamma2 : G2Point 
        member delta2 : G2Point 
        member IC : G1Point*

    end

	struct Proof:

		member A : G1Point 
		member B : G2Point 
		member C : G1Point 

	end

	func verifyingKey() -> (vk : VerifyingKey):

	#This is the part where the data is rendered

	   let alfa1 : G1Point = BuildG1Point(
            <%=vk_alpha_1[0]%>,
            <%=vk_alpha_1[1]%>
        )

        let beta2 : G2Point = BuildG2Point(
            <%=vk_beta_2[0][1]%>,
            <%=vk_beta_2[0][0]%>,
            <%=vk_beta_2[1][1]%>,
            <%=vk_beta_2[1][0]%>
        )

        let gamma2 : G2Point = BuildG2Point(
            <%=vk_gamma_2[0][1]%>,
            <%=vk_gamma_2[0][0]%>,
            <%=vk_gamma_2[1][1]%>,
            <%=vk_gamma_2[1][0]%>
        )
        let delta2 : G2Point = BuildG2Point(
            <%=vk_delta_2[0][1]%>,
            <%=vk_delta_2[0][0]%>,
            <%=vk_delta_2[1][1]%>,
            <%=vk_delta_2[1][0]%>
        )
        
        let (IC : G1Point*) = alloc()
        <% for (let i=0; i<IC.length; i++) { %>
        assert IC[<%=i%>] = BuildG1Point( 
            <%=IC[i][0]%>,
            <%=IC[i][1]%>
        )                                      
        <% } %>

        return(VerifyingKey(alfa1, beta2, gamma2, delta2, IC))

	end

    func verify(input : felt*, proof: Proof) -> (r : felt):

        let snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617

        let vk : VerifyingKey = verifyingKey()

        #TODO: find out how to get the lengh of an array
        #input vs IC lengh comparison

        #for loop 
        #TODO: complete func

    end

    func verifyProof( a : felt*
                      b : felt**
                      c : felt*
                      input : felt*) -> (r : felt):

        let proof : Proof = Proof(A = G1Point(a[0], a[1]),
                                  B = BuildG2Point(b[0][0], b[0][1]
                                                   b[1][0], b[1][1]),
                                  C = G1Point(c[0], c[1]))

        let (inputValues : felt) = alloc()

        memcpy(input, inputValues, <%IC.length%>)  

        if(verify(inputValues, proof) == 0){

            return(FALSE)

        } else {

            return(TRUE)
        }

    end













