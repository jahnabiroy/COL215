import sys


def main():
    argument = sys.argv[1]
    circuit_file = sys.argv[2]
    gate_delays_file = sys.argv[3]
    delay_constraint_file = sys.argv[4]

    # reads the input,internal signal and output
    store_def = {}
    with open(circuit_file, "r") as circuit:
        for line in circuit:
            if (
                not (line.startswith("//"))
                and not (line.startswith("\n"))
                and (
                    (line.startswith("PRIMARY_INPUTS"))
                    or (line.startswith("INTERNAL_SIGNALS"))
                    or (line.startswith("PRIMARY_OUTPUTS") or (line.startswith("DFF")))
                )
            ):
                i = line.split(" ")

                for j in range(len(i)):
                    i[j] = i[j].replace("\n", "")

                if i[0] != "DFF":
                    store_def[i[0]] = []
                    for m in range(1, len(i)):
                        if i[m] != "":
                            store_def[i[0]] += [i[m]]
                else:
                    store_def["PRIMARY_INPUTS"] += [i[-1]]
                    store_def["PRIMARY_OUTPUTS"] += [i[1]]

    # delay constraint file
    delay_constraint = 0
    with open(delay_constraint_file, "r") as delay:
        for line in delay:
            if not (line.startswith("//")) and not (line.startswith("\n")):
                inputs = line.split(" ")
                for i in range(1, len(inputs)):
                    inputs[i] = inputs[i].replace("\n", "")

                delay_constraint = max(float(inputs[0]), delay_constraint)

    # store all the signals with there initial timestamps as 0
    input_output = {}
    with open(circuit_file, "r") as circuit:
        for line in circuit:
            if (
                not (line.startswith("//"))
                and not (line.startswith("\n"))
                and (
                    (line.startswith("PRIMARY_INPUTS"))
                    or (line.startswith("INTERNAL_SIGNALS"))
                    or (line.startswith("PRIMARY_OUTPUTS"))
                )
            ):
                inputs = line.split(" ")

                for i in range(1, len(inputs)):  # looping or all the signals
                    inputs[i] = inputs[i].replace("\n", "")
                    input_output[inputs[i]] = 0

    # store the gate delays and gate areas after reading the file
    gate_delay_all = {}
    gate_area_all = {}
    gate_delay_min = {}
    with open(gate_delays_file, "r") as gates:
        existing_gates = set()  # set storing the type of the gate
        for line in gates:
            if not (line.startswith("//")) and not (line.startswith("\n")):
                inputs = line.split(" ")
                for i in range(len(inputs)):
                    inputs[i] = inputs[i].replace("\n", "")
                if inputs[1] not in existing_gates:
                    gate_delay_all[inputs[1]] = []
                    gate_delay_all[inputs[1]] += [float(inputs[2])]
                    gate_area_all[inputs[1]] = []
                    gate_area_all[inputs[1]] += [float(inputs[3])]
                    gate_delay_min[inputs[1]] = float(inputs[2])
                    existing_gates.add(inputs[1])
                else:
                    gate_delay_all[inputs[1]] += [float(inputs[2])]
                    gate_area_all[inputs[1]] += [float(inputs[3])]
                    m = gate_delay_min[inputs[1]]
                    gate_delay_min[inputs[1]] = min(m, float(inputs[2]))

    for i in gate_delay_all:
        gate_delay_all[i].sort()
    for i in gate_area_all:
        gate_area_all[i].sort(reverse=True)

    # sorting the circuit.
    def sorting_circuit():
        with open(circuit_file, "r") as circuit:
            unsorted_circuit = []
            sorted_circuit = []
            for line in circuit:
                if (
                    not (line.startswith("//"))
                    and not (
                        (line.startswith("PRIMARY_INPUTS"))
                        or (line.startswith("INTERNAL_SIGNALS"))
                        or (line.startswith("PRIMARY_OUTPUTS"))
                    )
                    and not (line.startswith("\n"))
                ):
                    inputs = line.split(" ")
                    for i in range(len(inputs)):
                        inputs[i] = inputs[i].replace("\n", "")
                    if len(set(inputs)) != 1:
                        unsorted_circuit.append(inputs)

            existing_signals = set(
                store_def["PRIMARY_INPUTS"]
            )  # append the input signals as they exist always
            g = len(unsorted_circuit)
            while True:
                for j in range(g):
                    flag = 0
                    k = (
                        len(unsorted_circuit[j]) - 1
                    )  # not including the last one as it is output, we need to check if all the inputs of the gate are existing or not
                    for q in range(1, k):
                        if unsorted_circuit[j][q] not in existing_signals:
                            flag = 1
                            break

                    if flag == 0:
                        # flag 0 means that all the inputs are existing in the existing signals
                        sorted_circuit.append(unsorted_circuit[j])
                        existing_signals.add(unsorted_circuit[j][-1])
                        unsorted_circuit.remove(unsorted_circuit[j])
                        g = g - 1
                        j = 0
                        break
                if g == 0:
                    break
                elif flag == 1 and j == g - 1:
                    sys.exit("Circuit does not exist")
        return sorted_circuit

    """
    4 cases to consider :
    •	From any primary input to any primary output (not passing through a DFF)
    •	From any primary input to any DFF input
    •	From any DFF output to any primary output
    •	From any DFF output to any DFF input

    simple solution taken - put dff inputs into primary outputs and dff outputs as primary inputs. 
    thus done. all cases considered

    the cycle essentially contains combinational paths
 starting at the output of a DFF and terminating at the input of a DFF.
    """

    def longest_combinatorial_delay():
        l = sorting_circuit()

        for i in range(len(l)):
            if l[i][0] == "INV":
                input_output[l[i][-1]] = max(
                    gate_delay_min[l[i][0]] + input_output[l[i][1]],
                    input_output[l[i][-1]],
                )

            elif l[i][0] == "DFF":
                input_output[l[i][-1]] = 0

            else:
                c = 0
                for b in range(1, len(l[i]) - 1):
                    c = max(c, input_output[l[i][b]])
                input_output[l[i][-1]] = max(
                    c + gate_delay_min[l[i][0]], input_output[l[i][-1]]
                )
        longest_delay = 0
        longest_delay_signal = 0

        for i in store_def["PRIMARY_OUTPUTS"]:
            longest_delay = max(longest_delay, input_output[i])
            if longest_delay == input_output[i]:
                longest_delay_signal = i

        file_path = "longest_delay.txt"
        with open(file_path, "w") as file:
            if longest_delay - int(longest_delay) == 0.0:
                file.write(str(int(longest_delay)))
                file.write("\n")
            else:
                file.write(str(longest_delay))
                file.write("\n")

        return longest_delay_signal

    """
    find the smallest circuit that respects a given longest combinational path delay constraint. 
    That is, select the implementation for each gate in the circuit, such that the total area 
    (= sum of gate areas) is minimum and the longest combinational path delay is 
    less than or equal to a given constraint.
    """

    def forming_gate():
        lst = sorting_circuit()
        forming_gate = {}
        for i in range(len(lst)):
            if lst[i][0] != "DFF":
                forming_gate[lst[i][-1]] = [lst[i][0], 0, 0]
        return forming_gate

    def dfs():
        l = sorting_circuit()
        paths = {}
        for i in range(len(l)):
            if l[i][-1] in store_def["PRIMARY_OUTPUTS"]:
                paths[l[i][-1]] = []
        internal_signals = []
        for i in range(len(l)):
            if l[i][-1] in store_def["INTERNAL_SIGNALS"]:
                if (
                    l[i][-1] not in store_def["PRIMARY_INPUTS"]
                    and l[i][-1] not in store_def["PRIMARY_OUTPUTS"]
                ):
                    internal_signals.append(l[i][-1])

        internal_signals_paths = {}  # O(n^3)
        for i in internal_signals:
            internal_signals_paths[i] = []
        for i in range(len(l)):
            if l[i][-1] in internal_signals:
                for j in range(1, len(l[i]) - 1):
                    if l[i][j] in internal_signals:
                        internal_signals_paths[l[i][-1]].append(l[i][j])
                internal_signals_paths[l[i][-1]].append(l[i][-1])

        for i in range(len(l)):
            if l[i][0] != "DFF":
                if l[i][-1] in store_def["PRIMARY_OUTPUTS"]:
                    for j in range(1, len(l[i]) - 1):
                        if l[i][j] in internal_signals:
                            paths[l[i][-1]] += internal_signals_paths[l[i][j]]
                        elif l[i][j] in store_def["PRIMARY_OUTPUTS"]:
                            paths[l[i][-1]] += paths[l[i][j]]
                    paths[l[i][-1]].append(l[i][-1])

        return paths

    def compute(s, path):
        delay = 0
        for i in range(len(s)):
            b = int(s[i])
            delay += gate_delay_all[forming_gate()[path[i]][0]][b]
        return delay

    def area(forminggate):
        area = 0
        for i in forminggate:
            area += gate_area_all[forminggate[i][0]][forminggate[i][1]]
        return area

    def area_compute(paths, forminggate, m):
        for i in paths:
            c = ""
            for j in range(len(paths[i])):
                c += str(forminggate[paths[i][j]][1])
            lst_check = trie(c, c, paths[i], m, forminggate)[1]
            for j in range(len(paths[i])):
                forminggate[paths[i][j]][1] = int(lst_check[j])

        a = area(forminggate)
        return a

    def trie(s, last_checked, path, n, forminggate):
        if compute(s, path) <= n:
            last_checked = s
            for i in range(len(s)):
                if int(s[i]) < 2 and forminggate[path[i]][-1] != 1:
                    f = int(s[i])
                    f += 1
                    c = s[:i] + str(f) + s[(i + 1) :]
                    if trie(c, last_checked, path, n, forminggate)[0] == True:
                        last_checked = trie(c, last_checked, path, n, forminggate)[1]
                        break
                    else:
                        last_checked = trie(c, last_checked, path, n, forminggate)[1]

        else:
            return (False, last_checked)
        return (True, last_checked)

    def optimised_area():
        n = delay_constraint
        paths = dfs()

        flag = 0
        max_delay = []
        min_area = []

        for i in paths:
            forminggate = forming_gate()
            s = ""
            for j in paths[i]:
                s += str(forminggate[j][1])
            lst_chck = trie(s, s, paths[i], n, forminggate)[1]
            max_delay.append(compute(lst_chck, paths[i]))
            m = max_delay[-1]
            flag = 1
            for j in range(len(paths[i])):
                forminggate[paths[i][j]][1] = int(lst_chck[j])
                forminggate[paths[i][j]][-1] = flag
            a = area_compute(paths, forminggate, m)
            min_area.append(a)

        file_path = "minimum_area.txt"
        with open(file_path, "w") as file:
            if min(min_area) - int(min(min_area)) == 0.0:
                file.write(str(int(min(min_area))))
                file.write("\n")
            else:
                file.write(str(min(min_area)))
                file.write("\n")

    if argument == "A":
        longest_combinatorial_delay()
    elif argument == "B":
        optimised_area()


if __name__ == "__main__":
    main()
