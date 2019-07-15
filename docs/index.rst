.. baseimage documentation master file, created by
   sphinx-quickstart on Mon Jul 15 01:14:29 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

=====================
Welcome to baseimage!
=====================

.. _GitHub: https://github.com/kudato/baseimage

.. _tini: https://github.com/krallin/tini

.. _su-exec: https://github.com/ncopa/su-exec

.. _Vault: https://www.vaultproject.io/docs/secrets/kv/index.html

This project is a wrapper for other base images
that adds some features:

- Runs via tini_ and su-exec_ as non-root user;
- Loading environment variables from Vault_ KV.
- Init scripts with additional functions;
- Customizable healthchecks HTTP, TCP, UDP, Sockets, Pidfiles and via custom scripts;
- Configuring via environment vars.


Is designed to be an lightweight, ready-to-use base for various docker images.


Source code
===========

The project is hosted on GitHub_

Please feel free to file an issue on the `bug tracker
<https://github.com/kudato/baseimage/issues>`_ if you have found a bug
or have some suggestion in order to improve the image.


Authors and License
===================

The ``baseimage`` is written by Alexander Shevchenko.

It's *MIT* licensed and freely available.
