#!/bin/bash

target_dir=target
base_url=http://www.ale.dk/fileadmin/download/Festivaler
pdf=Festivalguide2015.pdf
index_first_page=155
index_last_page=160
patt1='No. [3-4]$'
patt2='[0-9]$'

test ! -d $target_dir && mkdir $target_dir

test ! -f $target_dir/$pdf && wget --directory-prefix=$target_dir $base_url/$pdf

pdftotext -f $index_first_page -l $index_last_page $target_dir/$pdf - \
    | sed '/•/d;/[A-T]-[B-Ø]/d;/[P-S]-[S-T]/d;/ØLINDEX/d;/3[0-9][0-9]/d;/^\s*$/d' \
    | while read line; do 
    if [[ $line =~ $patt1 ]]; then
        echo -n "$line "
    elif [[ $line =~ $patt2 ]]; then
        echo $line
    else
        echo -n "$line "
    fi
done > $target_dir/index.txt

cat <<EOF > $target_dir/index.html
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Ølfestival® 2015</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
ul { padding: 0; }
li { display: block; }
li span { font-weight: bold; padding-left: 1em; }
</style>
</head>
<body>
<ul>
EOF

cat $target_dir/index.txt | while read line; do
    echo -n '<li>'
    echo -n $(sed -r 's/ ([0-9]+$)/ <span>\1<\/span>/' <<< $line)
    echo '</li>'
done >> $target_dir/index.html

cat <<EOF >> $target_dir/index.html
</ul>
</body>
</html>
EOF
