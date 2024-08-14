# nextclade-nf

![push main](https://github.com/BCCDC-PHL/nextclade-nf/actions/workflows/push_main.yml/badge.svg)

Call viral lineages using [nextclade](https://github.com/nextstrain/nextclade) across many sequencing runs.
This pipeline is designed to take the output of [BCCDC-PHL/ncov2019-artic-nf](https://github.com/BCCDC-PHL/ncov2019-artic-nf) or [BCCDC-PHL/mpxv-artic-nf](https://github.com/BCCDC-PHL/mpxv-artic-nf) as its input,
and makes some assumptions about directory structures for finding consensus sequences to analyze.

## Usage

Some default parameters are set to be compatible with the outputs of [BCCDC-PHL/ncov2019-artic-nf](https://github.com/BCCDC-PHL/ncov2019-artic-nf). When analyzing those outputs, the following command can be used:

```
nextflow run BCCDC-PHL/nextclade-nf \
  -profile conda \
  --cache ${HOME}/.conda/envs \
  --analysis_parent_dir <analysis_parent_dir> \
  --dataset_dir /path/to/nextclade-data/sars-cov-2 \
  --dataset_name sars-cov-2 \
  --outdir <outdir>
```

...where `<analysis_parent_dir>` should be a directory that contains one sub-directory per sequencing run, each of which has an `ncov2019-artic-nf-vX.Y-output` sub-directory.

When analyzing outputs of the [BCCDC-PHL/mpxv-artic-nf](https://github.com/BCCDC-PHL/mpxv-artic-nf) pipeline, some default parameters must be overridden:

```
nextflow run BCCDC-PHL/nextclade-nf \
  -profile conda \
  --cache ${HOME}/.conda/envs \
  --analysis_parent_dir <analysis_parent_dir> \
  --consensus_subdir "mpxvIllumina_sequenceAnalysis_callConsensusFreebayes" \
  --dataset_dir /path/to/nextclade-data/mpox \
  --dataset_name hMPXV \
  --artic_prefix mpxv \
  --outdir <outdir>
```

## Output

A tsv file named `nextclade_lineages.tsv` will be written into `outdir`, with the following fields.
See the [nextclade docs](https://docs.nextstrain.org/projects/nextclade/en/stable/user/output-files/04-results-tsv.html)
for more details on these fields.

The fields: `sequencingRunID`, `nextcladeDatasetName`, `nextcladeDatasetVersion`, and `nextcladeVersion` are added by this pipeline for data provenance purposes.

```
sequencingRunID
index
seqName
clade
Nextclade_pango
partiallyAliased
clade_nextstrain
clade_who
clade_display
qc.overallScore
qc.overallStatus
totalSubstitutions
totalDeletions
totalInsertions
totalFrameShifts
totalMissing
totalNonACGTNs
totalAminoacidSubstitutions
totalAminoacidDeletions
totalAminoacidInsertions
totalUnknownAa
alignmentScore
alignmentStart
alignmentEnd
coverage
isReverseComplement
substitutions
deletions
insertions
frameShifts
aaSubstitutions
aaDeletions
aaInsertions
privateNucMutations.reversionSubstitutions
privateNucMutations.labeledSubstitutions
privateNucMutations.unlabeledSubstitutions
privateNucMutations.totalReversionSubstitutions
privateNucMutations.totalLabeledSubstitutions
privateNucMutations.totalUnlabeledSubstitutions
privateNucMutations.totalPrivateSubstitutions
missing
unknownAaRanges
nonACGTNs
qc.missingData.missingDataThreshold
qc.missingData.score
qc.missingData.status
qc.missingData.totalMissing
qc.mixedSites.mixedSitesThreshold
qc.mixedSites.score
qc.mixedSites.status
qc.mixedSites.totalMixedSites
qc.privateMutations.cutoff
qc.privateMutations.excess
qc.privateMutations.score
qc.privateMutations.status
qc.privateMutations.total
qc.snpClusters.clusteredSNPs
qc.snpClusters.score
qc.snpClusters.status
qc.snpClusters.totalSNPs
qc.frameShifts.frameShifts
qc.frameShifts.totalFrameShifts
qc.frameShifts.frameShiftsIgnored
qc.frameShifts.totalFrameShiftsIgnored
qc.frameShifts.score
qc.frameShifts.status
qc.stopCodons.stopCodons
qc.stopCodons.totalStopCodons
qc.stopCodons.score
qc.stopCodons.status
totalPcrPrimerChanges
pcrPrimerChanges
failedCdses
warnings
errors
nextcladeDatasetName
nextcladeDatasetVersion
nextcladeVersion
```