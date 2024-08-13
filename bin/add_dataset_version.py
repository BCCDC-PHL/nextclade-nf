#!/usr/bin/env python3
import argparse
import csv
import json
import os
import sys

def parse_dataset_version(nextclade_dataset_version):
    """
    Parse dataset version into a dictionary

    :param nextclade_dataset_version: Dataset version TSV file path
    :type nextclade_dataset_version: str
    :return: Dictionary of dataset version
    :rtype: dict
    """
    dataset_version = {}
    with open(nextclade_dataset_version, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            dataset_version = row
    return dataset_version

def parse_nextclade_output(nextclade_tsv):
    """
    Parse nextclade output into a dictionary

    :param nextclade_tsv: Nextclade output tsv file
    :type nextclade_tsv: str
    :return: Dictionary of nextclade output
    :rtype: dict
    """
    with open(nextclade_tsv, 'r') as f:
        reader = csv.reader(f, delimiter='\t')
        nextclade_header = next(reader)
    
    nextclade_output = []
    with open(nextclade_tsv, 'r') as f:
        reader = csv.DictReader(f, delimiter='\t')
        for row in reader:
            nextclade_output.append(row)
    return nextclade_header, nextclade_output

def main(args):
    dataset_version = parse_dataset_version(args.nextclade_dataset_version)
    version_keys = sorted(dataset_version.keys())
    
    nextclade_header, nextclade_data = parse_nextclade_output(args.nextclade_tsv)

    output_fieldnames = nextclade_header + version_keys

    writer = csv.DictWriter(sys.stdout, dialect='excel-tab', fieldnames=output_fieldnames, extrasaction='ignore', lineterminator=os.linesep)

    writer.writeheader()
    for row in nextclade_data:
        for key in version_keys:
            row[key] = dataset_version[key]
        try:
            writer.writerow(row)
        except BrokenPipeError as e:
            pass

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--nextclade-tsv', required=True)
    parser.add_argument('--nextclade-dataset-version', required=True)
    args = parser.parse_args()
    main(args)