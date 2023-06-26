"""
Exposes `@mustimplement` macro to help developers identifying API definitions.

    This code was taken on May 13, 2023 from https://github.com/atoptima/Coluna.jl/blob/master/src/MustImplement/MustImplement.jl
    which was available under the Mozilla Public License, Version 2.0 (https://github.com/atoptima/Coluna.jl/blob/master/LICENSE.md).
"""
module MustImplement

"""
    IncompleteInterfaceError <: Exception

Exception to be thrown when an interface function is called without default implementation.
"""
struct IncompleteInterfaceError <: Exception
    trait::String  # Name of the interface
    func_signature::String  # Signature of the function
end

function Base.showerror(io::IO, e::IncompleteInterfaceError)
    msg = """
    Incomplete implementation of interface $(e.trait).
    $(e.func_signature) not implemented.
    """
    println(io, msg)
    return nothing
end

function generate_fallback(interface_name, fname, args)
    quote
        function $(fname)(args...)
            throw(
                IncompleteInterfaceError(
                    $(string(interface_name)),
                    string(
                        $(fname),
                        "(",
                        join(string.(args[1:length(args) .== :(args)]), ", "),
                        ")",
                    ),
                ),
            )
        end
    end
end

function macroexpand_to_fallback(interface_name, sig)
    fname = sig.args[1]
    args = sig.args[2:end]
    fallback_fn = generate_fallback(interface_name, fname, args)
    fallback_fn.args[1] = quote
        $(esc(fname))
    end
    return fallback_fn
end

macro mustimplement(interface_name, sig)
    fallback_fn = macroexpand_to_fallback(interface_name, sig)
    quote
        $fallback_fn
    end
end

export @mustimplement, IncompleteInterfaceError

end
