+++
date = "2015-11-08T02:41:50Z"
draft = true
title = "Hosting Hugo on GitHub Pages: Workflow"

+++
## Hosting Hugo on GitHub pages: workflow

```bash
git init
git checkout code
echo "# README" >> README.md
git add .
git commit -m 'Initial commit'
git remote add origin git@github.com:username/username.github.io git
git push -u origin code
git checkout --orphan master
git rm --cached $(git ls-files)
git checkout code README.md
git add
git commit -m "INIT: initial commit on master branch"
git push origin master
git checkout code
# Create Hugo website or copy existing files for Hugo website
rm -rf public/
git subtree add --prefix=public git@github.com:username/username.github.io.git master --squash
git subtree pull --prefix=public git@github.com:username/username.github.io.git master --squash # to avoid merge conflicts
hugo # with any parameters you may need, as -b=http://www.username.github.io --theme=your_theme_name --buildDrafts -d=public/ -v
git add -A .
git commit -m 'Website update'
git push origin code
git subtree push --prefix=public git@github.com:username/username.github.io.git master --squash
```

## Deploy.sh

```bash
#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
# hugo -t hugo-steam-theme
hugo -b=http://jhirniak.github.io/ --theme=hugo-steam-theme --buildDrafts -d=public/ -v

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin code
git subtree push --prefix=public git@github.com:jhirniak/jhirniak.github.io.git master

```
