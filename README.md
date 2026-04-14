# 🧠 Foundations of Business Analytics — Tutorial Builder

Welcome! This repository helps you build **clean, student-facing tutorials** for the *Foundations of Business Analytics* course using a modular and instructor-friendly workflow in RStudio and Quarto.

## 📋 Repository Structure

```
_quarto-r-questions.yml     # YAML for rendering only r-questions
_quarto-r-solutions.yml     # YAML for rendering only r-solutions
_quarto-r-teaching-guide.yml# YAML for rendering only r-teaching-guide
make_student.sh             # Script to generate clean student version
render.sh                   # Renders all instructor profiles and student file
tutorial.qmd                # Master tutorial (uses includes + profiles)
_questions/                 # Individual question files (one per exercise)
_learning_goals/            # Learning goal callout (optional)
_introduction/              # Introductory content (e.g., case study prompt)
```

## ✍️ Authoring a Tutorial

### 1. Write Each Question in Its Own File
Each question lives in a separate file like:

```
_questions/question_01.qmd
_questions/question_02.qmd
```

At the **top of each question file**, specify its type:

```markdown
<!-- question-type: prepare -->
```
or
```markdown
<!-- question-type: inclass -->
```

This controls where the question appears in the final student document.

### 2. Add Teaching Content Inside Comment Blocks
Each question file can also include **instructor-only material**:

- **Teaching Guide**:
  ```markdown
  <!-- BEGIN PROFILE:r-teaching-guide -->
  - Use this prompt to encourage peer discussion.
  <!-- END PROFILE:r-teaching-guide -->
  ```

- **Solution**:
  ```markdown
  <!-- BEGIN PROFILE:r-solutions -->
  ```{r}
  # Example solution code
  ```
  <!-- END PROFILE:r-solutions -->
  ```

The script will strip this material out of the final `tutorial_student.qmd` but preserve it for teaching preparation.

### 3. Include Learning Goals and Business Context
You can update the following files:

- `_learning_goals/learning_goals.qmd`
- `_introduction/business_challenge.qmd`

These are included at the top of the tutorial, and can also contain teaching-only blocks.

### 4. Set Metadata for the Tutorial
Open `_quarto-r-questions.yml` and locate:

```yaml
# BEGIN STUDENT HEADER
title: 'Tutorial 1: Business Analytics Skills for Inventory Management'
author: Foundations of Business Analytics
date: today
date-format: "MMMM, YYYY"
# END STUDENT HEADER
```

Edit only this block. It gets inserted into the top of the student version as the YAML frontmatter.

Note: Each Quarto profile (r-questions, r-solutions, r-teaching-guide) has its own `.yml` file to control rendering for different audiences.

### 5. Use `tutorial.qmd` as Your Master File
The file `tutorial.qmd` is the **master document** rendered by each Quarto profile:

- It includes the structure of the tutorial using `{{< include ... >}}` tags
- It references:
  - learning goals
  - business challenge
  - each question file
  - special headers for "Prepare" and "In-Class" sections using:
    ```markdown
    <!-- BEGIN INSERT:prepare-header -->
    ## Prepare these Exercises before Class
    ...
    <!-- END INSERT:prepare-header -->
    ```
- It is rendered differently depending on the profile used (e.g. `r-solutions` will show answers, `r-teaching-guide` will show teaching notes)

Note: `tutorial.qmd` is not used when generating `tutorial_student.qmd`. The student version is assembled separately using `make_student.sh`.

## ▶️ Build and Render the Tutorial

To render all instructor versions and generate the student file, run:

```bash
bash render.sh
```

This will:

- Render all Quarto profiles:
  - `r-questions` → shows only questions
  - `r-solutions` → shows questions + solutions
  - `r-teaching-guide` → shows questions + teaching tips
- Then run the student cleaner script:

```bash
bash make_student.sh
```

This generates `tutorial_student.qmd`, which includes:

- Only student-visible content
- All prepare/in-class questions in the right place
- Clean formatting and whitespace
- Smart answer prompts:
  - A blank line for text answers
  - An empty code block if the solution contained R code

## 💡 Tips & Conventions

- The script automatically detects the question type and inserts section headers like:
  - `## Prepare these Exercises before Class`
  - `## In-Class Exercises`

- Instructor-only blocks **must** use the `<!-- BEGIN PROFILE:... -->` / `<!-- END PROFILE:... -->` format.
- Only include the metadata you want in the student view between `# BEGIN STUDENT HEADER` and `# END STUDENT HEADER`.
- Use consistent question file naming: `question_01.qmd`, `question_02.qmd`, etc.

## 🏠 Designed for Faculty

This setup avoids manual copy-paste and gives you:

- A clean output for students
- An easy way to hide/show instructor content
- Flexible rendering profiles for different teaching needs
- Markdown + R Markdown integration for code