test("IntPoint ↔ Tuple") do
	x=1; y=0
	xy=(x,y)
	ip_direct=IntPoint(x,y)
	ip_fromtp=IntPoint(xy)
	@test ip_direct==ip_fromtp

	@test easyClipper.IntPoint2Tuple(ip_direct)==xy
	@test all( easyClipper.IntPoint2Vector(ip_direct) .== [x,y] )
end
test("Tuple extrema") do
	pointsvec = [(0,0),(1,0),(0,2),(-1,1)]
	minpoint,maxpoint=easyClipper.tupleextrema(pointsvec)
	@test minpoint == (-1,0)
	@test maxpoint == (1,2)
end
test("Rescaling julia DataTypes to full-range Cint") do
	pointsvec = NTuple{2,Float64}[(0.,0.),(1.,2.)]
	minx,xwidth=easyClipper.min_width(pointsvec)
	@test minx == (0.,0.)
	@test xwidth == (1.,2.)
	cmax,o,t=easyClipper.maxCint_one_two(Float64)
	Cpointsvec = easyClipper._scale_j2c(pointsvec,minx,xwidth)
	@test Cpointsvec[1] == (-cmax,-cmax)
	@test Cpointsvec[2] == (cmax,cmax)

	pointsvec = easyClipper.vector2ntuple(2,Float32,[rand(Float32,2) for x in 1:50])
	minx,xwidth=easyClipper.min_width(pointsvec)
	if xwidth[1]>0 && xwidth[2]>0
		Cpointsvec = easyClipper._scale_j2c(pointsvec,minx,xwidth)
		minpoint,maxpoint=easyClipper.tupleextrema(Cpointsvec)
		@test minpoint == (-cmax,-cmax)
		@test maxpoint == (cmax,cmax)

		Rpointsvec = easyClipper._scale_c2j(Cpointsvec,minx,xwidth)
		@test all( all(isapprox.(x,y)) for (x,y) in zip(pointsvec,Rpointsvec) )
	end

	pointsvec = [(0x01,0x03),(0xd3,0x2f),(0x39,0x22),(0x08,0x34)]
	minx,xwidth=easyClipper.min_width(pointsvec)
	Cpointsvec = easyClipper._scale_j2c(pointsvec,minx,xwidth)
	minpoint,maxpoint=easyClipper.tupleextrema(Cpointsvec)
	@test minpoint == (-cmax,-cmax)
	@test maxpoint == (cmax,cmax)

	Rpointsvec = easyClipper._scale_c2j(Cpointsvec,minx,xwidth)
	@test all( all(isapprox.(x,y)) for (x,y) in zip(pointsvec,Rpointsvec) )

end
