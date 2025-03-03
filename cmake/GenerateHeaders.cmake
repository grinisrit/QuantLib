# Generate quantlib.hpp header for the source_dir
function(generate_ql_header source_dir binary_dir)
    set(children_hpp "")
    set(children_dir "")
    file(WRITE "${binary_dir}/ql/quantlib.hpp"
        "/* This file is automatically generated; do not edit. */\n\n"
        "#include <ql/qldefines.hpp>\n"
        "#include <ql/version.hpp>\n"
        "#if !defined(BOOST_ALL_NO_LIB) && defined(BOOST_MSVC)\n"
        "#  include <ql/auto_link.hpp>\n"
        "#endif\n\n")
    file(GLOB children_hpp RELATIVE ${source_dir} "${source_dir}/ql/*.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "auto_link.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "config.*.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "mathconstants.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "qldefines.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "quantlib.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "version.hpp")
    foreach(child ${children_hpp})
        file(APPEND "${binary_dir}/ql/quantlib.hpp" "#include <${child}>\n")
    endforeach()
    file(APPEND "${binary_dir}/ql/quantlib.hpp" "\n")
    file(GLOB children_dir RELATIVE ${source_dir} "${source_dir}/ql/*")
    list(FILTER children_dir EXCLUDE REGEX "CMakeFiles")
    list(FILTER children_dir EXCLUDE REGEX "^ql/\\..*")
    foreach(child ${children_dir})
        if (IS_DIRECTORY "${source_dir}/${child}")
            file(APPEND "${binary_dir}/ql/quantlib.hpp" "#include <${child}/all.hpp>\n")
        endif()
    endforeach()
endfunction()

# Generate all.hpp for the source_dir and recurse down the path
function(generate_dir_headers source_dir binary_dir)
    set(children_hpp "")
    set(children_dir "")
    set(children_all "")
    file(GLOB children_hpp RELATIVE ${source_dir} "${source_dir}/*.hpp")
    list(FILTER children_hpp EXCLUDE REGEX "all.hpp")
    file(GLOB children_dir RELATIVE ${source_dir} "${source_dir}/*")
    list(FILTER children_dir EXCLUDE REGEX "CMakeFiles")
    list(FILTER children_dir EXCLUDE REGEX "^\\..*")
    foreach(child ${children_hpp})
        list(APPEND children_all "${source_dir}/${child}")
    endforeach()
    foreach(child ${children_dir})
        if (IS_DIRECTORY "${source_dir}/${child}")
            list(APPEND children_all "${source_dir}/${child}/all.hpp")
            # Recurse down this subpath
            generate_dir_headers("${source_dir}/${child}" "${binary_dir}/${child}")
        endif()
    endforeach()
    if (children_all)
        file(WRITE "${binary_dir}/all.hpp"
            "/* This file is automatically generated; do not edit. */\n\n")
        foreach(child ${children_all})
            file(RELATIVE_PATH all_path ${SOURCE_DIR} ${child})
            file(APPEND "${binary_dir}/all.hpp" "#include <${all_path}>\n")
        endforeach()
    endif()
endfunction()

# Call generate_dir_headers for each directory at this top level (ql/)
function(generate_all_headers source_dir binary_dir)
    file(GLOB children RELATIVE ${source_dir} "${source_dir}/*")
    list(FILTER children EXCLUDE REGEX "^\\..*")
    foreach(child ${children})
        if (IS_DIRECTORY "${source_dir}/${child}")
            generate_dir_headers("${source_dir}/${child}" "${binary_dir}/${child}")
        endif()
    endforeach()
endfunction()

# Entry point
generate_ql_header(${SOURCE_DIR} ${BINARY_DIR})
generate_all_headers("${SOURCE_DIR}/ql" "${BINARY_DIR}/ql")
