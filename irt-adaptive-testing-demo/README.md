# IRT Adaptive e-Testing Demo

A browser-based e-Testing prototype based on Item Response Theory (IRT).

This project demonstrates how basic IRT concepts can be connected to an interactive testing interface implemented with HTML and JavaScript. It includes item parameters, response probability calculation, Bayesian ability estimation, skipped-answer handling, answer-time recording, a confidence survey item, and an undo/back function.

## Repository Location

This project is part of the `portfolio-projects` repository and is intended to be referenced from my personal academic portfolio website.

```text
portfolio-projects/
└── irt-adaptive-testing-demo/
    ├── README.md
    └── src/
        ├── index.html
        ├── 1_functions.js
        ├── 2_itemBank.json
        └── 3_functions.js
```

## Project Overview

The goal of this project is to build a small interactive testing system that uses Item Response Theory rather than a simple raw-score-based evaluation.

The prototype implements:

- a two-parameter logistic model for response probability
- Bayesian ability estimation over candidate ability values
- item parameters for discrimination and difficulty
- skipped-answer handling
- answer-time recording
- a confidence survey item
- an undo/back function using state history
- a final result table showing answers, correctness, and response time

## Main Files

### `src/index.html`

The browser interface for the test. It loads Bootstrap and connects the JavaScript files.

### `src/1_functions.js`

Core IRT and simulation logic, including:

- normal density and prior distribution
- correct response probability
- response likelihood
- Bayesian posterior calculation
- ability estimation
- item information and standard error
- simulation functions

### `src/2_itemBank.json`

A small item bank containing English questions, choices, correct answers, and IRT item parameters:

- `a`: discrimination parameter
- `b`: difficulty parameter

It also contains a confidence survey item.

### `src/3_functions.js`

Main interactive testing logic, including:

- item loading
- answer handling
- ability update
- skipped-answer processing
- response-time recording
- confidence survey handling
- final result rendering
- undo/back behavior using `exam.history`

## How to Run Locally

Because the item bank is loaded with `fetch()`, run the project with a local static server instead of opening the HTML file directly.

```bash
cd irt-adaptive-testing-demo/src
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

## Theoretical Background

The project uses the two-parameter logistic model:

```math
P_i(\theta) = \frac{1}{1 + \exp(-D a_i(\theta - b_i))}
```

where:

- `theta` is the examinee's latent ability
- `a_i` is the item discrimination parameter
- `b_i` is the item difficulty parameter
- `D` is a scaling constant, usually around `1.7`

The system estimates ability from the response pattern by calculating a posterior distribution over possible ability values.

## Portfolio Usage

Suggested project description for a portfolio page:

> A browser-based e-Testing prototype implementing basic Item Response Theory concepts, including 2PL response probability, Bayesian ability estimation, skipped-answer handling, answer-time recording, and undo-based state restoration.

## Future Improvements

- adaptive item selection based on item information
- visualization of ability trajectory
- larger calibrated item bank
- TypeScript refactoring
- separation of model logic and UI logic
- improved result dashboard
- deployment as an interactive demo

## License

For personal academic portfolio use. A formal license can be added later if this project is made reusable.
