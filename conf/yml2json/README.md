# yml2json

This directory is primarily a cache directory which can generally be
ignored in normal operation. A make system is used to convert yml
configuration in the parent directory in json equivalents here
as cached versions for use in cromwell.

## Rationale
Much of the cromwell system takes either HOCON, which is a JSON derivative
that is supposed to be readable, or JSON, which is not terribly readable. In particular,
JSON provides no real mechansim for comments and HOCON is not consistently used 
throughout cromwell. Therefore, our solution is to use yml which is generally
a simpler structure and allows copious comments.

In order to implement yml as the standard configuration syntax, we have to
convert all of the yml into json for actual execution. That is where this 
directory comes in. The goal here is to create a "shadow" directory which
is converted yml2json such that json can be directly imported into the
system. Both the conf/system configuration and the bin/ scripts support
using this approach. Assuming the system works as designed, there is 
little to no reason to explore this directory.

## Process
A makefile is included in this file that will pick up any yml in the
parent directory and make it into json in this directory. There is
a tool (yq) that can perform this. However, not knowing whether
or not yq is installed (it appears to often not be), we use
apptainer to wrap the execution of yq. 

If one were to manually execute the process in this directory, one
starts by running 'make' (assuming make is installed). This will
find yml files in the parent directory. If the corresponding json
file in this directory is out of date (relative to the yml file),
it is remade using the 'yq' script (which itself calls apptainer to
execute the command).

This build process is done by the bin/cromwell-* scripts via
a (cd conf/yml2json && make) command which should generate
the needed files. The other aspects of cromwell scripts and/or
conf files use these json files by default.