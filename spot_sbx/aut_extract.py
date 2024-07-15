import spot
import argparse

def main(aiger_file, output_dot_file):
    # Load the AIGER circuit
    aig = spot.aiger_circuit(aiger_file)

    # Convert AIGER circuit to automaton
    aut = aig.as_automaton()

    # Dictionary to hold the BDD -> formula mapping
    bdd_dict = {}

    # Iterate over the number of states
    for state in range(aut.num_states()):
        print("State:", state)
        for edge in aut.out(state):
            # Convert BDD to formula if not already done
            if edge.cond not in bdd_dict:
                bdd_dict[edge.cond] = spot.bdd_format_formula(aut.get_dict(), edge.cond)
            print("  Transition to State {} with label: {}".format(edge.dst, bdd_dict[edge.cond]))

    # Output the automaton in DOT format
    dot = aut.to_str('dot')
    with open(output_dot_file, "w") as dotfile:
        dotfile.write(dot)
    print(f"Automaton graph has been saved to {output_dot_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process an AIGER file and output the automaton in DOT format.")
    parser.add_argument("aiger_file", help="Path to the AIGER file.")
    parser.add_argument("output_dot_file", help="Path to save the output DOT file.")
    args = parser.parse_args()

    main(args.aiger_file, args.output_dot_file)
