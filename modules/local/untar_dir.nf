process UNTAR_DIR {
    tag "$archive"
    label 'process_low'
    label 'error_retry'

    conda (params.enable_conda ? "conda-forge::sed=4.7" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'ubuntu:20.04' }"

    input:
    path(archive)

    output:
    path("$untar"), emit: untar
    path "versions.yml"   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args  = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    untar     = archive.toString() - '.tar'
    tar_opts  = '-xvf'

    """
    mkdir output

    tar \\
        -C output \\
        $tar_opts \\
        $args \\
        $archive \\
        $args2

    mv output ${untar}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """

    stub:
    untar     = archive.toString() - '.tar'
    """
    mkdir $untar
    touch $untar/dummy.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """
}
