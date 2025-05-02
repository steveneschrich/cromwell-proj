# Backend Configuration
In cromwell, launching jobs is handled by a specific backend. This is arguably the most important aspect of the cromwell execution engine as it orchestrates launching jobs, localizing files and monitoring completion. And if you think about it, cromwell has to manage doing this from a bash command line, docker/singularity/apptainer, cluster (slurm, pbs, etc), google cloud, and others. So it can be very complex.

This directory contains a series of different backends pre-defined. Where possible, reasonable defaults are selected relative to each platform. However, customization is certainly possible (and likely).

The organization of a backend configuration is roughly grouped as:

- submission: how to go from a task command block to a process/job
- configuration: directories, operating characteristics, other settings for builtin functionality
- filesystem: how to manage the filesystem (localizing files, caching, etc)

## Job Submissions
A task can define some `runtime-attributes` for execution hints. These attributes can be combined with any defined here (or elsewhere in the config files as `default-runtime-attributes`) in order to successfully execute the job. This all comes together in the form of a `submit` definition within the backend. The submit definition is a string that combines runtime attributes, job information and your own knowledge of your backend to create a run script. So in the simplest case (Local), submit would be:
```hocon
submit = "/usr/bin/env bash ${script}"
```

As you can see, there are builtin variables (like `script`) which are defined by cromwell when setting up a task. And then there are others that you can set (e.g., `docker` for docker container url). It is not entirely clear to me what language is being used for this string that is created, however the examples show there is some flexibility. In particular, this link (https://cromwell.readthedocs.io/en/develop/tutorials/Containers/#docker) indicates a typical shell script.

Some things to note about configuring submissions:

- You can create new runtime variables and hook them into the submission. For instance, I created a `docker-volumes` variable that I connect to the `docker run` command. Then in tasks (or inputs.json) you can add a `docker-volumes` variable. 
- Whatever the language is, it allows for WDL task syntax to include a command line argument only if the runtime variable exists: `${"--user " + docker_user}`. This can be useful for those options parameters that could be included.

## Configuration

## Filesystems
A note about filesystems. For most of our examples, we use the `SFS` filesystem which is the `Shared File System`. This just means that all tasks, etc will use the same filesystem so there is an assumption that the structure, etc is the same task to task. Other backends have different filesystems that do not behave like a shared filesystem, so need extra things. Our case is some variation of a shared folder (e.g., common NFS filesystem). 

The biggest consideration (for me) in the filesystem is the localization strategy. There are a ton of isolated directories that are created for task execution. Inputs are connected to the task and outputs have to be made available to following tasks. So how to manage all of these files?

The simplest strategy would be to copy input files to the tasks input directory, then copy the output files to the following task's input directory. That would consume a huge amount of disk space. Not a great approach, although it would definitely work. That is the `localization` strategy `copy`: 
```
localization: "copy"
```

Another approach would be to use symbolic links. This makes the most sense, since it costs very little to "copy" a file around; you simply make another link which contains the path of the original file (tens of bytes rather than TB!). That is the `localization` strategy `soft-link`. There is a problem with this, however. Generally, a docker container cannot see any of the filesystems of the docker host so if tasks are running inside docker containers they cannot follow the symbolic link. However, there is now a flag 
```
docker.allow-soft-links: true
```

that can be used with `localization: "soft-link"` to make this work with docker containers. The backends here utilize this strategy.

The final approach is hard links. These are distinct from soft links and basically use the same filesystem information for two different files. Since they point to specific file info data structures (not filenames), they can be used inside of docker or outside. The problem that we have seen in practice is that filesystems keep track of hard links to a file and there is a limit on the total number of hard links to a file. So there are occasions in which you cannot make any more hard links to a file, forcing a copy. 