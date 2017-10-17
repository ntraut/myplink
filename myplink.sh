#!/bin/bash
# myplink
# makes it nicer to use plink
# nicolas traut, v3 17 October 2017
# roberto toro, v2 30 July 2013
# roberto toro, v1 12 July 2012

set -e

if command -v gmktemp >& /dev/null; then
    mktemp=gmktemp
else
    mktemp=mktemp
fi

np=0; nc=0;
tmp=$($mktemp)
tmp_pheno=$($mktemp --suffix=.pheno)
tmp_covar=$($mktemp --suffix=.covar)
trap 'echo removing temporary files; rm $tmp $tmp_pheno $tmp_covar' EXIT

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
	--pheno)
		file="$2"
		if [[ $np -eq 0 ]]; then
			pheno=$file
		else
		    if [[ $np -eq 1 ]]; then
		        cat $pheno > $tmp_pheno
		        pheno=$tmp_pheno
		    fi
			awk 'NR == FNR {
				k[$1, $2]=$0
				next
			}
			($1, $2) in k {
				printf "%s", k[$1, $2]
				for (i=3; i<=NF; i++)
					printf " %s", $i
				print ""
			}' $tmp_pheno $file > $tmp
			cp $tmp $tmp_pheno
		fi
		shift # past argument
		((++np))
		;;
	--covar)
		file="$2"
		if [[ $nc -eq 0 ]]; then
		    covar=$file
		else
		    if [[ $nc -eq 1 ]]; then
		        cat $covar > $tmp_covar
		        covar=$tmp_covar
		    fi
			awk 'NR == FNR {
				k[$1, $2]=$0
				next
			}
			($1, $2) in k {
				printf "%s", k[$1, $2]
				for (i=3; i<=NF; i++)
					printf " %s", $i
				print ""
			}' $tmp_covar $file > $tmp
			cp $tmp $tmp_covar
		fi
		shift # past argument
		((++nc))
		;;
	*)
		cmd="$cmd $key"
		;;
	esac
	shift
done

echo "npheno=$np, ncovar=$nc"

if [[ $np -ne 0 ]]; then
	cmd="$cmd --pheno $pheno"
fi
if [[ $nc -ne 0 ]]; then
	cmd="$cmd --covar $covar"
fi

echo "$cmd"
eval "$cmd"