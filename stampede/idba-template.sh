#!/bin/bash

set -u

WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

ARGS=''

if [[ -n ${VERBOSE:-''} ]]; then
  ARGS='--debug'
fi

if [[ ${#MAX_MISMATCH} -gt 1 ]]; then
  ARGS="$ARGS --max_mismatch $MAX_MISMATCH"
fi

if [[ ${#MAXK} -gt 1 ]]; then
  ARGS="$ARGS --maxk $MAXK"
fi

if [[ ${#MIN_CONTIG} -gt 1 ]]; then
  ARGS="$ARGS --min_contig $MIN_CONTIG"
fi

if [[ ${#MIN_COUNT} -gt 1 ]]; then
  ARGS="$ARGS --min_count $MIN_COUNT"
fi

if [[ ${#MIN_PAIRS} -gt 1 ]]; then
  ARGS="$ARGS --min_pairs $MIN_PAIRS"
fi

if [[ ${#MIN_SUPPORT} -gt 1 ]]; then
  ARGS="$ARGS --min_support $MIN_SUPPORT"
fi

if [[ ${#MINK} -gt 1 ]]; then
  ARGS="$ARGS --mink $MIN_K"
fi

if [[ ${#NO_COVERAGE,} -gt 1 ]]; then
  ARGS="$ARGS --no_coverage"
fi

if [[ ${#NO_CORRECT} -gt 1 ]]; then
  ARGS="$ARGS --no_correct"
fi

if [[ ${#PRE_CORRECTION} -gt 1 ]]; then
  ARGS="$ARGS --pre_correction"
fi

if [[ ${#PREFIX} -gt 1 ]]; then
  ARGS="$ARGS --prefix $PREFIX"
fi

if [[ ${#SEED_KMER} -gt 1 ]]; then
  ARGS="$ARGS --seed_kmer $SEED_KMER"
fi

if [[ ${#SIMILAR} -gt 1 ]]; then
  ARGS="$ARGS --similar $SIMILAR"
fi

if [[ ${#STEP} -gt 1 ]]; then
  ARGS=$ARGS $MAX_MISMATCH"
fi

$WRAPPERDIR/run-idba.pl -d ${IN_DIR} -o ${OUT_DIR:-"${WRAPPERDIR}/idba-out"} $ARGS
