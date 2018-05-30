# ResearchObject-Nextflow
Project to show the strutcture and the steps of the implementation of the esearchObject ito Nextflow.

We are using the RNASeq-nf (https://github.com/nextflow-io/rnaseq-nf) pipeline as a example to identify the elements and the structure of the RO.

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

## Input/Output code
The structure of the I/O is the following:

They will be entities ![Entity](https://github.com/edgano/researchObject-Nextflow/blob/master/images/entity.jpg)

```
for (element in inputList){
    Path path = Paths.get(element);
    def element_name = path.getFileName()
    
    Entity input_element = pFactory.newEntity(qn(element_name.toString()))
    //asume it is a file
    input_element.setValue(pFactory.newValue("file",pFactory.getName().PROV_TYPE));
    input_element.setValue(pFactory.newValue("${element_name}", pFactory.getName().PROV_VALUE))
}
```
The definition of an **Entity** allow us to have:
* ID : ```NF_prov:{http://www.Workflow_REPO.org}<FILE_NAME>```
* Properties:
  * other: Interface for PROV objects that have **non-PROV** attributes -> _my idea is to have extra info here_
  * value: Direct representation of an entity ```<value=file_name; type=prov:{http://www.w3.org/ns/prov#}value>```
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
  * location: A location can be an identifiable geographic place (ISO 19112), but it can also be a non-geographic place such as a directory, row, or column **?PATH??**

To implement the PROV into NF, we are using Prov-DM and ProvToolBox http://lucmoreau.github.io/ProvToolbox/

# Steps

- [x] Files Structure Moockup
- [x] Identify elements (Activity/Entity)
- [ ] Input/Output NF development
- [ ] Get critical data -> author, container hash
- [ ] Get container's software version
- [ ] Automatic relation identification
- [ ] Generate RO Object
