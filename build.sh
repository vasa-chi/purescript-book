find chapters -type f -print0 | xargs -0 pandoc -S --epub-metadata=metadata.xml -o dist.epub title.txt
