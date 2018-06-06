{
    "cwlVersion": "v1.0", 
    "$graph": [
        {
            "class": "CommandLineTool", 
            "hints": [
                {
                    "dockerPull": "biocontainers/clustal-omega", 
                    "class": "DockerRequirement"
                }, 
                {
                    "packages": [
                        {
                            "package": "clustalo", 
                            "specs": [
                                "https://identifiers.org/rrid/RRID:SCR_001591"
                            ]
                        }
                    ], 
                    "class": "SoftwareRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#clustalo.cwl/multi_sequence"
                }
            ], 
            "outputs": [
                {
                    "type": "stdout", 
                    "label": "Multiple sequence alignment", 
                    "id": "#clustalo.cwl/alignment"
                }, 
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "$(inputs.multi_sequence.nameroot).ph"
                    }, 
                    "id": "#clustalo.cwl/guide_tree"
                }
            ], 
            "baseCommand": "clustalo", 
            "arguments": [
                "-i", 
                "$(inputs.multi_sequence.path)", 
                "--guidetree-out", 
                "$(inputs.multi_sequence.nameroot).ph", 
                "--threads", 
                "$(runtime.cores)"
            ], 
            "id": "#clustalo.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "hints": [
                {
                    "dockerPull": "bionode/paml", 
                    "class": "DockerRequirement"
                }, 
                {
                    "listing": [
                        {
                            "entryname": "paml0-3.ctl", 
                            "entry": "seqfile  = $(inputs.sequences.path)\ntreefile = $(inputs.tree.path)\noutfile = results0-3.txt   * main result file name\nnoisy = 9        * 0,1,2,3,9: how much rubbish on the screen\nverbose = 1      * 1:detailed output\nrunmode = 0      * 0:user defined tree\nseqtype = 1      * 1:codons\nCodonFreq = 2    * 0:equal, 1:F1X4, 2:F3X4, 3:F61\nmodel = 0        * 0:one omega ratio for all branches\n                 * 1:separate omega for each branch\n                 * 2:user specified dN/dS ratios for branches\nNSsites = 0 3 \nicode = 0        * 0:universal code\nfix_kappa = 0    * 1:kappa fixed, 0:kappa to be estimated\nkappa = 4        * initial or fixed kappa\nfix_omega = 0    * 1:omega fixed, 0:omega to be estimated\nomega = 5        * initial omega\n                 * RateAncestor = 1\nncatG = 3        * num. of categories in the dG or AdG models of rates\ngetSE = 0        * 0: don't want them, 1: want S.E.s of estimates\n"
                        }
                    ], 
                    "class": "InitialWorkDirRequirement"
                }, 
                {
                    "packages": [
                        {
                            "package": "paml", 
                            "specs": [
                                "https://identifiers.org/rrid/RRID:SCR_014932"
                            ]
                        }
                    ], 
                    "class": "SoftwareRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#codeml.cwl/sequences"
                }, 
                {
                    "type": "File", 
                    "id": "#codeml.cwl/tree"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "results0-3.txt"
                    }, 
                    "id": "#codeml.cwl/results"
                }
            ], 
            "baseCommand": [
                "codeml", 
                "paml0-3.ctl"
            ], 
            "id": "#codeml.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "hints": [
                {
                    "dockerImageId": "ubuntu-test", 
                    "class": "DockerRequirement"
                }, 
                {
                    "packages": [
                        {
                            "package": "pal2nal", 
                            "specs": [
                                "https://doi.org/10.1093/nar/gkl315"
                            ]
                        }
                    ], 
                    "class": "SoftwareRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "label": "nucleotide sequence", 
                    "id": "#pal2nal.cwl/nucleotides"
                }, 
                {
                    "type": "File", 
                    "label": "Multiple sequence alignment", 
                    "id": "#pal2nal.cwl/protein_alignment"
                }
            ], 
            "outputs": [
                {
                    "type": "stdout", 
                    "label": "Multiple sequence alignment", 
                    "id": "#pal2nal.cwl/alignment"
                }
            ], 
            "baseCommand": "pal2nal.pl", 
            "arguments": [
                {
                    "valueFrom": "paml", 
                    "prefix": "-output"
                }, 
                "$(inputs.protein_alignment.path)", 
                "$(inputs.nucleotides.path)"
            ], 
            "id": "#pal2nal.cwl"
        }, 
        {
            "class": "Workflow", 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#per_cluster_workflow.cwl/nucleotides"
                }, 
                {
                    "type": "File", 
                    "label": "proteins", 
                    "id": "#per_cluster_workflow.cwl/proteins_to_align"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#per_cluster_workflow.cwl/clustal/alignment", 
                    "label": "proteins alignment", 
                    "id": "#per_cluster_workflow.cwl/alignment1"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#per_cluster_workflow.cwl/pal2nal/alignment", 
                    "label": "nucleotides alignment", 
                    "id": "#per_cluster_workflow.cwl/alignment2"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#per_cluster_workflow.cwl/clustal/guide_tree", 
                    "label": "guide tree", 
                    "id": "#per_cluster_workflow.cwl/guide_tree"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#per_cluster_workflow.cwl/codeml/results", 
                    "label": "dN/dS results", 
                    "id": "#per_cluster_workflow.cwl/results"
                }
            ], 
            "steps": [
                {
                    "run": "#clustalo.cwl", 
                    "in": [
                        {
                            "source": "#per_cluster_workflow.cwl/proteins_to_align", 
                            "id": "#per_cluster_workflow.cwl/clustal/multi_sequence"
                        }
                    ], 
                    "out": [
                        "#per_cluster_workflow.cwl/clustal/alignment", 
                        "#per_cluster_workflow.cwl/clustal/guide_tree"
                    ], 
                    "id": "#per_cluster_workflow.cwl/clustal"
                }, 
                {
                    "run": "#codeml.cwl", 
                    "in": [
                        {
                            "source": "#per_cluster_workflow.cwl/pal2nal/alignment", 
                            "id": "#per_cluster_workflow.cwl/codeml/sequences"
                        }, 
                        {
                            "source": "#per_cluster_workflow.cwl/clustal/guide_tree", 
                            "id": "#per_cluster_workflow.cwl/codeml/tree"
                        }
                    ], 
                    "out": [
                        "#per_cluster_workflow.cwl/codeml/results"
                    ], 
                    "id": "#per_cluster_workflow.cwl/codeml"
                }, 
                {
                    "run": "#pal2nal.cwl", 
                    "in": [
                        {
                            "source": "#per_cluster_workflow.cwl/nucleotides", 
                            "id": "#per_cluster_workflow.cwl/pal2nal/nucleotides"
                        }, 
                        {
                            "source": "#per_cluster_workflow.cwl/clustal/alignment", 
                            "id": "#per_cluster_workflow.cwl/pal2nal/protein_alignment"
                        }
                    ], 
                    "out": [
                        "#per_cluster_workflow.cwl/pal2nal/alignment"
                    ], 
                    "id": "#per_cluster_workflow.cwl/pal2nal"
                }
            ], 
            "id": "#per_cluster_workflow.cwl"
        }, 
        {
            "class": "Workflow", 
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }, 
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "label": "Matching list of nucleotide sequence files", 
                    "id": "#main/nucleotides"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "label": "List of protein sequence files", 
                    "id": "#main/proteins"
                }
            ], 
            "outputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "outputSource": "#main/alignment/results", 
                    "id": "#main/results"
                }
            ], 
            "steps": [
                {
                    "run": "#per_cluster_workflow.cwl", 
                    "in": [
                        {
                            "source": "#main/nucleotides", 
                            "id": "#main/alignment/nucleotides"
                        }, 
                        {
                            "source": "#main/proteins", 
                            "id": "#main/alignment/proteins_to_align"
                        }
                    ], 
                    "out": [
                        "#main/alignment/results"
                    ], 
                    "scatter": [
                        "#main/alignment/proteins_to_align", 
                        "#main/alignment/nucleotides"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "id": "#main/alignment"
                }
            ], 
            "id": "#main"
        }
    ]
}