#!/usr/bin/env python3

import argparse
import json

def main(args):

    with open(args.nextclade_json, 'r') as f:
        nextclade_info = json.load(f)


    current_version_tag = nextclade_info["version"]["tag"]

    print('\t'.join(['nextcladeDatasetName', 'nextcladeDatasetVersion', 'nextcladeVersion']))
    print('\t'.join([args.dataset_name, current_version_tag, args.nextclade_version]))
    

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--nextclade_json')
    parser.add_argument('--dataset_name')
    parser.add_argument('--nextclade_version')
    args = parser.parse_args()
    main(args)
