#!/usr/bin/env python

import os
import sys

from enum import Enum
from functools import reduce
from shutil import copy2 as copy


class Drone(Enum):
    Pipeline = lambda x='.drone.yml': f'{x}'
    Head = lambda: \
f'''
kind: pipeline
name: Publish to Docker Hub

steps:
- name: Make
  image: python:3.7-alpine3.9
  commands:
  - chmod +x make.py && ./make.py
'''

    When = lambda: \
'''
  when:
    branch:
    - master


# ---------------------------------
'''

    Build = lambda x, y:\
f'''
- name: {y}
  image: plugins/docker
  settings:
    repo: kudato/baseimage
    dockerfile: {x}
    username:
      from_secret: docker_username
    password:
      from_secret: docker_password
    tags:
'''

    Tags = lambda z: reduce(lambda x,y: x+y,
            map(lambda a: '      - '+ a +'\n',z))



class Dockerfile:
    tmpl = Drone

    def __init__(self, file, t='w'):
        self.dockerfile = file
        self.tags = ('latest', self.os.split(':')[1])
        self.write(self.tmpl.Head() + self.tmpl.When(),
                   self.tmpl.Pipeline(), t)
        self.create('Dockerfile', self.os, self.tags)

    def __rshift__(self, conf):
        self.create(f'.images/{conf[1][0]}/Dockerfile',conf[0],conf[1])
        return self

    @property
    def os(self):
        return self.readline(self.dockerfile)[5:15]

    def create(self, path, from_, tags):
        self.create_pipeline(path, tags)
        if path != self.dockerfile:
            copy(self.dockerfile, self.create_dir(path))
            self.write(self.read(path).replace(
                                        f'FROM {self.os}',
                                        f'FROM {from_}'),
                                        path)

    def create_pipeline(self, path, tags):
        self.write(
            (
                self.tmpl.Build(path, tags[0]) \
                    + self.tmpl.Tags(tags) \
                    + self.tmpl.When()
            ),
            self.tmpl.Pipeline(), 'a'
        )

    def read(self, file):
        with open (file, 'r') as f:
            return f.read()

    def readline(self, file):
        with open (file, 'r') as f:
            return f.readline()

    def write(self, data, file, t='w'):
        with open (file, t) as f:
              f.write(data)

    def create_dir(self, file_path):
        directory = os.path.dirname(file_path)
        if not os.path.exists(directory):
            os.makedirs(directory)
        return file_path


if __name__ == "__main__":
    if not sys.version >= '3.6.8':
        raise RuntimeError(f'{sys.version} is wrong version')

    Dockerfile('Dockerfile') \
         >> (
                'python:3.7-alpine3.9',
                (
                    'python-3.7',
                    'python-3.7-alpine3.9',
                    'python'
                )
            ) \
         >> (
                'python:3.6-alpine3.9',
                (
                    'python-3.6',
                    'python-3.6-alpine3.9'
                )
            ) \
         >> (
                'php:7.3-cli-alpine3.9',
                (
                     'php-cli-7.3',
                     'php-cli-7.3-alpine3.9',
                     'php-cli'
                 )
            ) \
         >> (
                'php:7.3-fpm-alpine3.9',
                (
                    'php-fpm-7.3',
                    'php-fpm-7.3-alpine3.9',
                    'php-fpm'
                )
            ) \
         >> (
                'php:7.2-cli-alpine3.9',
                (
                    'php-cli-7.2',
                    'php-cli-7.2-alpine3.9'
                )
            ) \
         >> (
                'php:7.2-fpm-alpine3.9',
                (
                    'php-fpm-7.2',
                    'php-fpm-7.2-alpine3.9'
                )
            ) \
         >> (
                'node:6.17-alpine',
                (
                    'node-6.17',
                    'node-6.17-alpine3.9'
                )

            ) \
         >> (
                'node:8.16-alpine',
                (
                    'node-8.16',
                    'node-8.16-alpine3.9'
                )

            ) \
         >> (
                'node:10.15-alpine',
                (
                    'node-10.15',
                    'node-10.15-alpine3.9',
                    'node',

                )

            ) \
         >> (
                'node:11.15-alpine',
                (
                    'node-11.15',
                    'node-11.15-alpine3.9'
                )

            ) \
         >> (
                'node:12.1-alpine',
                (
                    'node-12.1',
                    'node-12.1-alpine3.9'
                )

            )

