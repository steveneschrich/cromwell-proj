# Preparing Data for Import
To start cromwell workflows, one has to setup the relevant information. That
is a sample sheet. The format of the sample sheet (as a csv) is:

```
sample,library,readgroup,R1,R1_md5,R2,R2_md5
```
The sample is a group of libraries and readgroups. Typically, we have 1 or more readgroups associated with
a sample, however sometimes multiple libraries are used for sequencing. But generally, we use 'lib1' by convention. 
For readgroups, we use `rg1` and `rg2` for readgroups. The R1 and R2 fields are the path (relative to the project root)
for the fastq files. You can include md5 checksums or just leave the field blank (I usually leave it blank).

This process is often very manual and time-consuming, as it is trying to put whatever data is provided
into a flat, simple structure.