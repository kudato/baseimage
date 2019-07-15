import os
import uuid
import subprocess
import threading

import unittest

from unittest.mock import patch
from tempfile import mkstemp


def bash(cmd: str, env=os.environ.copy()):
    return subprocess.run(
        'source scripts/lib.sh; ' + cmd,
        shell=True,
        executable='/bin/bash',
        capture_output=True
    ).stdout.decode('utf-8').strip('\n')


def bash_thread(cmd):
    thread_func = lambda: bash(cmd)
    thread = threading.Thread(target=thread_func)
    thread.start()
    return thread


def external_script(body: str, test_func):
    try:
        fd, path = mkstemp(suffix='.sh')
        with open(fd, 'w') as f:
            f.write(body)
        test_func(path)
    finally:
        os.remove(path)


class TestExec(unittest.TestCase):
    def test_runFile(self):
        external_script('exit 0',
            lambda path: self.assertEqual(
                bash(f'runFile "{path}"'),
                f'0|{path}:SUCCESS'
            )
        )

    def test_bgStart(self):
        self.assertIsInstance(
            int(bash('bgStart sleep 1')),int)

    def test_bgWait(self):
        self.assertEqual(
            int(bash(
                '''
                bgStart sleep 1 &>/dev/null;
                bgWait;echo "${BG_TASKS_EXITCODES}"
                '''
            )),0)



class TestFunctions(unittest.TestCase):
    env = dict(
        FOO='bar',
        BAR='baz',
        BAZ='foo'
    )

    def test_uuid(self):
        self.assertTrue(bash('uuid 32') is not '')

    def test_map(self):
        self.assertEqual(
            bash('map "echo" "FOO BAR BAZ"'),
            'FOO BAR BAZ'
        )

    def test_curry(self):
        self.assertEqual(
            bash('curry test echo "FOO=BAR" &>/dev/null; test'),
            'FOO=BAR'
        )

    def test_getLeft(self):
        self.assertEqual(bash('getLeft "=" "a=1"'), 'a')

    def test_getRight(self):
        self.assertEqual(bash('getRight "=" "a=1"'), '1')

    def test_getEnv(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('getEnv "FOO"'), 'bar')

    def test_filterEnv(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('filterEnv BA R'),'BAR=baz')

    def test_filterEnvKeys(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('filterEnvKeys BA R'),'BAR')

    def test_filterEnvValues(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('filterEnvValues BA R'),'baz')

    def test_defaultEnv(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(
                bash('defaultEnv "FOO,BAR,TEST=12"; echo "${TEST}"'),
                'baz'
            )
            self.assertEqual(
                bash('defaultEnv "BAR,NOT,TEST=12"; echo "${TEST}"'),
                'baz'
            )
            self.assertEqual(
                bash('defaultEnv "NOT,TON,TEST=12"; echo "${TEST}"'),
                '12'
            )


class TestChecks(unittest.TestCase):
    def test_checkHttpCode(self):
        bash_thread('timeout 5 nc -lp 23456 -c "echo HTTP/1.1 200 OK\n\n"')
        self.assertEqual(bash('checkHttpCode 200,localhost:23456; echo $?'),'0')
        bash_thread('timeout 5 nc -lp 23456 -c "echo HTTP/1.1 200 OK\n\n"')
        self.assertEqual(bash('checkHttpCode 201,localhost:23456; echo $?'),'1')

    def test_checkTcp(self):
        bash_thread('timeout 5 nc -lp 23456')
        self.assertEqual(bash('checkTcp localhost:23456; echo $?'),'0')
        self.assertEqual(bash('checkTcp localhost:23456; echo $?'),'1')

    def test_checkUdp(self):
        bash_thread('timeout 5 nc -ulp 23456')
        self.assertEqual(bash('checkUdp localhost:23456; echo $?'),'0')
        self.assertEqual(bash('checkUdp localhost:23456; echo $?'),'1')
