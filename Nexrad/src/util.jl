using GZip

function gunzip_file(input_file::AbstractString, output_file::AbstractString)
    isfile(output_file) && rm(output_file)
    GZip.open(input_file, "r") do io
        open(output_file, "w") do out
            write(out, GZip.read(io))
        end
    end
end
