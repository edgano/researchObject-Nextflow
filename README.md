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

~~ ## Files Structure
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
![Structure v2](https://files.gitter.im/privateEdgano/Lobby/7bNX/image.png)

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
 "container_sha": ""
"container_name":""
"commandLine":""
"nextflow_version":""
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
<DATE> -- author -- <image SHA>
<DATE> -- author -- <image SHA>
<DATE> -- author -- <image SHA>
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

### TODO Activity Object
~~convert time (start/End) to include in ```getStartTime()``` and ```getEndTime()```~~

## Next Steps
Next steps will be to start saving the file with the structure we have defined before, ~~generate the sha for the files. Then we will clean the code and use ```Enum``` for the PROV-Types.~~

After that, we will move to the next milestone, capture author information, container hash, ...

To implement the PROV into NF, we are using Prov-DM and [ProvToolBox](http://lucmoreau.github.io/ProvToolbox/)

# Steps

- [x] Files Structure Moockup
- [x] Identify elements (Activity/Entity)
- [x] Input/Output NF 
- [ ] Get critical data -> author, container hash -- **under development**
- [ ] Get container's software version
- [ ] Automatic relation identification
- [ ] Generate RO Object
