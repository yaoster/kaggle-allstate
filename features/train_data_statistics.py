#!/usr/bin/env python

import csv

INPUT_FILE = 'train.csv'

def column_configurations():
    configs = { }
    with open(INPUT_FILE, 'r') as f:
        csvreader = csv.reader(f)
        for line in csvreader:
            nas = tuple([i for i in xrange(len(line)) if (line[i] == 'NA' or line[i] == '')])
            if nas not in configs:
                configs[nas] = 0
            configs[nas] = configs[nas] + 1
    return configs

def shopping_point_frequencies():
    customer = { }
    with open(INPUT_FILE, 'r') as f:
        csvreader = csv.reader(f)
        for line in csvreader:
            customer_id = line[0]
            if customer_id not in customer:
                customer[customer_id] = 0
            customer[customer_id] = customer[customer_id] + 1

    print '# customers: ' + str(len(customer.keys()))
    max_shopping_pts = max(customer.values())
    frequencies = dict(zip(xrange(max_shopping_pts + 1), [0]*max_shopping_pts))
    for i in xrange(max_shopping_pts + 1):
        frequencies[i] = len([c for c in customer.values() if c == i])
    return frequencies

def main():
    configs = column_configurations()
    print configs

    shopping_points = shopping_point_frequencies()
    print shopping_points

if __name__ == '__main__':
    main()
