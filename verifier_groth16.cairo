#This is a template for cairo based on verifier_groth16.sol.ejs on snarkjs/templates
%builtins range_check 

from starkware.cairo.common.math_cmp import RC_BOUND
from starkware.cairo.common.bool import FALSE, TRUE
from starkware.cairo.common.math import assert_nn, split_int
from starkware.cairo.common.alloc import alloc
from alt_bn128_g1 import G1Point, g1, ec_add, ec_mul
from alt_bn128_g2 import G2Point, g2
from alt_bn128_pair import pairing
from alt_bn128_field import FQ12, is_zero, FQ2, fq12_diff, fq12_eq_zero, fq12_mul, fq12_one
from bigint import BigInt3, BASE

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
#Returns number as BigInt3
func getBigInt3{range_check_ptr}(number : felt) -> (r : BigInt3):
    alloc_locals
    let (output : felt*) = alloc()
    split_int(number, 3, BASE, RC_BOUND, output)
    return(BigInt3(output[0], output[1], output[2]))

end

#Creates a G1Point from the received felts: G1Point(x,y)
func BuildG1Point{range_check_ptr : felt}(x : felt, y : felt) -> (r: G1Point):
    alloc_locals
    let X : BigInt3 = getBigInt3(x)
    let Y : BigInt3 = getBigInt3(y)

    return (G1Point(X,Y))

end
        
#Creates a G2Point from the received felts: G2Point([a,b],[c,d])
func BuildG2Point{range_check_ptr : felt}(a : felt, b : felt, c : felt, d : felt) -> (r : G2Point):
    alloc_locals
    let A : BigInt3 = getBigInt3(a)
    let B : BigInt3 = getBigInt3(b)
    let C : BigInt3 = getBigInt3(c)    
    let D : BigInt3 = getBigInt3(d)

    let x : FQ2 = FQ2(A,B)
    let y : FQ2 = FQ2(C,D)

    return (G2Point(x, y))

end

#Returns negated BigInt3
func negateBigInt3(n : BigInt3) -> (r : BigInt3):
    let d0 = -n.d0
    let d1 = -n.d1
    let d2 = -n.d2

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
func compute_pairings{range_check_ptr : felt}(p1 : G1Point*, p2 : G2Point*, pairing_result : FQ12, position : felt, lengh : felt) -> (result : FQ12):
        if position != lengh:
            let current_pairing_result : FQ12 = pairing(p2[position], p1[position])
            let mul_result : FQ12 = fq12_mul(pairing_result, current_pairing_result) 

            return compute_pairings(p1, p2,mul_result, position+1, lengh)
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
func vk_x_linear_combination{range_check_ptr : felt}( vk_x : G1Point, input : BigInt3*, position, length, IC : G1Point*) -> (result_vk_x : G1Point):
    let mul_result : G1Point = ec_mul(IC[position + 1], input[position])
    let add_result : G1Point = ec_add(vk_x, mul_result)

    if position != length:
        return vk_x_linear_combination(add_result, input, position + 1, length,  IC)
    else:
            return(add_result)
    end
end

func verify{range_check_ptr : felt}(input : BigInt3*, proof: Proof) -> (r : felt):
    alloc_locals
    let vk : VerifyingKey = verifyingKey()

    let initial_vk_x : G1Point = BuildG1Point(0,0)
    let computed_vk_x : G1Point = vk_x_linear_combination(initial_vk_x, input, 0, vk.IC_length - 1, vk.IC)
    let vk_x : G1Point = ec_add(computed_vk_x, vk.IC[0])

    let neg_proof_A : G1Point = negate(proof.A)
    return pairingProd4(neg_proof_A, proof.B , vk.alfa1, vk.beta2, vk_x, vk.gamma2, proof.C, vk.delta2)

end

#Fills the empty array output with the BigInt3 version of each number in input
func getBigInt3array{range_check_ptr : felt}(input : felt*, output : BigInt3*, position, lengh):
    if position != lengh:
        let big_int : BigInt3 = getBigInt3(input[position])
        assert output[position] = big_int

        getBigInt3array(input,output,position+1,lengh)
        return()
    end
    return()
end

func verifyProof{range_check_ptr : felt}(a_len : felt, a : felt*, b1_len : felt, b1 : felt*, b2_len : felt, b2 : felt*,
                                         c_len : felt, c : felt*, input_len : felt, input : felt*) -> (r : felt):
    alloc_locals
    let A : G1Point = BuildG1Point(a[0], a[1])
    let B : G2Point = BuildG2Point(b1[0], b1[1], b2[0], b2[1])
    let C : G1Point = BuildG1Point(c[0], c[1])

    let (big_input : BigInt3*) = alloc()
    getBigInt3array(input, big_input, 0, input_len)

    let proof : Proof = Proof(A, B, C)
    return verify(big_input, proof)

end
