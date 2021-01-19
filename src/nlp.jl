module NLP
export countwords, filtcount, process, stopwords_en
dir = @__DIR__
stopwords_en = Set(readlines(dir * "/../res/stopwords_en.txt"))
function splitwords(text::AbstractString, regexp=r"\w[\w']+")
    words = findall(regexp, text)
    words = [endswith(text[i], "'s") ? text[i][1:end - 2] : text[i] for i in words]
end

function countwords(words::AbstractVector{<:AbstractString}; counter=Dict{String,Int}())
    for w in words
        counter[w] = get!(counter, w, 0) + 1
    end
    counter
end

countwords(text::AbstractString; regexp=r"\w[\w']+", kargs...) = countwords(splitwords(text, regexp); kargs...)
"count words in text. And use `regexp` to split."        
function countwords(textfile::IO; counter=Dict{String,Int}(), kargs...)
    for l in eachline(textfile)
        countwords(l;counter=counter, kargs...)
    end
    counter
end
        
# function countwords(textfiles::AbstractVector{<:IO};counter=Dict{String,Int}(), kargs...)
#     for f in textfiles
#         countwords(f;counter=counter, kargs...)
#     end
#     counter
# end
"""
Process the text, filter the words, and adjust the weights. return processed words vector and weights vector.
## Positional Arguments
* text: string, a vector of words, or a opend file(IO)
* Or, a counter::Dict{<:AbstractString, <:Number}
## Optional Keyword Arguments
* stopwords: a words Set
* minlength, maxlength: min and max length of a word to be included
* minfrequency: minimum frequency of a word to be included
* maxnum: maximum number of words
* minweight, maxweight: within 0 ~ 1, set to adjust extreme weight
"""
function process(counter::Dict{<:AbstractString, <:Number}; 
    stopwords=stopwords_en,
    minlength=2, maxlength=30,
    minfrequency=0,
    maxnum=500,
    minweight=1/maxnum, maxweight=minweight*20)
    stopwords = Set(stopwords)
    println("$(sum(values(counter))) words")
    println("$(length(counter)) different words")
    for (w, c) in counter
        if (c < minfrequency 
            || length(w) < minlength || length(w) > maxlength 
            || lowercase(w) in stopwords || w in stopwords)
            delete!(counter, w)
        end
    end
    words = keys(counter) |> collect
    weights = values(counter) |> collect
    println("$(length(words)) legal words")
    maxnum = min(maxnum, length(weights))
    inds = partialsortperm(weights, 1:maxnum, rev=true)
    words = words[inds]
    weights = weights[inds]
    @assert !isempty(weights)
#     weights = sqrt.(weights)
    weights = weights ./ sum(weights)
#     min_i = findfirst(x->x<minweight, weights)
#     if min_i !== nothing
#         min_i = max(1, min_i-1)
#         words = words[1:min_i]
#         weights = weights[1:min_i]
#         weights = weights ./ sum(weights)
#     end
#     println("$(length(words)) non-tiny words")
    m = weights .> maxweight
    weights[m] .= log1p.(weights[m] .- maxweight)./10 .+ maxweight
    weights .+= minweight
    println("$(sum(m)) huge words")
    words, weights
end
function process(text; regexp=r"\w[\w']+", counter=Dict{String,Int}(), kargs...)
    process(countwords(text, regexp=regexp, counter=counter); kargs...)
end
end