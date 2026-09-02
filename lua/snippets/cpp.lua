-- C++ snippets. One table per snippet; see lua/config/snippets.lua for the
-- fields. A trigger starting with a dot is a postfix snippet: it is only
-- offered after `<expression>.`, and `$EXPR` is that expression.
return {
    -- containers: items.foreach -> for (const auto& item : items) { ... }
    {
        trig = ".foreach",
        dscr = "range 'for' over the expression before the dot",
        priority = 2000,
        body = "for (${1:const auto&} ${2:item} : $EXPR) {\n\t$0\n}",
    },

    -- arrays: arr.fori -> for (int i = 0; i < std::size(arr); ++i) { ... }
    -- tabstops: index name -> bound (swap for MAX_FOO, length, ...) -> body
    {
        trig = ".fori",
        dscr = "indexed 'for' over the expression before the dot",
        priority = 1900,
        body = "for (int ${1:i} = 0; $1 < ${2:std::size($EXPR)}; ++$1) {\n\t$0\n}",
    },
}
