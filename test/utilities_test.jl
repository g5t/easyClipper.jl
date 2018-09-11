test("Utility path intersection, xor, union, difference") do
	pv=[(0.,0.),(2.,0.),(0.,2.)]
	cv=[(0.,0.),(1.,0.),(1.,1.),(0.,1.)]

	success,intersection=pathintersection(pv,cv)
	@test success
	@test intersection[1] == cv[[3,4,1,2]] # Is this always true or is the permutation system dependent?
	
	success,exclusiveor=pathxor(pv,cv)
	@test success
	@test exclusiveor[1] == [(1.0,0.0),(2.0,0.0),(0.0,2.0),(0.0,1.0),(1.0,1.0)]

	success,union=pathunion(pv,cv)
	@test success
	@test union[1] == pv[[3,1,2]] # Again, is this permutation always true?

	success,difference=pathdifference(pv,cv)
	@test success
	@test difference[1] == exclusiveor[1] # a quirk of this path/clip combination

end

