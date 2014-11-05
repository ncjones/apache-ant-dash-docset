Apache Ant Dash Docset Generator
================================

This project builds a [Dash](1) or [Zeal](2) docset for the [Apache Ant](3)
user manual.


Building
--------

 1. Get the Apache Ant source:

        $ git submodule init && git submodule update

 2. Make sure sqlite3 is installed

 3. Build the docset:

        $ ./build.sh


Installing
----------

To install the built docset to the user's Zeal docsets dir run:

    $ ./install.sh


[1]: http://kapeli.com/dash
[1]: http://zealdocs.org/
[3]: https://ant.apache.org/
