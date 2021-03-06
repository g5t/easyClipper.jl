## This file autogenerated by BinaryProvider.write_deps_file().
## Do not edit.
##
## Include this file within your main top-level source, and call
## `check_deps()` from within your module's `__init__()` method

if isdefined((@static VERSION < v"0.7.0-DEV.484" ? current_module() : @__MODULE__), :Compat)
    import Compat.Libdl
elseif VERSION >= v"0.7.0-DEV.3382"
    import Libdl
end
const cclipper = joinpath(dirname(@__FILE__), "usr/lib/cclipper.so")
function check_deps()
    global cclipper
    if !isfile(cclipper)
        error("$(cclipper) does not exist, Please re-run Pkg.build(\"Clipper\"), and restart Julia.")
    end

    if Libdl.dlopen_e(cclipper) == C_NULL
        error("$(cclipper) cannot be opened, Please re-run Pkg.build(\"Clipper\"), and restart Julia.")
    end

end
