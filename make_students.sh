#!/bin/bash

OUT="tutorial_student.qmd"
> "$OUT"

# 🔼 STEP 1: Add clean YAML header
echo "---" >> "$OUT"
awk '
  /# BEGIN STUDENT HEADER/ { in_block = 1; next }
  /# END STUDENT HEADER/   { in_block = 0; next }
  in_block == 1
' _quarto-r-questions.yml >> "$OUT"
echo "---" >> "$OUT"
echo "" >> "$OUT"

# 🔽 STEP 2: Add base files (learning goals + business challenge)
for f in _learning_goals/learning_goals.qmd _introduction/business_challenge.qmd; do
  awk '
    BEGIN { skip = 0 }
    /^<!-- BEGIN PROFILE:r-(solutions|teaching-guide) -->/ { skip = 1; next }
    /^<!-- END PROFILE:r-(solutions|teaching-guide) -->/   { skip = 0; next }
    /^<!-- question-type:/ { next }
    skip == 1 { next }
    { print }
  ' "$f" >> "$OUT"
  echo -e "\n\n" >> "$OUT"
done

# 🔽 STEP 3: Process question files
FILES=($(ls _questions/question_*.qmd | sort))
inserted_prepare=0
inserted_inclass=0
qnum=1

for f in "${FILES[@]}"; do
  # Detect question type
  qtype=$(grep -oP '(?<=<!-- question-type: )\w+(?= -->)' "$f")

  # Insert prepare header once before first prepare question
  if [[ "$qtype" == "prepare" && "$inserted_prepare" -eq 0 ]]; then
    awk '
      /<!-- BEGIN INSERT:prepare-header -->/ { in_block = 1; next }
      /<!-- END INSERT:prepare-header -->/   { in_block = 0; next }
      in_block == 1 { print }
    ' tutorial.qmd >> "$OUT"
    echo -e "\n\n" >> "$OUT"
    inserted_prepare=1
  fi

  # Insert in-class header once before first inclass question
  if [[ "$qtype" == "inclass" && "$inserted_inclass" -eq 0 ]]; then
    awk '
      /<!-- BEGIN INSERT:inclass-header -->/ { in_block = 1; next }
      /<!-- END INSERT:inclass-header -->/   { in_block = 0; next }
      in_block == 1 { print }
    ' tutorial.qmd >> "$OUT"
    echo -e "\n\n" >> "$OUT"
    inserted_inclass=1
  fi

  # Detect whether solution block contains R code
  has_code=$(awk '
    BEGIN { capture = 0; found = 0 }
    /^<!-- BEGIN PROFILE:r-solutions -->/ { capture = 1; next }
    /^<!-- END PROFILE:r-solutions -->/   { capture = 0; next }
    capture == 1 && /^\s*```{r/ { found = 1 }
    END { print found }
  ' "$f")

  # Strip instructor-only content and comment lines
  filtered=$(awk '
    BEGIN { skip = 0 }
    /^<!-- BEGIN PROFILE:r-(solutions|teaching-guide) -->/ { skip = 1; next }
    /^<!-- END PROFILE:r-(solutions|teaching-guide) -->/   { skip = 0; next }
    /^<!-- question-type:/ { next }
    skip == 1 { next }
    { print }
  ' "$f")

  echo "$filtered" >> "$OUT"
  echo "" >> "$OUT"

  # Add placeholder depending on code presence
  if [[ "$has_code" -eq 1 ]]; then
    echo '```{r}' >> "$OUT"
    echo '# Write your answer here' >> "$OUT"
    echo '```' >> "$OUT"
  else
    echo '*Write your answer here*' >> "$OUT"
  fi

  echo -e "\n\n" >> "$OUT"
  ((qnum++))
done

# 🔽 STEP 4: Remove extra blank lines
awk 'BEGIN{blank=0} /^$/ { if (++blank < 2) print; next } { blank=0; print }' "$OUT" > tmp && mv tmp "$OUT"

echo "✅ Created student version: $OUT with ${#FILES[@]} questions"
