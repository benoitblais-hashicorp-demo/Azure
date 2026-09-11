locals {

  # Read file content to get all lines.
  raw_lines = [
    for line in split("\n", file(var.path)) :
    line if startswith(line, "#") || startswith(line, "")
  ]

  # Get the index of the first blank line.
  # The description should be solid text followed by a blank line. 
  index = index(local.raw_lines, "")

  # Extract description line from the entire file.
  # The description should starts on the first line of the file and finish with the blank line identify in the index.
  description_lines = slice(local.raw_lines, 0, local.index)

  # A commented line must begin with the "#" symbol.
  # Because we don't want that symbol in the description, it is removed from each line.
  uncommented_lines = [
    for line in local.description_lines :
    trimspace(trimprefix(line, "#"))
  ]

  # The description can be written on multiple line.
  # Because of that, we need to join every line into a single string for the description.
  description = join(" ", local.uncommented_lines)
}