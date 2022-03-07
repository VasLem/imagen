#!/bin/bash
set -e
source ../get_input_args.sh $1 $2 $3
cd ../../python
ROOT_DIR=".."
MUNGED_DIR=$ROOT_DIR/results/ldsc/$DATASET_ID/munged
H2_DIR=$ROOT_DIR/results/ldsc/$DATASET_ID/h2
mkdir -p $MUNGED_DIR
mkdir -p $H2_DIR

for i in {1..31}; do
    i=$(printf "%02.f" $i)
    echo Handling Partition $i
    gunzip <$ROOT_DIR/results/genomeDemo/$DATASET_ID/CCAPart$i.csv.gz >data.csv
    ./ldsc/munge_sumstats.py --sumstats data.csv \
        --n-min 1000 --snp "rsID" --p P-value --a1 "A1" --a2 "A2" \
        --signed-sumstats ChiScore,1 --delim , --out $MUNGED_DIR/par$i
    ./ldsc/ldsc.py --h2 $MUNGED_DIR/par$i.sumstats.gz \
        --ref-ld-chr $ROOT_DIR/SAMPLE_DATA/eur_w_ld_chr/ \
        -w-ld-chr $ROOT_DIR/SAMPLE_DATA/eur_w_ld_chr/ --out $H2_DIR/par$i
done

echo "Collecting stats"
for i in {1..31}; do
    i=$(printf "%02.f" $i)
    if [[ "$i" = "01" ]]; then
        cat $H2_DIR/par$i.log | sed -nr 's/^(.*):\s+([0-9\.]+).*$/\1\t\2/p' | head -n4 | sed "1s/^/\t$i\n/" >ret.csv
    else
        paste ret.csv <(cat $H2_DIR/par$i.log | sed -nr 's/^.*:\s+([0-9\.]+).*$/\1/p' | head -n4 | sed "1s/^/$i\n/") -d '\t' >temp && mv temp ret.csv
    fi
done
mv ret.csv $H2_DIR/h2_results.csv
cd -