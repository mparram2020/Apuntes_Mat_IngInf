'''

    Authors:
        · Alejandro Santorum Varela - alejandro.santorum@estudiante.uam.es
        · Sergio Galán Martín - sergio.galanm@estudiante.uam.es

    File: ex_mcculloch_pitts.py
    Date: Feb. 20, 2021
    Project: Assignment 1 - Neurocomputation [EPS-UAM]

    Description: This file contains the implementation of the first exercise of
        the assignment, which consists in implementing a given electronic
        circuit using McCulloch-Pitts neural networks.

'''


import sys
from tabulate import tabulate
from neuro_clfs.NeuralNetwork import NeuralNetwork
from neuro_clfs.Layer import Layer
from neuro_clfs.Neuron import Neuron


def build_nn_ex1():
    '''
        Implements a given electronic circuit using McCulloch-Pitts neural networks.
        It solves exercise 1 of the assignment 1.

        :return: McCulloch-Pitts neural network that solves exercise 1.
    '''

    # Building neural network with given data
    nn = NeuralNetwork()
    input_layer = Layer()
    hidden_layer = Layer()
    output_layer = Layer()

    x1 = Neuron(Neuron.Type.Direct)
    x2 = Neuron(Neuron.Type.Direct)
    x3 = Neuron(Neuron.Type.Direct)
    input_layer.add(x1)
    input_layer.add(x2)
    input_layer.add(x3)
    # threshold = 2, active_output = 1, inactive_output = 0
    h1 = Neuron(Neuron.Type.McCulloch, 2, 1, 0)
    h2 = Neuron(Neuron.Type.McCulloch, 2, 1, 0)
    h3 = Neuron(Neuron.Type.McCulloch, 2, 1, 0)
    hidden_layer.add(h1)
    hidden_layer.add(h2)
    hidden_layer.add(h3)
    o1 = Neuron(Neuron.Type.McCulloch, 1, 1, 0)
    output_layer.add(o1)

    # a12
    x1.connect(h1, 1)
    x2.connect(h1, 1)
    x3.connect(h1, 0)
    # a13
    x1.connect(h2, 1)
    x2.connect(h2, 0)
    x3.connect(h2, 1)
    # a23
    x1.connect(h3, 0)
    x2.connect(h3, 1)
    x3.connect(h3, 1)

    h1.connect(o1, 1)
    h2.connect(o1, 1)
    h3.connect(o1, 1)

    nn.add(input_layer)
    nn.add(hidden_layer)
    nn.add(output_layer)

    return nn



def run_ex_mccPitts(nn, file_lines):
    '''
        It initialises the designed McCulloch-Pitts neural net with
        the values of the file provided. Then, it calculates the predictions
        generated by the neural network and prints them in a table.

        :param nn: designed and initialised McCulloch-Pitts neural network.
        :param file_lines: set of file lines, where each line is an input vector.
        :return: None
    '''

    headers = ['x1', 'x2', 'x3', 'a12', 'a13', 'a23', 'y']

    results = []
    for line in file_lines:
        values = line.split()

        for (i, neuron) in enumerate(nn.layers[0].neurons):
            neuron.initialise(int(values[i]))

        nn.trigger()
        nn.propagate()

        res = []
        for layer in nn.layers:
            for neuron in layer.neurons:
                res.append(str(neuron.f_x))
        results.append(res)

    # We add two 'dirty' inputs in order to see the output of the
    # McCulloch-Pitts network of the two last input values.
    # Remember that this network needs two timesteps to generate
    # an output given an input.
    for j in range(2):
        for (i, neuron) in enumerate(nn.layers[0].neurons):
            neuron.initialise(0)

        nn.trigger()
        nn.propagate()

        res = []
        for layer in nn.layers:
            for neuron in layer.neurons:
                res.append(str(neuron.f_x))
        results.append(res)

    print(tabulate(results, headers=headers, tablefmt='pretty'))




if __name__ == "__main__":

    # Reading data file
    if len(sys.argv) == 2:
        file = open(sys.argv[1])
        file_lines = file.readlines()
    else:
        # Error: No data file provided
        print("Please, provide data file name")
        exit()

    nn = build_nn_ex1()
    run_ex_mccPitts(nn, file_lines)
