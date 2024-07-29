process prepare_multi_fasta {

    tag { run_id }

    executor 'local'

    input:
    tuple val(run_id), path(analysis_dir)

    output:
    tuple val(run_id), path("${run_id}.consensus.fa"), path("${run_id}.qc.csv")

    script:
    // for freebayes consensus, header is unchanged but fasta is converted to single line
    consensus_subdir = params.consensus_subdir
    awk_string = '/^>/ { print $0 }; !/^>/ { printf "%s", $0 }; END { print ""}'
    """
    export LATEST_ARTIC_ANALYSIS_VERSION=\$(ls -1 ${run_id} | grep "${params.artic_prefix}-artic-nf-.*-output" | cut -d '-' -f 4 | tail -n 1 | tr -d \$'\\n')
    cp ${analysis_dir}/*-artic-nf-\${LATEST_ARTIC_ANALYSIS_VERSION}-output/${run_id}.qc.csv .
    tail -n+2 ${run_id}.qc.csv | grep -iv '^NEG' | cut -d ',' -f 1 > ${run_id}_samples.csv
    touch ${run_id}.consensus.fa
    while IFS="," read -r sample_id; do
    cat ${analysis_dir}/${params.artic_prefix}-artic-nf-\${LATEST_ARTIC_ANALYSIS_VERSION}-output/${consensus_subdir}/\${sample_id}*.fa \
	| awk -F "_" '${awk_string}' \
	>> ${run_id}.consensus.fa;
    done < ${run_id}_samples.csv
    """
}

process nextclade_dataset_list {

    tag { dataset_name }

    input:
    val(dataset_name)

    output:
    path("nextclade_dataset_${dataset_name}.json"), emit: nextclade_dataset_json
    path("nextclade_dataset_${dataset_name}_version.tsv"), emit: nextclade_dataset_version

    script:
    """
    nextclade dataset list \
	--name=${dataset_name} \
	--json \
	> nextclade_dataset_${dataset_name}.json

    export nextclade_ver=\$(nextclade --version | awk '{print \$2}')


    get_dataset_version.py \
	--nextclade_json nextclade_dataset_${dataset_name}.json \
	--dataset_name ${dataset_name} \
    --nextclade_version \$nextclade_ver  > nextclade_dataset_${dataset_name}_version.tsv
    """
}






  
process nextclade_run {

    tag { run_id }

    input:
    tuple val(run_id), path(consensus_multi_fasta), path(artic_qc), path(nextclade_dataset_version), path(dataset)

    output:
    tuple val(run_id), path("${run_id}_nextclade_with_version.tsv")

    script:
    """
    nextclade run \
	--input-dataset=${dataset} \
	--input-ref=${dataset}/reference.fasta \
	--input-annotation=${dataset}/genome_annotation.gff3 \
	--input-tree=${dataset}/tree.json \
	--input-pathogen-json=${dataset}/pathogen.json \
	--output-tsv=${run_id}_nextclade.tsv \
	${consensus_multi_fasta}

    # add sequencingRunID column to tsv
    awk 'BEGIN{FS=OFS="\t"} {print (NR>1 ? "${run_id}" : "sequencing_run_id"), \$0}' ${run_id}_nextclade.tsv > ${run_id}_nextclade.tsv.tmp

    add_dataset_version.py \
	--nextclade-dataset-version ${nextclade_dataset_version} \
	--nextclade-tsv ${run_id}_nextclade.tsv.tmp \
	> ${run_id}_nextclade_with_version.tsv
    """
}