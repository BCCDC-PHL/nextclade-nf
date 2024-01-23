#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { prepare_multi_fasta }    from './modules/nextclade.nf'
include { nextclade_dataset_list } from './modules/nextclade.nf'
include { nextclade_run }          from './modules/nextclade.nf'


def getArticSubDirs(Path p) {
  pattern = ~/ncov2019-artic-nf*/
  FileFilter filter = { x -> x.isDirectory() && x.getName() =~ pattern }
  articSubDirs = p.toFile().listFiles(filter)

  return articSubDirs
}

def hasArticSubDirs(Path p) {
  articSubDirs = getArticSubDirs(p)

  return (articSubDirs.size() > 0)
}

def latestArticSubdirHasQCFile(Path p) {
  runID = p.toFile().getName()
  articSubDirs = getArticSubDirs(p)
  latestArticSubdir = articSubDirs.last()
  def pattern = ~/[A-Za-z0-9_\-]+\.qc\.csv/
  FileFilter filter = { x -> x.isFile() && x.getName() =~ pattern }
  articQCFiles = latestArticSubdir.listFiles(filter)
  hasQCFile = articQCFiles.size() > 0

  return hasQCFile
}


workflow {

    ch_analysis_dirs = Channel.fromPath("${params.analysis_parent_dir}/*", type: 'dir')
    ch_dataset = Channel.fromPath("${params.dataset_dir}", type: 'dir')

  main:
    prepare_multi_fasta(ch_analysis_dirs.map{ it -> [it.baseName, it] }.filter{ it -> hasArticSubDirs(it[1]) }.filter{ it -> latestArticSubdirHasQCFile(it[1]) })  // Check that analysis dirs contain artic outputs, exclude those that don't
    ch_nextclade_dataset_version = nextclade_dataset_list(params.dataset_name).nextclade_dataset_version
    nextclade_run(prepare_multi_fasta.out.combine(ch_nextclade_dataset_version).combine(ch_dataset))
    nextclade_run.out.map{ it -> it[1] }.collectFile(keepHeader: true, name: "nextclade_lineages.tsv", storeDir: "${params.outdir}")
}
