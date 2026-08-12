-- Sections are the fold structure: an `#` section is level 1, `##` level 2,
-- and so on. No `level`, so the file opens fully expanded.
--
-- close_level = 1 because a document with a single top-level `#` is one big
-- level-1 fold -- collapsing to 0 would fold the whole file into one line.
-- 1 keeps the `#` heading and its intro visible and folds the `##` sections,
-- which is the outline you actually want. Use 2 to keep `##` open too.
require("config.fold").use("treesitter", { close_level = 1 })
