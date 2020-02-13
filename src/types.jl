SingleView{T} = SubArray{T,0,Array{T,1},Tuple{Int64},true} where T

abstract type AbstractTuneable <: Number end

struct Tuneable{T<:Number} <: AbstractTuneable
    val::T
    Tuneable(val::T) where T = new{T}(val)
end

struct InitializedTuneable{T<:Number} <: AbstractTuneable
    view::SingleView{T}
end


initialize!(vect, untuneable) = untuneable
function initialize!(vect::Vector{T}, tuneable::Tuneable) where T
    push!(vect, tuneable.val)
    return InitializedTuneable{T}(@view vect[end])
end
function initialize!(vect::Vector, array::AbstractArray{T}) where T
    new_array = T[]
    for elem in array
        push!(new_array, initialize!(vect, elem))
    end
    return new_array
end
function initialize!(vect::Vector, tup::NamedTuple)
    array = Pair[]
    for (key, val) in zip(keys(tup), values(tup))
        push!(array, key => initialize!(vect, val))
    end
    return (;array...)
end


struct TuneableModel{M, A}
    model::M
    array::Vector{<:A}
end
function TuneableModel{A}(model) where {A}
    arr = A[]
    for pname in propertynames(model)
        prop = getproperty(model, pname)
        initialize!(arr, prop)
    end
end
