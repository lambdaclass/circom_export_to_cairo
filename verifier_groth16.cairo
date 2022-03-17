#This is a template for cairo based on verifier_groth16.sol.ejs on snarkjs/templates

#%lang starknet


%builtins range_check

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bool import TRUE, FALSE

#TODO: investigate library syntax
#TODO: find out what I can use in cairo to replace libraries
#TODO: learn more about starknet contracts

#Start of Library Pairing

	struct G1Point:

		member X: felt
		member Y: felt
	end

	struct G2Point:

		member X: felt*
		member Y: felt*
	end


	#returns G1Point generator
	func P1() -> (r : G1Point):
	
		return (G1Point(1, 2))

	end

	#returns G2Point generator
	func P2() -> (r : G2Point):

		#TODO: find out why the new operator doesnt work
		#let arr1 : felt* = new(11559732032986387107991004021392285783925812861821192530917403151452391805634,10857046999023057135944570762232829481370756359578518086990519993285655852781)

		#let arr2: felt* = new(4082367875863433681332203403145435568316851327593401208105741076214120093531,8495653923123431417604973247489272438418190587263600148770280649306958101930)

		let (arr1 : felt*) = alloc()
        assert arr1[0] = 11559732032986387107991004021392285783925812861821192530917403151452391805634
        assert arr1[1] = 10857046999023057135944570762232829481370756359578518086990519993285655852781
        
        let(arr2 : felt*) = alloc()
        assert arr2[0] = 4082367875863433681332203403145435568316851327593401208105741076214120093531
        assert arr2[1] = 8495653923123431417604973247489272438418190587263600148770280649306958101930
        

		return (G2Point(arr1, arr2))

	end

	#returns negated G1Point{range_check_ptr}(addition of a G1Point and a negated G1Point should be zero)
	func negate(p : G1Point) -> (r: G1Point):

		let q = 21888242871839275222246405745257275088696311157297823662689037894645226208583

		#TODO: find out how to use &&
		if p.X == 0 :

			if p.Y == 0:
        
            	return (G1Point(0, 0))
            end
        
        end

       	#TODO: div (q) is out of valid range (too big), fix
        let ( _ , var) = unsigned_div_rem(p.Y, q)

        return (G1Point(p.X, q - var))


    end

    #returns sum of two G1Point
    func addition(p1 : G1Point, p2: G2Point) -> (r : G1Point):

    	let (input : felt*) = alloc()

    	assert input[0] = p1.X
    	assert input[1] = p2.X
    	assert input[2] = p1.Y
    	assert input[3] = p2.Y

    	let success = ???

    	#TODO: investigate what the next block of code does

        #TODO: complete func

    end

    #returns the product of a G1Point p and a scalar s
    func scalar_mu(p : G1Point, s : felt) -> (r : G1Point):

    	let (input : felt) = alloc()

    	assert input[0] = p.X
    	assert input[1] = p.Y
    	assert input[2] = s

    	#TODO: ???

        #TODO: complete func

    end


    #returns the result of computing the pairing check
    func pairing(p1 : G1Point*, p2: G2Point*) -> (r : felt):

        #TODO: find out how to calculate the lengh of an array

    	#TODO: HELP!

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

    #auxiliary function used to create a G2Point off of the received numbers : G2Point([a,b],[c,d])
    
    func BuildG2Point(a : felt
                      b : felt
                      c : felt
                      d : felt) -> (r : G2Point):

        #TODO: change syntax to using new operator if available

        let (arr1 : felt*) = alloc()
        let (arr2 : felt*) = alloc()

        assert arr1[0] = a
        assert arr1[1] = b
        assert arr2[0] = c
        assert arr2[1] = d

        return (G2Point(arr1, arr2))

    end

	func verifyingKey() -> (vk : VerifyingKey):

    #TODO: test this in playground

	#This is the part where the data is rendered

	   vk.alfa1  = Pairing.G1Point(
            <%=vk_alpha_1[0]%>,
            <%=vk_alpha_1[1]%>
        )

        vk.beta2 : Pairing.G2Point = BuildG2Point(
            <%=vk_beta_2[0][1]%>,
            <%=vk_beta_2[0][0]%>,
            <%=vk_beta_2[1][1]%>,
            <%=vk_beta_2[1][0]%>
        )

        vk.gamma2 : Pairing.G2Point = BuilgG2Point(
            <%=vk_gamma_2[0][1]%>,
            <%=vk_gamma_2[0][0]%>,
            <%=vk_gamma_2[1][1]%>,
            <%=vk_gamma_2[1][0]%>
        )
        vk.delta2 : Pairing.G2Point = BuildG2Point(
            <%=vk_delta_2[0][1]%>,
            <%=vk_delta_2[0][0]%>,
            <%=vk_delta_2[1][1]%>,
            <%=vk_delta_2[1][0]%>
        )
        
        let (vk.IC : G1Point*) = alloc()
        <% for (let i=0; i<IC.length; i++) { %>
        vk.IC[<%=i%>] = Pairing.G1Point( 
            <%=IC[i][0]%>,
            <%=IC[i][1]%>
        )                                      
        <% } %>

	end

    func verify(input : felt*, proof: Proof) -> (r : felt):

        let snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617

        let vk : VerifyingKey = verifyingKey()

        #TODO: find out how to get the lengh of an array
        #TODO: complete func

    end

    func verifyProof( a : felt*
                      b : felt*
                      c : felt*
                      input : felt*) -> (r : felt):

        let proof : Proof = Proof(A= Pairing.G1Point(a[0], a[1]))
        #TODO complete func

    end













