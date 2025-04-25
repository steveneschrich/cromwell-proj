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