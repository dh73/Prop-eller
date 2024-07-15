## State Space Extraction of AIGER Circuits

### Overview
This Python script converts an AIGER circuit file into a DOT format automaton graph using the Spot library. The script reads an AIGER file, processes it to generate an automaton, and then outputs the automaton in DOT format.
A safety property can be defined as an output of the automaton. This will be present in the transition arcs.

### Prerequisites
- **Python 3.x**
- **Spot Library**: Spot is a model-checking library that provides algorithms and data structures to manipulate omega-automata and implement the automata-theoretic approach to model-checking[1].

### Installation
To install the required libraries, you can use pip:
```sh
pip install spot
```

### Usage
Run the script from the command line with the following arguments:
```sh
python aut_extract.py <aiger_file> <output_dot_file>
```
- `<aiger_file>`: Path to the input AIGER file.
- `<output_dot_file>`: Path to save the output DOT file.

### Script Description
1. **Loading the AIGER Circuit**: The script uses Spot to load the AIGER circuit.
2. **Converting to Automaton**: The loaded AIGER circuit is converted into an automaton.
3. **Processing States and Transitions**: The script iterates over the states and transitions of the automaton, converting BDD conditions to readable formulas.
4. **Outputting DOT Format**: The automaton is then saved in DOT format to the specified output file.

### Example
Executing:
```bash
$ python aut_extract.py fifo.aag model_fifo.dot
```

Generates transition relation:
```bash
State: 0
  Transition to State 0 with label: (prop0 & prop1 & !rst_n) | (!prop0 & prop1 & rst_n & !write_en)
  Transition to State 2 with label: !prop0 & prop1 & rst_n & write_en
State: 1
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 1 with label: !prop0 & prop1 & !read_en & rst_n
  Transition to State 6 with label: !prop0 & prop1 & read_en & rst_n
State: 2
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 1 with label: !prop0 & prop1 & !read_en & rst_n & write_en
  Transition to State 2 with label: !prop0 & prop1 & !read_en & rst_n & !write_en
  Transition to State 6 with label: !prop0 & prop1 & read_en & rst_n & write_en
  Transition to State 7 with label: !prop0 & prop1 & read_en & rst_n & !write_en
State: 3
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 3 with label: !prop0 & prop1 & !read_en & rst_n
  Transition to State 9 with label: !prop0 & prop1 & read_en & rst_n
State: 4
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 4 with label: !prop0 & prop1 & rst_n & !write_en
  Transition to State 5 with label: !prop0 & prop1 & rst_n & write_en
State: 5
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 3 with label: !prop0 & prop1 & !read_en & rst_n & write_en
  Transition to State 5 with label: !prop0 & prop1 & !read_en & rst_n & !write_en
  Transition to State 9 with label: !prop0 & prop1 & read_en & rst_n & write_en
  Transition to State 11 with label: !prop0 & prop1 & read_en & rst_n & !write_en
State: 6
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 4 with label: !prop0 & prop1 & read_en & rst_n & !write_en
  Transition to State 5 with label: !prop0 & prop1 & read_en & rst_n & write_en
  Transition to State 6 with label: !prop0 & prop1 & !read_en & rst_n & !write_en
  Transition to State 8 with label: !prop0 & prop1 & !read_en & rst_n & write_en
State: 7
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 6 with label: !prop0 & prop1 & rst_n & write_en
  Transition to State 7 with label: !prop0 & prop1 & rst_n & !write_en
State: 8
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 5 with label: !prop0 & prop1 & read_en & rst_n
  Transition to State 8 with label: !prop0 & prop1 & !read_en & rst_n
State: 9
  Transition to State 0 with label: (prop0 & prop1 & !rst_n) | (!prop0 & prop1 & read_en & rst_n & !write_en)
  Transition to State 2 with label: !prop0 & prop1 & read_en & rst_n & write_en
  Transition to State 9 with label: !prop0 & prop1 & !read_en & rst_n & !write_en
  Transition to State 10 with label: !prop0 & prop1 & !read_en & rst_n & write_en
State: 10
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 2 with label: !prop0 & prop1 & read_en & rst_n
  Transition to State 10 with label: !prop0 & prop1 & !read_en & rst_n
State: 11
  Transition to State 0 with label: prop0 & prop1 & !rst_n
  Transition to State 9 with label: !prop0 & prop1 & rst_n & write_en
  Transition to State 11 with label: !prop0 & prop1 & rst_n & !write_en
```

And this state space as an automata with no acceptance condition:

### References
1. Spot Library Documentation: Spot is a model-checking library that provides algorithms and data structures to manipulate omega-automata[1].
2. AIGER Format: AIGER is a format and set of utilities for And-Inverter Graphs (AIGs)[2].

Citations:
[1] https://spot.lre.epita.fr/doxygen/
[2] https://fmv.jku.at/aiger/