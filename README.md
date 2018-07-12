# ResearchObject-Nextflow
Project to show the strutcture and the steps of the implementation of the ResearchObject into Nextflow.

All the work is being coded into the branch research-object of my nextflow fork 
[Pipeline Repository](https://github.com/edgano/nextflow/tree/research-object). 
To run the example just run the command ```./launch.sh run nextflow-io/rnatoy -with-docker -with-trace -with-prov```

We are using the [RNASeq-nf](https://github.com/nextflow-io/rnaseq-nf) pipeline as a example to identify the elements and the structure of the RO.

## Diagram
After identify the elements and the interactions, it will be a fisrt approach for us case.

![Pipeline Diagram](https://github.com/edgano/researchObject-Nextflow/blob/master/images/RNASeq-nf.jpg)

XML: https://drive.google.com/file/d/1EMhjxsD18PdyhmtK1ZxLg_8wZ1z3sWEe/view?usp=sharing

## Files Structure
We believe the folder/file structure has to look like this:

![File Structure](https://github.com/edgano/researchObject-Nextflow/blob/master/images/fileStructure.png)


Being the content of the files as follow:

* .ro
  * annotations
    * metadata.xml -> software version, command line "snapshot"
  * manifest.json -> containing author's,  project date, change's log
* workflow
  * bin -> nextflow "working" directory
    * main.nf
    * nextflow.config
  * mimetype
  * visualitation.png -> pipeline graph

## File structure V2
Trying to define the correct structure of the RO, I have this new version of the files tree and the content of them
![Structure v2](https://files.gitter.im/privateEdgano/Lobby/LRY8/thumb/image.png)

## File structure V2.1
After the BOSC 2018 in Portal, and thanks to some CWL&RO posters. We decide to move to a similar structure. Avoiding big differences between RO zip files between CWL and Nextflow.
![Structure v2.1](https://files.gitter.im/privateEdgano/Lobby/NnQB/image.png)

The files inside the orange square are the nextflow directory. ```main.nf``` is the main scrip file and the ```nextflow.config``` is the configuration file for the pipeline. Then the ```bin``` folder is an example of an optional/extra files.

manifest.json
```
{ "@id": "/",
  "@context": ["https://w3id.org/bundle/context"],
 "author": "authorFoo"
 "description": "manifest description foo"
 "date": <DATE of creation>
  "aggregates": [
    "/paper.pdf",
    "githubID/data",
    "githubID/bin",
    "github/main.nf"
  ]
}
```
metadata.xml
```
{ "@id": "/",
  "@context": ["https://w3id.org/bundle/context"],
  "container_technology": "Docker"  //Docker/Singularity/Not container used
  "container_sha": "f7a60a2f83b7e98db6f45034c94541901e270cafdc8e1f9ae4cd5a2b7edd039c"   //<SHA256>/Not container used
  "container_name":"nextflow/rnatoy@sha256:9ac0345b5851b2b20913cb4e6d469df77cf1232bafcadf8fd929535614a85c75"  //<container_name>/Not container used
  "UUID": "2961a607-7a96-43ae-82c6-27eb0892fd1d"   //nextflow execution UUID
  "commandLine":"run nextflow-io/rnatoy -with-docker -with-trace -with-prov -resume"
  "nextflow_version":"0.29.0.5367"
}
```
provenance.json
```
{
  "wasGeneratedBy": {
    "NF:generatedBy_1_/home/edgar/CBCRG/nextflow/work/2e/2969be0f03561e68e4ce0c13d689f0/genome.index.1.bt2": {
      "prov:entity": "NF:/home/edgar/CBCRG/nextflow/work/2e/2969be0f03561e68e4ce0c13d689f0/genome.index.1.bt2",
      "prov:role": {
        "$": "",
        "type": "xsd:string"
      },
      "prov:activity": "NF:activity_1"
    },
...
"activity": {
    "NF:activity_1": {
      "prov:type": {
        "$": "ActivityType",
        "type": "NF:process"
      },
      "prov:label": "buildIndex (ggal_1_48850000_49020000.Ggal71.500bpflank)"
    },
...
```
log.txt
```
<DATE> -- author -- --<UUID> -- <image SHA>
06/07/2018 15:03:07 -- AuthorFoo -- 2961a607-7a96-43ae-82c6-27eb0892fd1d --f7a60a2f83b7e98db6f45034c94541901e270cafdc8e1f9ae4cd5a2b7edd039c
...
```

## Input/Output code
The structure of the I/O is the following:

They will be entities ![Entity](https://github.com/edgano/researchObject-Nextflow/blob/master/images/entity.jpg)

The definition of an **Entity** allow us to have:
* ID : ```NF_prov:{}<FILE_PATH>```
* Properties:
  * other: Interface for PROV objects that have **non-PROV** attributes -> _my idea is to have extra info here_
  * **value**: Direct representation of an entity ```<value=<file_name>; type=prov:{http://www.w3.org/ns/prov#}value>```
  * kind: ```PROV_ENTITY```
  * type: Provides further typing information for any construct with an optional set of attribute-value pairs (file,URI,int...) ?checksum, size?
  ```
  org.openprovenance.prov.xml.Type@525692af[  value=URI_Foo  type='xsd:{http://www.w3.org/2001/XMLSchema#}anyURI'], 
  org.openprovenance.prov.xml.Type@1dda70c4[  value=checksumFOO  type='NF_prov:{http://www.Workflow_REPO.org}checksum'], 
  org.openprovenance.prov.xml.Type@2ec90447[  value=sizeFoo  type='NF_prov:{http://www.Workflow_REPO.org}fileSize'], 
  org.openprovenance.prov.xml.Type@5b9a9530[  value=fileFoo  type='NF_prov:{http://www.Workflow_REPO.org}objectType']'
  ```
  * class: ```class org.openprovenance.prov.xml.Entity```
  * label: Provides a human-readable representation, and we can have has many labels as we want. ```value=labelFOO; lang=ENG```
  * location: A location can be an identifiable geographic place (ISO 19112), but it can also be a non-geographic place such as a directory, row, or column. Personally I dont see it usefull, we already have the path on the ID
  
*Example* ```entity(NF:/home/edgar/CBCRG/nextflow/work/0f/c188d4d568b1c49d7b510f36598f48/transcript_ggal_liver.gtf,[prov:value = "transcript_ggal_liver.gtf" %% prov:value])```

Next element is the **Activity** , in our case they will be the Process
The definition of this element allow us to capture:
* ID: ```NF:activity_<task_id>``` this decision is becasue the task_id is unique for each process, then it will made the activity id unique too.
* Type: ```process``` make it open if in the future we can identify more activites not just _process_
* Label: ```<task_name>``` being able to identify with activity is part of wich process. (make it more readable for humans)

*Example* ```activity(NF:activity_3,-,-,[prov:type = "ActivityType" %% NF:process, prov:label = "mapping (ggal_liver)"])```

Another task done is the **Used** and **wasGeneratedBy** relations.
Being the main relations between the input/output files and the processes.
When a process consume a file, it generates a **used** relationship. And when the process makes a file it is generated a **wasGeneratedBy** relation between the process and the output file.

## Dummy Real Example
Full version of the file can be found here: https://github.com/edgano/researchObject-Nextflow/blob/master/docs/RnaToyPROV.json
```
"wasGeneratedBy": {
    "NF:generatedBy_1_/home/edgar/CBCRG/nextflow/work/2e/2969be0f03561e68e4ce0c13d689f0/genome.index.1.bt2": {
      "prov:entity": "NF:/home/edgar/CBCRG/nextflow/work/2e/2969be0f03561e68e4ce0c13d689f0/genome.index.1.bt2",
      "prov:role": {
        "$": "",
        "type": "xsd:string"
      },
      "prov:activity": "NF:activity_1"
    },
.....
 "activity": {
    "NF:activity_1": {
      "prov:type": {
        "$": "ActivityType",
        "type": "NF:process"
      },
      "prov:label": "buildIndex (ggal_1_48850000_49020000.Ggal71.500bpflank)"
    },
....
"used": {
    "NF:used_1_/home/edgar/.nextflow/assets/nextflow-io/rnatoy/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa": {
      "prov:entity": "NF:/home/edgar/.nextflow/assets/nextflow-io/rnatoy/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa",
      "prov:activity": "NF:activity_1"
    },
....
"entity": {
    "NF:/home/edgar/.nextflow/assets/nextflow-io/rnatoy/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa": {
      "prov:value": {
        "$": "ggal_1_48850000_49020000.Ggal71.500bpflank.fa",
        "type": "prov:value"
      }
    },
    "NF:/home/edgar/CBCRG/nextflow/work/2e/2969be0f03561e68e4ce0c13d689f0/genome.index.1.bt2": [
      {
        "prov:value": {
          "$": "genome.index.1.bt2",
          "type": "prov:value"
        }
      },
      {
        "prov:value": {
          "$": "genome.index.1.bt2",
          "type": "prov:value"
        }
      }
    ],

```
Meaning that the entity(file) ```NF:/home/edgar/CBCRG/nextflow/work/2e/2969be0f03561e68e4ce0c13d689f0/genome.index.1.bt2``` was created by the activity ```NF:activity_1```, and we knwo that it is the process ```buildIndex (ggal_1_48850000_49020000.Ggal71.500bpflank)```.
Then we can see how _activity_1_ has consumed the entity(file) ```NF:/home/edgar/.nextflow/assets/nextflow-io/rnatoy/data/ggal/ggal_1_48850000_49020000.Ggal71.500bpflank.fa```


## Next Steps
~~Next steps will be to start saving the file with the structure we have defined before~~
~~generate the sha for the files. Then we will clean the code and use ```Enum``` for the PROV-Types.~~
Refactor code to make it as a tool

Implement Agent with container's info


## RO Bundle
[Tutorial](https://github.com/ResearchObject/ro-tutorials/tree/master/01-creating)

To generate the RO bundle we need to create first the mimetype for the RO
```
echo -n application/vnd.wf4ever.robundle+zip > mimetype
zip -0 -X example.bundle.zip mimetype
```
Then, we will add the files to the zip bundle using the following command:
```
zip example.bundle.zip rawdata5.csv paper3.pdf analyse2.py .ro/manifest.json
```
For the manifest, it will looks like:
```
{
    "@context": [
        {
            "@base": "arcp://uuid,66b766de-b56a-49de-9246-8a8c3ba1d0a2/metadata/"
        }, 
        "https://w3id.org/bundle/context"
    ], 
    "id": "/", 
    "manifest": "manifest.json", 
    "createdOn": "2018-04-05T06:22:36.552110", 
    "createdBy": {
        "uri": "urn:uuid:36dd58bb-b50f-4774-9fbe-aeffc7234ae6", 
        "name": "cwltool 1.0.20180404035408"
    }, 
    "aggregates": [
        {
            "uri": "urn:hash::sha1:f650cc2571ee262d625d2e6c8ec91ec9880fe61b", 
            "bundledAs": {
                "folder": "/data/f6/", 
                "uri": "arcp://uuid,66b766de-b56a-49de-9246-8a8c3ba1d0a2/data/f6/f650cc2571ee262d625d2e6c8ec91ec9880fe61b", 
                "filename": "f650cc2571ee262d625d2e6c8ec91ec9880fe61b"
            }
        }, ...
```
**QUESTION:** Do we need to list **ALL** the files? --> The same Bundle capture them


After that, we will move to the next milestone, capture author information, container hash, ...

To implement the PROV into NF, we are using Prov-DM and [ProvToolBox](http://lucmoreau.github.io/ProvToolbox/)

# Steps

- [x] Files Structure Moockup
- [x] Identify elements (Activity/Entity)
- [x] Input/Output NF 
- [x] Get critical data -> author, container hash 
- [ ] Get container's software version
- [x] Automatic relation identification
- [x] Generate RO Object
- [ ] Refactor code to implement as a tool -- **under development**
- [ ] Implement AGENT object (to save container's info)
- [ ] Generate Snapshot content -> reRun.sh (relative path??)
- [ ] Find a way to KNOW the final output folder -- **HELP NEEDED**
- [ ] Find a way to KNOW the software version -> include a auxFile written by the user? -- **HELP NEEDED**
- [ ] Test and Documentation
