IntPoint(xy::NTuple{2,T}) where T<:Integer = IntPoint(xy[1],xy[2])

IntPoint2Tuple(a::IntPoint)=(a.X,a.Y)
IntPoint2Vector(i::IntPoint)=[i.X,i.Y]

function tupleextrema(x::Vector{NTuple{2,T}}) where T
    ex1 = extrema([xi[1] for xi in x])
    ex2 = extrema([xi[2] for xi in x])
    ( (ex1[1],ex2[1]), (ex1[2],ex2[2]) )
end

maxCint_one_two(T)=(typemax(Cint),T(1),T(2))
function _scale_j2c(x::Vector{Z},minx::Z,width::Z) where Z<:NTuple{2,T} where T
	n=length(x)
	ix = hcat( [[z...] for z in x]... ) # 2×length(x) Array
	maxi,o,t=maxCint_one_two(T)
	sx = maxi*(2*(ix.-minx)./width .- 1) # broadcast works for (Array,NTuple)
	cx = Array{Cint}(undef,size(sx))
	tb=sx.>maxi; ts=sx.<-maxi;
	cx[tb].=maxi; cx[ts].=-maxi
	representable = .~(tb.|ts)
	cx[representable] = round.(Cint,sx[representable])
	NTuple{2,Cint}[Tuple(cx[:,i]) for i=1:n]
end
function _scale_c2j(x::Vector{Z},minx::Y,width::Y) where {Z<:NTuple{2,I},Y<:NTuple{2,T}} where {I,T<:AbstractFloat}
	maxi,o,t=maxCint_one_two(T)
	[ convert.(T, (xi./maxi./t .+ (o/t) ).*width .+ minx) for xi in x ]
end
function _scale_c2j(x::Vector{Z},minx::Y,width::Y) where {Z<:NTuple{2,I},Y<:NTuple{2,T}} where {I,T<:Integer}
	maxi,o,t=maxCint_one_two(T)
	[   round.(T, (xi./maxi./t .+ (o/t) ).*width .+ minx) for xi in x ]
end


function min_width(x::Vector{NTuple{2,T}}) where T
    minx,maxx=tupleextrema(x)
    return (minx,(maxx.-minx))
end

to_intpoints(x::Vector{NTuple{2,T}}) where T = IntPoint.(_scale_j2c(x,min_width(x)...))
to_intpoints(x::Vector{Z},minx::Z,width::Z) where Z<:NTuple{2,T} where T = IntPoint.(_scale_j2c(x,minx,width))
function to_intpoints(x::Vector{Vector{NTuple{2,T}}}) where T
	minx,width=min_width(vcat(x...)) # determine width and minimum from *all* points
	[to_intpoints(xi,minx,width) for xi in x]
end

function from_intpoints(x::Vector{NTuple{2,T}},i::Vector{Vector{IntPoint}}) where T
    minx,width=min_width(x)
    [_scale_c2j(k,minx,width) for k in [IntPoint2Tuple.(j) for j in i]]
end
function from_intpoints(x::Vector{NTuple{2,T}},i::Vector{IntPoint}) where T
    minx,width=min_width(x)
    [_scale_c2j(k,minx,width) for k in IntPoint2Tuple.(i)]
end

function vector2ntuple(N::Integer,T::DataType,v::Vector{Vector{R}}) where R<:Number
    NTuple{N,T}[convert.(T,Tuple(x)) for x in v]
end
function vector2ntuple(N::Integer,T::DataType,v::Vector{Vector{Vector{R}}}) where R<:Number
    Vector{NTuple{N,T}}[vector2ntuple(N,T,x) for x in v]
end
function ntuple2vector(t::Vector{NTuple{N,T}}) where {N,T}
    Vector{T}[[x...] for x in t]
end
function ntuple2vector(t::Vector{Vector{NTuple{N,T}}}) where {N,T}
    Vector{Vector{T}}[ntuple2vector(x) for x in t]
end
