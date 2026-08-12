-- Indentation *is* the block structure in Python, and `indent` folds are
-- cheaper and never lag behind an incomplete parse while typing.
require("config.fold").use("indent")
