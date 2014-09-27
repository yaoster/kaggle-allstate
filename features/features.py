#!/usr/bin/env python

import csv
from random import randint
from collections import defaultdict
from os.path import expanduser

HOME = expanduser('~')
TRAIN_FILE = HOME + '/src/kaggle/kaggle-allstate/data/train.csv'
TEST_FILE = HOME + '/src/kaggle/kaggle-allstate/data/test_v2.csv'
TRAIN_TARGETS = HOME + '/src/kaggle/kaggle-allstate/data/train_targets.csv'
TRAIN_FEATURES = HOME + '/src/kaggle/kaggle-allstate/data/train_features.csv'
TEST_FEATURES = HOME + '/src/kaggle/kaggle-allstate/data/test_features.csv'

def load_data(filename, return_states=False):
    data = []
    states = set()
    with open(filename, 'r') as f:
        csvreader = csv.reader(f)
        header = True
        for line in csvreader:
            if header:
                header = False
                continue
            data.append(line)
            if return_states:
                states.add(line[5])
    return (data, states)

def policy_features(policy):
    policy = [int(c) for c in policy]
    featuresA = [0]*3 #14-16 (0-indexed)
    featuresB = [0]*2 #17-18
    featuresC = [0]*4 #19-22
    featuresD = [0]*3 #23-25
    featuresE = [0]*2 #26-27
    featuresF = [0]*4 #28-31
    featuresG = [0]*4 #32-35
    featuresA[policy[0]] = 1
    featuresB[policy[1]] = 1
    featuresC[policy[2] - 1] = 1
    featuresD[policy[3] - 1] = 1
    featuresE[policy[4]] = 1
    featuresF[policy[5]] = 1
    featuresG[policy[6] - 1] = 1
    return featuresA + featuresB + featuresC + featuresD + featuresE + featuresF + featuresG

def state_features(states, state):
    ret = [0]*len(states)
    if state not in states:
        return ret
    ret[states.index(state)] = 1
    return ret

def write_features(data, states, filename, target_filename=None):
    customers = defaultdict(list) # customer ID -> [[raw line of data]]
    for line in data:
        customers[line[0]].append(line[1:])
    customer_ids = sorted(customers.keys())

    if target_filename is not None:
        # save targets and truncate data to mirror the test set
        with open(target_filename, 'w') as f:
            csvwriter = csv.writer(f)
            csvwriter.writerow(['customer', 'A', 'B', 'C', 'D', 'E', 'F', 'G'])
            for customer in customer_ids:
                target = [customer]
                target = target + customers[customer][-1][16:23]
                csvwriter.writerow(target)
                npoints = len(customers[customer]) - 1
                truncated_point = 1
                if npoints > 1:
                    truncated_point = randint(2, npoints)
                customers[customer] = customers[customer][0:truncated_point]
    else:
        TEST_CUSTOMERS = HOME + '/src/kaggle/kaggle-allstate/data/test_customers.csv'
        with open(TEST_CUSTOMERS, 'w') as f:
            csvwriter = csv.writer(f)
            csvwriter.writerow(['customer'])
            for customer in customer_ids:
                target = [customer]
                csvwriter.writerow(target)

    with open(filename, 'w') as f:
        csvwriter = csv.writer(f)
        for customer in customer_ids:
            row = []
            session = customers[customer]
            last_point = session[-1]
            row.append(len(session))
            row.append(last_point[2]) # day
            row.append(last_point[3][0:2]) # hour
            row.append(last_point[6]) # group size
            row.append(last_point[7]) # homeowner
            row.append(last_point[8]) # car age
            if last_point[9] == '':
                row.append(-1)
            else:
                row.append(str(ord(last_point[9]) - ord('a'))) # car value
            if last_point[10] == 'NA':
                row.append(-1)
            else:
                row.append(last_point[10]) # risk factor
            row.append(last_point[11]) # oldest age
            row.append(last_point[12]) # youngest age
            row.append(last_point[13]) # married
            if last_point[14] == 'NA':
                row.append(-1)
            else:
                row.append(last_point[14]) # C_previous
            if last_point[15] == 'NA':
                row.append(-1)
            else:
                row.append(last_point[15]) # duration_previous
            row.append(last_point[23]) # cost
            row = row + policy_features(last_point[16:23])
            row = row + state_features(states, last_point[4])
            csvwriter.writerow(row)


def main():
    # write training data
    train_data, states = load_data(TRAIN_FILE, True)
    states = sorted(list(states))
    write_features(train_data, states, TRAIN_FEATURES, TRAIN_TARGETS)

    # write test data
    test_data, _ = load_data(TEST_FILE)
    write_features(test_data, states, TEST_FEATURES)

if __name__ == '__main__':
    main()
