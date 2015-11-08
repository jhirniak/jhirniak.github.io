#!/bin/bash
hugo -b=http://blog.hirniak.com/ --theme=hugo-steam-theme --buildDrafts -d=../blog.hirniak.info-static/ -v
echo "rsync -avxz * ravanave@s3.mydevil.net:/home/ravanave/domains/blog.hirniak.com/public_html"
