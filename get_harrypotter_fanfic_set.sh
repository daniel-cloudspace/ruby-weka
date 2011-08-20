#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: ./get_harrypotter_fanfic_set.sh num_of_fics"
  return 1
fi

fanficdir="harry_potter_erotic_fanfiction"

# clear out our temporary data dir
ls textdir/eroticfanfiction/* | xargs rm

# copy the files over
ls "$fanficdir" | grep html | head -n $1 | while read file; do 
  cp "$fanficdir/$file" textdir/eroticfanfiction
done

# change into our data directory
cd textdir/eroticfanfiction

# Process text out of the fanfiction.com layout
#   select paragraph tags then strip html tags
for i in *; do cat $i | tr "\n" ' ' | tr A-Z a-z | grep -oE '<p>[^<]*</p>' | sed -e 's~<p>~~g; s~</p>~~g; s~[^a-z ]~~g' |tr "\n" ' ' > tmp; mv tmp "$i"; done

# select only 5000 characters from the files, the files were too big to process in a satisfactory amount of time
for i in *; do dd if=$i bs=1 count=5000 > a; mv a $i; done

# turn into a csv file because its way easier to parse
echo "fanfic" > ../../fanfics.csv
for i in *; do 
  echo -n '"'
  cat "$i"
  echo '"'
done >> ../../fanfics.csv
