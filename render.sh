# Separate documents for each language
quarto render --profile r-questions
quarto render --profile r-solutions
quarto render --profile r-teaching-guide

bash make_students.sh
