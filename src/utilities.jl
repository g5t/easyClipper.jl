export pathclip,pathdifference,pathintersection,pathunion,pathxor
function pathclip(path::Vector{NTuple{2,T}},clip::Vector{NTuple{2,R}},
                  cty::ClipType=ClipTypeIntersection,
                  pft::PolyFillType=PolyFillTypeNonZero,
                  cft::PolyFillType=PolyFillTypeNonZero;
                  pathclosed::Bool=true,
                  clipclosed::Bool=true) where {T,R}
    clipper=Clip()
    pathclip=to_intpoints([path,clip])
    add_path!(clipper,pathclip[1], PolyTypeSubject,pathclosed)
    add_path!(clipper,pathclip[2], PolyTypeClip,   clipclosed)
    (success,result)=execute(clipper,cty,pft,cft)
    #return (success,result)
    out = success ? from_intpoints([path;clip],result) : Vector{Vector{NTuple{2,T}}}()
    return (success,out)
end

function pathclip(path::Vector{Vector{NTuple{2,T}}},clip::Vector{NTuple{2,R}},
                  cty::ClipType=ClipTypeIntersection,
                  pft::PolyFillType=PolyFillTypeNonZero,
                  cft::PolyFillType=PolyFillTypeNonZero;
                  pathclosed::Bool=true,
                  clipclosed::Bool=true) where {T,R}
    clipper=Clip()
    pathclip=to_intpoints([path;[clip]])
    add_paths!(clipper,pathclip[1:end-1], PolyTypeSubject,pathclosed)
    add_path!( clipper,pathclip[end],     PolyTypeClip,   clipclosed)
    (success,result)=execute(clipper,cty,pft,cft)
    #return (success,result)
    out = success ? from_intpoints(vcat([path;[clip]]...),result) : Vector{Vector{NTuple{2,T}}}()
    return (success,out)
end

for (f,v) in zip( (:pathdifference,:pathintersection,:pathunion,:pathxor),
                  (ClipTypeDifference,ClipTypeIntersection,ClipTypeUnion,ClipTypeXor) )
  @eval $f(p1::Vector{NTuple{2,T}},p2::Vector{NTuple{2,R}},o...;k...) where {T,R} = pathclip(p1,p2,$v,o...;k...)
  @eval $f(p1::Vector{Vector{NTuple{2,T}}},p2::Vector{NTuple{2,R}},o...;k...) where {T,R} = pathclip(p1,p2,$v,o...;k...)
end
for f in (:pathdifference,:pathintersection,:pathunion,:pathxor)
  @eval begin
  function $f(p1::Vector{T},p2::Vector{R},o...;k...) where {T<:Vector,R<:Vector}
    @assert eltype(T)<:Number && eltype(R)<:Number "Paths should be constructed of Vector{Vector{Number}} or Vector{NTuple{2,Number}}"
    @assert all(length.(p1).==2)&&all(length.(p2).==2) "Clipper paths are restricted to two dimensions"
    S=promote_type(eltype(T),eltype(R))
    (success,result)=$f(vector2ntuple(2,S,p1),vector2ntuple(2,S,p2),o...;k...)
    out=success ? ntuple2vector(result) : Vector{Vector{Vector{S}}}()
    return (success,out)
  end
  function $f(p1::Vector{Vector{T}},p2::Vector{R},o...;k...) where {T<:Vector,R<:Vector}
    @assert eltype(T)<:Number && eltype(R)<:Number "Paths should be constructed of Vector{Vector{Vector{Number}}} or Vector{Vector{NTuple{2,Number}}}"
    @assert all(length.(vcat(p1...)).==2)&&all(length.(p2).==2) "Clipper paths are restricted to two dimensions"
    S=promote_type(eltype(T),eltype(R))
    (success,result)=$f(vector2ntuple(2,S,p1),vector2ntuple(2,S,p2),o...;k...)
    out=success ? ntuple2vector(result) : Vector{Vector{Vector{S}}}()
    return (success,out)
  end
  end
end

function area(path::Vector{NTuple{2,T}}) where T
  minx,width=min_width(path)
  areac=area(to_intpoints(path)) # the area in rescaled Cint^2
  areac/4/typemax(Cint)/typemax(Cint)*prod(width)
end
area(path::Vector{Vector{T}}) where T=area(vector2ntuple(2,T,path))
