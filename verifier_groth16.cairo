#This is a template for cairo based on verifier_groth16.sol.ejs on snarkjs/templates

%builtins range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.uint256 import uint256_unsigned_div_rem
from starkware.cairo.common.uint256 import uint256_eq
from starkware.cairo.common.uint256 import uint256_lt
from starkware.cairo.common.uint256 import uint256_sub
from starkware.cairo.common.uint256 import uint256_add
from starkware.cairo.common.uint256 import uint256_mul
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.math import assert_nn
from starkware.cairo.common.bool import TRUE
from starkware.cairo.common.bool import FALSE

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

    #Auxiliary functions (Builders)

#Returns number as Uint256
func getUint256{range_check_ptr}(number : felt) -> (r : Uint256):

    let (high : felt, low : felt) = split_felt(number)
    return(Uint256(low, high))

end

#Creates a G1Point off of the received numbers: G1Point(x,y)
func BuildG1Point{range_check_ptr : felt}(x : felt, y : felt) -> (r: G1Point):

    let X : Uint256 = getUint256(x)
    let Y : Uint256 = getUint256(y)

    return (G1Point(X,Y))

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


	#returns G1Point generator
	func P1{range_check_ptr : felt} () -> (r : G1Point):

            let p : G1Point = BuildG1Point(1,2)
		return(p)

	end

	#returns G2Point generator
	func P2{range_check_ptr : felt}() -> (r : G2Point):

		let p : G2Point = BuildG2Point(11559732032986387107991004021392285783925812861821192530917403151452391805634,
                                       10857046999023057135944570762232829481370756359578518086990519993285655852781,
                                       4082367875863433681332203403145435568316851327593401208105741076214120093531,
                                       8495653923123431417604973247489272438418190587263600148770280649306958101930)
		return(p)

	end

	#returns negated G1Point(addition of a G1Point and a negated G1Point should be zero)
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

        let (add_x : Uint256, _ ) = uint256_add(q ,p1.X)
        let sub_x : Uint256 = uint256_sub(add_x , p2.X)
        let x : Uint256 = uint256_unsigned_div_rem(sub_x, q)
        
        let (var : Uint256, _ ) = uint256_add(p1.Y, p2.Y)
        let y : Uint256 = uint256_unsigned_div_rem(var, q)

        return(G1Point(x, y))

         #Ignored previous template implementation and went by definition of addition (p + (-p) = p)
    end

    #returns the product of a G1Point p and a scalar s
    func scalar_mu{range_check_ptr : felt}(p : G1Point, s : felt) -> (r : G1Point):

        assert_nn(s) 
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

    end

    #Extracts each member of each point in the vectors' position and adds them to the input vector
    func get_point_members{range_check_ptr : felt}( position : felt, p1 : G1Point*, p2 : G2Point*, length : felt):

        assert input[position * 6 + 0] = p1[position].X
        assert input[position * 6 + 1] = p1[position].Y
        assert input[position * 6 + 2] = p2[position].X[0]
        assert input[position * 6 + 3] = p2[position].X[1]
        assert input[position * 6 + 4] = p2[position].Y[0]
        assert input[position * 6 + 5] = p2[position].Y[1]
        
        if lengh != position:
            get_point_members( position + 1, p1, p2, input, length)
        end
    end

    #returns the result of computing the pairing check
    func pairing{range_check_ptr : felt}(p1 : G1Point*, p2: G2Point*, length : felt) -> (r : felt):
        assert_nn(length)

        let (input : Uint256) = alloc()
        get_point_members(0, p1, p2, input, length - 1)

        #Incomplete

    end

    #Pairing chack for two pairs
    func pairingProd2{range_check_ptr : felt}(a1 : G1Point, a2 : G2Point, b1 : G1Point, b2 : G2Point) -> (r : felt):

    	let (p1 : G1Point*) = alloc()
    	let (p2 : G2Point*) = alloc()

    	assert p1[0] = a1
    	assert p1[1] = b1

    	assert p2[0] = a2
    	assert p2[1] = b2

    	let result : felt = pairing(p1,p2,2)
    	return (result)

    end

    #Pairing check for three pairs
    func pairingProd3{range_check_ptr : felt}(a1 : G1Point, a2 : G2Point,  b1 : G2Point, b2 : G2Point,
    				  c1 : G1Point, c2 : G2Point) -> (r : felt):

    	let (p1 : G1Point*) = alloc()
    	let (p2 : G2Point*) = alloc()

    	assert p1[0] = a1
    	assert p1[1] = b1
    	assert p1[2] = c1

    	assert p2[0] = a2
    	assert p2[1] = b2
    	assert p2[2] = c2

    	let result : felt = pairing(p1,p2,3)
    	return (result)
    end

    #Pairing check for four pairs
    func pairingProd4{range_check_ptr : felt}(a1 : G1Point, a2 : G2Point, b1 : G1Point, b2 : G2Point,
    				  c1 : G1Point, c2 : G2Point, d1 : G1Point, d2 : G2Point) -> (r : felt):

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

    	let result : felt = pairing(p1,p2,4)
    	return (result)
    end

#Start of verifier Contract

	struct VerifyingKey:
        
        member alfa1 : G1Point      
        member beta2 : G2Point      
        member gamma2 : G2Point 
        member delta2 : G2Point 
        member IC : G1Point*
        member IC_length : felt

    end

	struct Proof:

		member A : G1Point 
		member B : G2Point 
		member C : G1Point 

	end

	func verifyingKey{range_check_ptr : felt}() -> (vk : VerifyingKey):
	#This is where the data is rendered

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
        let point_<%=i%> : G1Point =  BuildG1Point( 
            <%=IC[i][0]%>,
            <%=IC[i][1]%>)
        assert IC[<%=i%>] =  point_<%=i%>                                   
        <% } %>
        let IC_length : felt = <%=IC.length%> 

        return(VerifyingKey(alfa1, beta2, gamma2, delta2, IC, IC_length))

	end
    
    #Computes the linear combination for vk_x
    func vk_x_linear_combination{range_check_ptr : felt}( vk_x : G1Point, input : felt*, position, length, IC : G1Point*) -> (result_vk_x : G1Point):

        assert_nn(input[position])

        let mul_result : G1Point = scalar_mu(IC[position + 1], input[position])
        let new_vk_x : G1Point = addition(vk_x, mul_result)

        if position != length:

            let result_vk_x : G1Point = vk_x_linear_combination( new_vk_x, input, position + 1, length,  IC)
            return(result_vk_x)

        else:

            return(new_vk_x)

        end

    end

    func verify{range_check_ptr : felt}(input : felt*, proof: Proof) -> (r : felt):
        alloc_locals

        let vk : VerifyingKey = verifyingKey()
        #length verification

        #Compute the linear combination vk_x
        let initial_vk_x : G1Point = BuildG1Point(0,0)
        let computed_vk_x : G1Point = vk_x_linear_combination(initial_vk_x, input, 0, vk.IC_length - 1, vk.IC)

        let vk_x : G1Point = addition(computed_vk_x, vk.IC[0])

        let neg_proof_A : G1Point = negate(proof.A)
        let result : felt = pairingProd4( neg_proof_A, proof.B , vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2)
        return (result)

    end

    func verifyProof{range_check_ptr : felt}( a : felt*, b : felt**, c : felt*, input : felt*) -> (r : felt):
        #Input is used as array of felts, changes needed if input values are larger than felt
        let A : G1Point = BuildG1Point(a[0], a[1])
        let B : G2Point = BuildG2Point(b[0][0], b[0][1], b[1][0], b[1][1])
        let C : G1Point = BuildG1Point(c[0], c[1])
       
        let proof : Proof = Proof(A, B, C)

        let result : felt = verify(input, proof)

        return(result)

  end
