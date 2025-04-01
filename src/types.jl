using SpaceDataModel: AbstractDataVariable
import SpaceDataModel: name

struct HAPIVariable{T,N} <: AbstractDataVariable{T,N}
    time::AbstractVector
    values::AbstractArray{T,N}
    meta::Dict
end

function HAPIVariable(time, values::AbstractArray{T,N}, meta) where {T,N}
    HAPIVariable{T,N}(time, values, meta)
end

Base.parent(var::HAPIVariable) = var.values

function HAPIVariables(data, meta)
    params = meta["parameters"]
    n = length(params) - 1
    vars = [HAPIVariable(data, meta, i) for i in 1:n]
    return n == 1 ? first(vars) : vars
end

colsize(param) = get(param, "size", 1) |> only

"""
    HAPIVariable(data, meta, i)

Construct a `HAPIVariable` object from CSV.File `data` and `meta` at index `i`.
"""
function HAPIVariable(data::CSV.File, meta, i::Integer; merge_metadata=true)
    time = Tables.getcolumn(data, 1)
    params = meta["parameters"]
    param = params[i+1]
    size = colsize(param)
    coloffset = mapreduce(colsize, +, @view(params[1:i])) + 1

    values = if size == 1
        Tables.getcolumn(data, coloffset)
    else
        cols = coloffset:(coloffset+size-1)
        map(row -> getindex.(Ref(row), cols), data)
    end
    final_meta = merge_metadata ? delete!(merge(meta, param), "parameters") : param
    HAPIVariable(time, values, final_meta)
end

"""
    HAPIVariable(data, meta, i)

Construct a `HAPIVariable` object from a JSON-parsed `data` and `meta` at index `i`.
"""
function HAPIVariable(data, meta, i::Integer; merge_metadata=true)
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    param = meta["parameters"][i+1]
    values = getindex.(data, i + 1)
    final_meta = merge_metadata ? delete!(merge(meta, param), "parameters") : param
    HAPIVariable(time, values, final_meta)
end

"""
    HAPIVariable(d, i)

Construct a `HAPIVariable` object from a JSON-parsed Dict `d` (containing parameters) at index `i`.
"""
function HAPIVariable(d::Dict, i::Integer)
    data = d["data"]
    param = d["parameters"][i+1]
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    values = getindex.(data, i + 1)
    HAPIVariable(time, values, param)
end

HAPIVariable(d::Dict, meta, i::Integer) = HAPIVariable(d, i)

hapi_properties = (:name, :columns, :units,)

name(var::HAPIVariable) = get(var.meta, "name", "")
columns(var::HAPIVariable) = var.meta["columns"]
colsize(var::HAPIVariable) = colsize(var.meta)

function Base.getproperty(var::HAPIVariable, s::Symbol)
    s in (:time, :values, :meta) && return getfield(var, s)
    s in hapi_properties && return eval(s)(var)
    return getproperty(var.py, s)
end

function Unitful.unit(var::HAPIVariable)
    get(var.meta, "units", 1) |> uparse
end