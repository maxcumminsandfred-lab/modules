process PYCOQC {
    tag "$summary"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pycoqc:2.5.2--py_0' :
        'biocontainers/pycoqc:2.5.2--py_0' }"

    input:
    tuple val(meta), path(summary)

    output:
    tuple val(meta), path("*.html")                                                                                    , emit: html
    tuple val(meta), path("*.json")                                                                                    , emit: json
    tuple val(meta), val("${task.process}"), val('pycoqc'), path("*.json")                                             , topic: multiqc_files, emit: multiqc_report
    tuple val("${task.process}"), val('pycoqc'), eval('pycoQC --version 2>&1 | sed "s/pycoQC v//"'), topic: versions   , emit: versions_pycoqc

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    pycoQC \\
        $args \\
        -f $summary \\
        -o ${prefix}.html \\
        -j ${prefix}.json
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.html
    touch ${prefix}.json
    """
}
