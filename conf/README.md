# Cromwell Configuration
This directory (`conf`) represents the configuration files needed for cromwell to execute. There are a couple of places where configuration for cromwell execution is defined: application-level and workflow options. And unfortunately these are not always well documented and they do appear to require two slightly different syntaxes. And perhaps they overlap (with workflow options overriding the application-level). The contents below are a discussion of the files and aspects of these files.

# TLDR;
Most of `conf/cromwell.conf` should be fairly static. Ideally you can modify things site-wide but otherwise you will want to override specific settings in `local.conf'.
Edit the `cromwell.conf` file to suit your purpose. It has fairly extensive documentation within it. Note that it will include files from the `backends` and
`db` directories, which can be selected for your specific purpose.

Edit the `workflow-options.json` file to suit your purpose. It also has extensive documentation (albeit in unusual format given it is a JSON file).

# Extended Configuration
There are three main types of configuration to consider. Logging, application-level and workflow options.

## Logging
Due to the way logging is handled in cromwell (and java), configuring the logging occurs separately (sort of). The variables are defined via java system properties (when the java call is invoked), as in `-DLOG_LEVEL=info`. See the file `../bin/cromwell-run` or `../bin/cromwell-server` for these settings. **However**, it's not that simple. The `cromwell.conf` file contains some logging configuration. There is a log level suitable for "pre-initialization" of the logging facility and log levels suitable for "post-initialization". In addition to the java arguments. It is not clear (to me), how these three different sets of settings interact.

## Application Level Configuration
There is a large number of variables that can be tuned within the cromwell application. Note that the application itself is written in scala but the configuration is specified in HOCON (see https://cromwell.readthedocs.io/en/stable/tutorials/ConfigurationFiles/ for details). It is a superset of JSON, but more human readable.

The number of configuration options is very large and we've created an annotated version here of some of the salient options (as of v88). If you are truly daring, you can extract the `reference.conf` from your version of cromwell using the command:
```
jar xf lib/cromwell-88.jar reference.conf
```

Note that there are two subdirectories in `conf`: `backends` and `db`. This is because there are various different configurations that are possible. In the case of database configurations, it appears that the one you define is the one that is used. So, in the `cromwell.conf` file one would pick the specific `db` directory include to use (currently, `hsqldb_file.conf` or `hsqldb_mem.conf`). See comments about choosing from within the `cromwell.conf` file. In the case of `backends`, one or more runners are possible (Local, slurm, docker, podman, slurm-podman, etc, etc). Include the backends that make sense for your specific conditions.

## Workflow Options
These are options that partly overlap with system settings but can be configured for specific workflow runs. These are required to use JSON syntax (unlike application settings), although some of the parameters appear to overlap. Therefore the syntax differs for the same settings.

Included in this directory is a `workflow-options.json` file. This is an annotated file with as many workflow options that I could find on the cromwell site. Most parameters are prefixed with an `_`, thereby disabling the setting. To use the parameter, remove the `_` and set the parameter.

# Default Setting
The standard options defined here within the current version of configured files includes:

- use the Local backend
- use the hsqldb_file (file-backed) database
- copy workflow outputs to a `workflow-outputs` directory
- copy workflow logs to `workflow-logs` on successful completion


# yml2json

This directory is used to maintain a cache directory (../cache), both
of which can generally be ignored in normal operation. See below for 
details. 

TLDR; The `yml2json` and `cache` directory are internal functionality
that can generally be ignored.

The longer story: A make system is used to convert yml
configuration in the `conf` directory into json equivalents that are
required for input to cromwell (but harder for humans to read/comment).
The management of this is in `yml2json` and the results are in `cache`.


## Rationale
Much of the cromwell system takes either HOCON, which is a JSON derivative
that is supposed to be readable, or JSON, which is not terribly readable. In particular,
JSON provides no real mechansim for comments and HOCON is not consistently used 
throughout cromwell. Therefore, our solution is to use yml which is generally
a simpler structure and allows copious comments.

In order to implement yml as the standard configuration syntax, we have to
convert all of the yml into json for actual execution. That is where this 
directory comes in. The goal here is to create a `cache` directory which
is converted yml2json such that json can be directly imported into the
system. Both the conf/system configuration and the bin/ scripts support
using this approach. Assuming the system works as designed, there is 
little to no reason to explore this directory.

## Process
A makefile is included in this directory that will pick up any yml in the
parent directory and make it into json in the cache directory. There is
a tool (yq) that can perform this. However, not knowing whether
or not yq is installed (it appears to often not be), we use
apptainer to wrap the execution of yq. Therefore apptainer (and
internet access) become requirements for cromwell.

If one were to manually execute the process in this directory, one
starts by running 'make' (assuming make is installed). This will
find yml files in the parent directory. If the corresponding json
file in the `cache` directory is out of date (relative to the yml file),
it is remade using the 'yq' script (which itself calls apptainer to
execute the command).

This build process is done by the bin/cromwell-* scripts via
a (cd conf/yml2json && make) command which should generate
the needed files. The other aspects of cromwell scripts and/or
conf files use these json files by default.