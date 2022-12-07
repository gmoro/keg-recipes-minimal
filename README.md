keg-recipes
===========

This repository contains recipes that can be used to generate [kiwi](https://github.com/OSInside/kiwi) image descriptions using
[keg](https://github.com/SUSE-Enceladus/keg).

This repository has for now the definition used to build SUSE [ALP](https://build.opensuse.org/package/show/SUSE:ALP/ALP)
Details about how changes are applied are provided in CONTRIBUTING.md

Basics
======

Keg recipes contain two types of input data, the image recipe in the `images`
sub directory and the image data in the `data` sub directory. The recipe and data configuration is
in YAML format.

The configuration data used is collected by keg from the image recipe and the data bits referenced by the recipe.

Keg merges the input data in a way that allows to mix and match configuration
bits to create a specific image description. This can be used to create a large
number of different image descriptions based on the input configuration without
the need to edit them directly.

Structure
=========

Image recipes
-------------

A recipe defines the image's base parameters and one or more build profiles. Any
leaf directory under `image` acts as the input parameter for keg. Keg will
read any YAML file in that directory and merge it with all YAML files of its
parent directories. This allows to e.g. define global defaults in the top level
directory, product specific defaults in a directory below that, and all bits
unique to the image in the leaf directories.

Image data
----------

The `data` sub directory contains sets of parameters that form logical blocks
of configuration data. The `base` sub directory contains blocks for building
the OS base of the image. 

