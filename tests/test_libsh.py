import os
import uuid
import random
import subprocess
import threading

import unittest

from unittest.mock import patch
from tempfile import mkstemp


def bash(cmd: str):
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
        FOOOOOO='barrrrr',
        BARRRRR='bazzzzz',
        BAZZZZZ='foooooo'
    )

    def test_uuid(self):
        self.assertTrue(bash('uuid 32') is not '')

    def test_map(self):
        self.assertEqual(
            bash('map "echo" "FOOOOOO BARRRRR BAZZZZZ"'),
            'FOOOOOO BARRRRR BAZZZZZ'
        )

    def test_curry(self):
        self.assertEqual(
            bash('curry test echo "FOOOOOO=BARRRRR" &>/dev/null; test'),
            'FOOOOOO=BARRRRR'
        )

    def test_getLeft(self):
        self.assertEqual(bash('getLeft "=" "a=1"'), 'a')

    def test_getRight(self):
        self.assertEqual(bash('getRight "=" "a=1"'), '1')

    def test_getEnv(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('getEnv "FOOOOOO"'), 'barrrrr')

    def test_searchEnv(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('searchEnv BAR RRRR'),'BARRRRR=bazzzzz')

    def test_searchEnvKeys(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('searchEnv.Keys BAR RRRR'),'BARRRRR')

    def test_searchEnvValues(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(bash('searchEnv.Values BAR RRRR'),'bazzzzz')

    def test_defaultEnv(self):
        with patch.dict(os.environ, self.env):
            self.assertEqual(
                bash('defaultEnv "FOO,BARRRRR,TEST=12"; echo "${TEST}"'),
                'bazzzzz'
            )
            self.assertEqual(
                bash('defaultEnv "BARRRRR,NOT,TEST=12"; echo "${TEST}"'),
                'bazzzzz'
            )
            self.assertEqual(
                bash('defaultEnv "NOT,TON,TEST=12"; echo "${TEST}"'),
                '12'
            )


#class TestChecks(unittest.TestCase):
#    def get_port(self):
#        return random.randint(20000,22000)
#
#    def test_checkHttpCode(self):
#        port = self.get_port()
#        bash_thread(f'timeout 5 nc -lp {port} -c "echo HTTP/1.1 200 OK\n\n"')
#        self.assertEqual(bash(f'checkHttpCode 200,localhost:{port}; echo $?'),'0')
#        bash_thread(f'timeout 5 nc -lp {port} -c "echo HTTP/1.1 200 OK\n\n"')
#        self.assertEqual(bash(f'checkHttpCode 201,localhost:{port}; echo $?'),'1')
#
#    def test_checkTcp(self):
#        port = self.get_port()
#        bash_thread(f'timeout 45 nc -lp {port}')
#        self.assertEqual(bash(f'checkTcp localhost:{port}; echo $?'),'0')
#        self.assertEqual(bash(f'checkTcp localhost:{port}; echo $?'),'1')
#
#    def test_checkUdp(self):
#        port = self.get_port()
#        bash_thread(f'timeout 5 nc -ulp {port}')
#        self.assertEqual(bash(f'checkUdp localhost:{port}; echo $?'),'0')
#        self.assertEqual(bash(f'checkUdp localhost:{port}; echo $?'),'1')
#