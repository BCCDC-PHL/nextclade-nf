#!/usr/bin/env python3

import argparse
import json

def parse_dataset_list(dataset_list):
    """
    Parse dataset list into a dictionary

    :param dataset_list: Dataset list
    :type dataset_list: str
    :return: Dictionary of dataset list
    :rtype: list[dict]
    """
    datasets = []
    with open(dataset_list, 'r') as f:
        datasets = json.load(f)

    return datasets


def main(args):
    dataset_list = parse_dataset_list(args.dataset_list)

    dataset_name_lowercased = args.dataset_name.lower()
    version = ''
    for dataset in dataset_list:
        name = dataset.get('attributes', {}).get('name', '')
        name_lowercased = name.lower()
        if name_lowercased == dataset_name_lowercased:
            version = dataset.get('version', {}).get('tag', '')
            print('\t'.join(['nextcladeDatasetName', 'nextcladeDatasetVersion']))
            print('\t'.join([name, version]))
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--dataset-list')
    parser.add_argument('--dataset-name')
    args = parser.parse_args()
    main(args)
