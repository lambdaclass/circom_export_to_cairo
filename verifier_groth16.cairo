#This is a template for cairo based on verifier_groth16.sol.ejs on snarkjs/templates
%builtins range_check 

from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.math import assert_nn, split_int
from starkware.cairo.common.alloc import alloc
from alt_bn128_g1 import G1Point, g1, ec_add, ec_mul
from alt_bn128_g2 import G2Point, g2
from alt_bn128_pair import pairing
from alt_bn128_field import FQ12, is_zero, FQ2, fq12_diff, fq12_eq_zero, fq12_mul, fq12_one
from bigint import BigInt3

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

#Auxiliary functions (Builders)
#Creates a G1Point from the received felts: G1Point(x,y)
func BuildG1Point{range_check_ptr : felt}(x1 : felt, x2 : felt, x3 : felt, y1 : felt, y2 : felt, y3 : felt) -> (r: G1Point):
    alloc_locals
    let X : BigInt3 = BigInt3(x1,x2,x3)
    let Y : BigInt3 = BigInt3(y1,y2,y3)

    return (G1Point(X,Y))

end
        
#Creates a G2Point from the received felts: G2Point([a,b],[c,d])
func BuildG2Point{range_check_ptr : felt}(a1 : felt, a2 : felt, a3 : felt, b1 : felt, b2 : felt, b3 : felt, c1 : felt, c2 : felt, c3 : felt, d1 : felt, d2 : felt, d3 : felt) -> (r : G2Point):
    alloc_locals
    let A : BigInt3 = BigInt3(a1,a2,a3)
    let B : BigInt3 = BigInt3(b1,b2,b2)
    let C : BigInt3 = BigInt3(c1,c2,c3)    
    let D : BigInt3 = BigInt3(d1,d2,d3)

    let x : FQ2 = FQ2(B,A)
    let y : FQ2 = FQ2(D,C)

    return (G2Point(x, y))

end

#Returns negated BigInt3
func negateBigInt3{range_check_ptr : felt}(n : BigInt3) -> (r : BigInt3):
    let (_, nd0) = unsigned_div_rem(n.d0, 60193888514187762220203335)
    let d0 = 60193888514187762220203335 -nd0
    let (_, nd1) = unsigned_div_rem(n.d1, 60193888514187762220203335)
    let d1 = 104997207448309323063248289 -nd1
    let (_, nd2) = unsigned_div_rem(n.d2, 60193888514187762220203335)
    let d2 = 3656382694611191768777987 -nd2

    return(BigInt3(d0,d1,d2))

end

#Returns negated G1Point(addition of a G1Point and a negated G1Point should be zero)
func negate{range_check_ptr : felt}(p : G1Point) -> (r: G1Point):
    alloc_locals
    let x_is_zero : felt = is_zero(p.x)
	if x_is_zero == TRUE:
        let y_is_zero : felt = is_zero(p.y)
		if y_is_zero == TRUE:
            return (G1Point(BigInt3(0,0,0),BigInt3(0,0,0)))
        end
    end

    let neg_y : BigInt3 = negateBigInt3(p.y)
    return (G1Point(p.x, neg_y))
end

#Computes the pairing for each pair of points in p1 and p2, multiplies each new result and returns the final result
#pairing_result should iniially be an fq12_one
func compute_pairings{range_check_ptr : felt}(p1 : G1Point*, p2 : G2Point*, pairing_result : FQ12, position : felt, length : felt) -> (result : FQ12):
        if position != length:
            let current_pairing_result : FQ12 = pairing(p2[position], p1[position])
            let mul_result : FQ12 = fq12_mul(pairing_result, current_pairing_result) 

            return compute_pairings(p1, p2,mul_result, position+1, length)
        end
        return(pairing_result)
    end

#Returns the result of computing the pairing check
func pairings{range_check_ptr : felt}(p1 : G1Point*, p2: G2Point*, length : felt) -> (r : felt):
    alloc_locals
    assert_nn(length)
    let initial_result : FQ12 = fq12_one()
    let pairing_result : FQ12 = compute_pairings(p1,p2,initial_result,0,length)

    let one : FQ12 = fq12_one()
    let diff : FQ12 = fq12_diff(pairing_result, one)
    let result : felt = fq12_eq_zero(diff)
    return(result)
 end

#Pairing check for two pairs
func pairingProd2{range_check_ptr : felt}(a1 : G1Point, a2 : G2Point, b1 : G1Point, b2 : G2Point) -> (r : felt):
    let (p1 : G1Point*) = alloc()
    let (p2 : G2Point*) = alloc()

    assert p1[0] = a1
    assert p1[1] = b1

    assert p2[0] = a2
    assert p2[1] = b2

    return pairings(p1,p2,2)

end

#Pairing check for three pairs
func pairingProd3{range_check_ptr : felt}(a1 : G1Point, a2 : G2Point,  b1 : G1Point, b2 : G2Point, c1 : G1Point, c2 : G2Point) -> (r : felt):
    let (p1 : G1Point*) = alloc()
    let (p2 : G2Point*) = alloc()

    assert p1[0] = a1
    assert p1[1] = b1
    assert p1[2] = c1

    assert p2[0] = a2
    assert p2[1] = b2
    assert p2[2] = c2

    return pairings(p1,p2,3)

end

#Pairing check for four pairs
func pairingProd4{range_check_ptr : felt}(a1 : G1Point, a2 : G2Point, b1 : G1Point, b2 : G2Point, c1 : G1Point, c2 : G2Point, d1 : G1Point, d2 : G2Point) -> (r : felt):
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

    return pairings(p1,p2,4)

end

#Data reception needs to be changed in order to accomodate split up numbers
func verifyingKey{range_check_ptr : felt}() -> (vk : VerifyingKey):
    alloc_locals
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
func vk_x_linear_combination{range_check_ptr : felt}( vk_x : G1Point, input : BigInt3*, position : felt, length : felt, IC : G1Point*) -> (result_vk_x : G1Point):
    if position != length:
        let mul_result : G1Point = ec_mul(IC[position + 1], input[position])
        let add_result : G1Point = ec_add(vk_x, mul_result)
    
        return vk_x_linear_combination(add_result, input, position + 1, length,  IC)
    end
        return(vk_x)
end

func verify{range_check_ptr : felt}(input : BigInt3*, proof: Proof) -> (r : felt):
    alloc_locals
    let vk : VerifyingKey = verifyingKey()

    let initial_vk_x : G1Point = BuildG1Point(0, 0, 0, 0, 0, 0)
    let computed_vk_x : G1Point = vk_x_linear_combination(initial_vk_x, input, 0, vk.IC_length - 1, vk.IC)
    let vk_x : G1Point = ec_add(computed_vk_x, vk.IC[0])

    let neg_proof_A : G1Point = negate(proof.A)
    return pairingProd4(neg_proof_A, proof.B , vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2)

end

#Fills the empty array output with the BigInt3 version of each number in input
func getBigInt3array{range_check_ptr : felt}(input : felt*, output : BigInt3*, input_position, output_position, length):
    if output_position != length:
        let big_int : BigInt3 = BigInt3(input[input_position], input[input_position + 1], input[input_position +2])
        assert output[output_position] = big_int

        getBigInt3array(input,output,input_position+3, output_position+1,length)
        return()
    end
    return()
end

#a_len, b1_len, b2_len and c_len are all 6, input_len would be 3* inputs
func verifyProof{range_check_ptr : felt}(a_len : felt, a : felt*, b1_len : felt, b1 : felt*, b2_len : felt, b2 : felt*,
                                         c_len : felt, c : felt*, input_len : felt, input : felt*) -> (r : felt):
    alloc_locals
    let A : G1Point = BuildG1Point(a[0], a[1], a[2], a[3], a[4], a[5])
    let B : G2Point = BuildG2Point(b1[0], b1[1], b1[2], b1[3], b1[4], b1[5], b2[0], b2[1], b2[2], b2[3], b2[4], b2[5])
    let C : G1Point = BuildG1Point(c[0], c[1], c[2], c[3], c[4], c[5])

    let (big_input : BigInt3*) = alloc()
    getBigInt3array(input, big_input, 0, 0, input_len/3)

    let proof : Proof = Proof(A, B, C)
    return verify(big_input, proof)

end
