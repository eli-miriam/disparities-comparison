library(lintr)

sink("lint_output.txt")

lint_dir(
    "analysis", 
    linters = linters_with_tags(tags = c("correctness"))
)

