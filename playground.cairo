
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

 #auxiliary function used to create a G2Point off of the received numbers : G2Point([a,b],[c,d])
    
    func BuildG2Point(a : felt,
                      b : felt,
                      c : felt,
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

	   let alfa1 : G1Point = G1Point(
            15184750631765204772480521349862262831514812045327221339726366914554701999092,
            19044554880208243253309357165951370053763172816922293672982938597144512700803
        )

        let beta2 : G2Point = BuildG2Point(
            2856404879948173442935074891510824626489846351916760523697190749912487026114,
            18038050900132983676647646090613837824909498250613378911435152783409222045230,
            16660459136292805895204825004630228673065061598139685404076706383711965126128,
            14337920493937612263437140017830011147725717564422618785344914418827058754514
        )

        let gamma2 : G2Point = BuildG2Point(
            11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781,
            4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930
        )
        let delta2 : G2Point = BuildG2Point(
            14206208118293479893237337939267558880874275330400244469012140753335317968972,
            9770507029829883800406084369213068292089532960646483572747765520567644587147,
            7508315859542695869135953783008615254128259505585794804119956010685613944890,
            17188967020838058170915181463587742504104708680482701850074129059409983809001
        )
        
        let (IC : G1Point*) = alloc()
        
        assert IC[0] = G1Point( 
            5697762690237807657695223611137032523638191271832287987770588570485611183634,
            9468568804623559196964661857426452417935876917998716148636600676881512607212
        )                                      
        
        assert IC[1] = G1Point( 
            15152966016134208049391326194594558661003757955258875515805588677252580239133,
            8036900368354133338684141760232373426623943313955996670489334157054563991652
        )                                      
        

        return(VerifyingKey(alfa1, beta2, gamma2, delta2, IC))

	end

	


func main{output_ptr : felt*, range_check_ptr}():

    let vk : VerifyingKey = verifyingKey()
    serialize_word(vk.beta2.X[1])
    serialize_word(vk.alfa1.Y)
    serialize_word(vk.IC[0].Y)

    return ()
end


