
%builtins output range_check


from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import unsigned_div_rem


struct G1Point:

		member X: felt
		member Y: felt
	end

	struct G2Point:

		member X: felt*
		member Y: felt*
	end


	#returns G1Point generator
	func P1() -> (r: G1Point):
	
		return (G1Point(1, 2))

	end


	#returns G2Point generator
	func P2() -> (r:G2Point):
        
        let (arr1 : felt*) = alloc()
        assert arr1[0] = 11559732032986387107991004021392285783925812861821192530917403151452391805634
        assert arr1[1] = 10857046999023057135944570762232829481370756359578518086990519993285655852781
        
        let(arr2 : felt*) = alloc()
        assert arr2[0] = 4082367875863433681332203403145435568316851327593401208105741076214120093531
        assert arr2[1] = 8495653923123431417604973247489272438418190587263600148770280649306958101930
        
		return (G2Point(arr1, arr2))
        
    end

   #returns negated G1Point (addition of a G1Point and a negated G1Point should be zero)
	func negate{range_check_ptr}(p : G1Point) -> (r: G1Point):

		#number changed to test functionality
		let q = 21888242871837297823

		#TODO: find out how to use &&
		if p.X == 0 :

			if p.Y == 0:
        
            	return (G1Point(0, 0))
            end
        
        end
       
       	#TODO: div (q) is out of valid range, fix
        let ( _ , var) = unsigned_div_rem(p.Y, q)

        return (G1Point(p.X, q - var))

      end

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


#test function, not used in final template
func vkmaker() -> (vk : VerifyingKey):

	let p1 : G1Point = P1()
	let p2 : G2Point = P2()
	let p3 : G2Point = P2()
	let p4 : G2Point = P2()

	let (arr : G1Point*) = alloc()

	assert arr[0] = G1Point(3,5)
	assert arr[1] = G1Point(4,7)

	return(VerifyingKey(p1,p2,p3,p4, arr))  

end  

func proofmaker() -> (proof : Proof):

	
    let p1 : G1Point = P1()
    let p2 : G2Point = P2()
    let p3 : G1Point = P1()
   	
   	return(Proof(p1,p2,p3))

 end
	


func main{output_ptr : felt*, range_check_ptr}():

    let vk : VerifyingKey = vkmaker()
    serialize_word(vk.beta2.X[1])
    serialize_word(vk.alfa1.Y)
    serialize_word(vk.IC[0].Y)

    let p1 : G1Point = P1()
    let p2 : G2Point = P2()
    let p3 : G1Point = P1()



    let proof : Proof = proofmaker()

    serialize_word(proof.A.X)
    serialize_word(proof.C.Y)
    serialize_word(proof.B.X[1])
    
    return ()
end


