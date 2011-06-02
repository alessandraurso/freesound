#!/usr/bin/env python
'''
This script walks the Freesound analysis directory and creates
a Gaia dataset with all the files it finds.
'''

import os, sys, gaia2
from settings import INDEX_DIR, SIMILARITY_MINIMUM_POINTS
from gaia_wrapper import GaiaWrapper

counter = 0
dataset = False

def prepare_dataset(dir, target):
    global dataset
    dataset = gaia2.DataSet()
    os.path.walk(dir, walk_func, False)
    dataset.save(target)


def walk_func(arg, dirname, names):
    """arg is unused but required for os.path.walk"""
    global counter
    for name in names:
        path = os.path.join(dirname, name)
        basename, ext = os.path.splitext(name)
        if os.path.isfile(path) and ext == '.yaml':
            handle_resource(path, basename)
            # progress counter
            counter += 1
            if counter % 100 == 0:
                print 'Processed %s yamls' % counter


def handle_resource(path, name):
    global dataset
    p = gaia2.Point()
    p.load(path)
    p.setName(name.split('_')[0])
    dataset.addPoint(p)
    if dataset.size() == SIMILARITY_MINIMUM_POINTS:
        dataset = GaiaWrapper.prepare_original_dataset_helper(dataset)


if __name__ == '__main__':
    prepare_dataset('/home/fsweb/freesound-data/analysis/', os.path.join(INDEX_DIR, 'orig.db'))
    create_directory()
    gaia_wrapper = GaiaWrapper()
