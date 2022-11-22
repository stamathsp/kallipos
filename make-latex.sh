#!/bin/sh
#assemble and preprocess all the sources files

if [ ! -d "./latex" ]; then
   echo "  creating missing directory for(latex)"
   mkdir ./latex
fi

if [ ! -d "./book" ]; then
   echo "  creating the missing directory for(book)"
   mkdir ./book
fi

echo "  Making the text/pre.txt to latex/pre.tex..."
pandoc text/pre.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/pre.tex

echo "  Compiling the text/intro.txt into latex/intro.tex..."
pandoc text/intro.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/intro.tex

for filename in text/ch*.txt; do
      [ -e "$filename" ] || continue
      echo "  $filename -> latex/$(basename "$filename" .txt).tex..."
      pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --lua-filter=contribution.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to latex > latex/"$(basename "$filename" .txt).tex"    
   done

echo "  text/epi.txt to latex/epi.tex..."
pandoc text/epi.txt --lua-filter=epigraph.lua --to markdown | pandoc --top-level-division=chapter --to latex > latex/epi.tex

for filename in text/apx*.txt; do 
   [ -e "$filename" ] || continue
   echo "  $filename -> latex/$(basename "$filename" .txt).tex..."
   pandoc --lua-filter=extras.lua "$filename" --to markdown | pandoc --lua-filter=extras.lua --to markdown | pandoc --lua-filter=epigraph.lua --to markdown | pandoc --lua-filter=figure.lua --to markdown | pandoc --filter pandoc-fignos --to markdown | pandoc --metadata-file=meta.yml --top-level-division=chapter --citeproc --bibliography=bibliography/"$(basename "$filename" .txt).bib" --reference-location=section --to latex > latex/"$(basename "$filename" .txt).tex"   
done

echo " Matching the .tex files into a single file. Standby, it will not take that long :)."
pandoc -s latex/*.tex -o book/book.tex

echo "  Creating the .pdf book from the .tex files. Be patient."
pandoc -N --quiet --variable "geometry=margin=1.2in" --variable mainfont="MesloLGS NF Regular" --variable sansfont="MesloLGS NF Regular" --variable monofont="MesloLGS NF Regular" --variable fontsize=12pt --variable version=2.0 book/book.tex  --pdf-engine=xelatex --toc -o book/book.pdf

echo "  The process has finished successfully! Well done :)"

#sed -i '' 's+Figure+Εικόνα+g' ./latex/ch0*
