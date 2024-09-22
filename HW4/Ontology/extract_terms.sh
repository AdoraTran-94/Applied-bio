#!/bin/bash

# Input: Command output file or paste output into a string variable
TERM_FILE="gene_description.txt"  # Replace with the file where the output of `bio explain gene` is saved

# Variables to store parents and children terms
PARENTS=()
CHILDREN=()

# Read the file line by line
while IFS= read -r line; do
  # Detect parent terms section
  if [[ $line == "Parents:" ]]; then
    # Read subsequent parent terms
    while IFS= read -r parent_line && [[ $parent_line =~ ^- ]]; do
      PARENTS+=("${parent_line//-/}")  # Remove leading "-" and add to PARENTS array
    done
  fi
  
  # Detect children terms section
  if [[ $line == "Children:" ]]; then
    # Read subsequent children terms
    while IFS= read -r child_line && [[ $child_line =~ ^- ]]; do
      CHILDREN+=("${child_line//-/}")  # Remove leading "-" and add to CHILDREN array
    done
  fi
done < "$TERM_FILE"

# Print parent terms
echo "Parent Terms:"
for parent in "${PARENTS[@]}"; do
  echo "  $parent"
done

# Print children terms
echo -e "\nChildren Terms:"
for child in "${CHILDREN[@]}"; do
  echo "  $child"
done
