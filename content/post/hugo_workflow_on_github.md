+++
date = "2015-11-08T02:41:50Z"
title = "Hosting Hugo on GitHub Pages: Workflow"
Description = "Workflow set-up description for hosting Hugo personal/organizational and project pages on GitHub to commit and publish with just one command. Save time and improve your Hugo workflow ;)"

tags = [ "Hugo", "GitHub Pages", "workflow", "deployment"]
categories = [ "Web Development" ]
series = [ "Hugo" ]
slug = "hugo_workflow_for_github"

+++

<script type="text/javascript" src="https://asciinema.org/a/14.js" id="asciicast-14" async></script>

1. [Hosting personal/organizational page in one repo]({{< relref "#hosting-personal-organizational-page-in-one-repo" >}})
2. [Hosting personal/organizational page in two repos]({{< relref "#hosting-personal-organizational-page-in-two-repos" >}})
3. [Hosting project page]({{< relref "#hosting-project-page" >}})


## Hosting Hugo on GitHub pages: workflow

[GitHub](https://pages.github.com/) is a great and convenient place to host your static pages - it gives you a nice website address with `github.io` and combines repo for your website with hosting. Furthermore, it is free and ad-free. I believe if set up right then it can save you considerable time. In this post I share a great git workflow I use for this blog with a [Hugo static engine](https://gohugo.io/). The workflow was described by [Spencer Lyon in his tutorial on hosting Hugo on GitHub pages](https://gohugo.io/tutorials/github-pages-blog/), here I share 2 workflows described by Spencer and one my own.

## Hosting personal/organizational page in one repo

If you are creating a new repo then just do follow the instructions exactly. You can rename `code` branch to anything you like, except `master`, as `master` is a branch from which GitHub Pages get static website content. Note, that the website available under `<your-username>.github.io` must be hosted in a repo called `<your-username>.github.io`.

If you have extisting repo at `<your-username>.github.io` then you can either delete the repo and start clean following the instructions or delete the master branch with `git branch -D master` making sure before if that branch has your website code that you checked it out to another branch with `git checkout -b <code-branch>` and `git push origin <code-branch>'.

1. Create `<your-username>.github.io` repo. Alternatively, if you have got existing `<your-username>.github.io` repo then make sure to checkout code to non-`master` branch with steps described above.
2. If you are starting fresh initialize the repo:
```bash
git init
git checkout code
echo "# README" >> README.md
git add .
git commit -m 'Initial commit'
git remote add origin git@github.com:username/username.github.io git
git push -u origin code
```
3. Now, the steps regardless if repo existed or not are the same. Create orphan branch (a branch that has no common history with an existing branch) called `master`. We will synchronize its code with `public` folder of the `code` branch.
```bash
# Set up orphan branch master
git checkout --orphan master
git rm --cached $(git ls-files)
git checkout code README.md
git add .
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

### Deploy.sh

To automate the above process of commiting to code branch, generating Hugo static pages, and pushing them to `master` branch we will create `deploy.sh` script. Remember, to update `<your-username>`, <your-project>, and if you used different prefix `--prefix` in the script. Finally, make the script executable with `chmod +x deploy.sh` and commit it to the repo. To use the script you just need to type `./deploy.sh <commit-message>`. If you leave `<commit-message>` empty then `rebuilding site <current-date>` will be used instead.

We format the terminal output with escape codes. Paremeter `-e` escapes the text before printing it to the terminal. Here

  * `\e[1m` makes text bold,
  * `\e[7m` reverse colors (will result with black on green background, if your terminal background is black),
  * `\e[32m` make text color green.

You can read more about bash colors and formatting escape codes [Flozz's website](http://misc.flogisoft.com/bash/tip_colors_and_formatting).


```bash
#!/bin/bash

# Build the project
# You may need to use some of the below options:
#   * -b=http://<your-username>.github.io/<your-project>
#   * --theme=<your-theme-name>
#   * --buildDrafts   # include drafts
#   * -d=<static-pages-dir>
#   * -v   # verbose
#
# Example: hugo -b=http://jhirniak.github.io/ --theme=hugo-steam-theme -d=public/ -v
echo -e "\e[1m\e[7m\e[32mBuilding the project...\e[0m"
hugo

# Add changes to git.
echo -e "\e[1m\e[7m\e[32mCommitting updates to code branch...\e[0m"
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin code

echo -e "\e[1m\e[7m\e[32mPushing the changes to master branch...\e[0m"
echo -e "\e[1m\e[7m\e[32mUpdating the website...\e[0m"
# Example:
# git subtree push --prefix=public git@github.com:jhirniak/jhirniak.github.io.git master
git subtree push --prefix=public git@github.com:<your-username>/<your-username>.github.io.git master
```

## Hosting personal/organizational page in two repos

When you divide project into a submodule for the `username.github.io` static pages from `public` folder (or the one that you use) and separate repo for the website code then the procedure is quite simple.

Step by step:

1. Create `code` repository, e.g. `<username>-hugo`.
2. Create static `website` repository, i.e. `<username>.github.io`, for `public` folder of you hugo website.
3. Create website at `<username>-hugo`, test it with `hugo server --watch -t <yourtheme>`, and once happy remove `public` folder with `rm -rf public` and commit changes.
4. Add submodule at `<username>-hugo` repo with:
```bash
git submodule add git@github.com:<username>/<username>.github.io.git public
```
5. Add `deploy.sh` script and make it executable with `chmod +x deploy.sh`.

### Deploy.sh

Remember, to update `<your-username>`, <your-project>, and if you used different prefix `--prefix` in the script. Finally, make the script executable with `chmod +x deploy.sh` and commit it to the repo. To use the script you just need to type `./deploy.sh <commit-message>`. If you leave `<commit-message>` empty then `rebuilding site <current-date>` will be used instead.

We format the terminal output with escape codes. Paremeter `-e` escapes the text before printing it to the terminal. Here

  * `\e[1m` makes text bold,
  * `\e[7m` reverse colors (will result with black on green background, if your terminal background is black),
  * `\e[32m` make text color green.

You can read more about bash colors and formatting escape codes [Flozz's website](http://misc.flogisoft.com/bash/tip_colors_and_formatting).

```bash
#!/bin/bash

# Build the project
# You may need to use some of the below options:
#   * -b=http://<your-username>.github.io/<your-project>
#   * --theme=<your-theme-name>
#   * --buildDrafts   # include drafts
#   * -d=<static-pages-dir>
#   * -v   # verbose
#
# Example: hugo -b=http://jhirniak.github.io/ --theme=hugo-steam-theme -d=public/ -v
echo -e "\e[1m\e[7m\e[32mBuilding the project...\e[0m"
hugo

cd public    # Go To Public folder
git add -A   # Add changes to git.

# Add changes to git.
echo -e "\e[1m\e[7m\e[32mPushing updates to master branch of <username>.github.io...\e[0m"
echo -e "\e[1m\e[7m\e[32mUpdating the website...\e[0m"
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

git push origin master   # Push source and build repos.

cd ..   # Come Back
```

## Hosting project page

Project page workflow is very similar to hosting personal/organizational page, except that the static pages are in `gh-pages` branch and code in some other branch. Here, we assume that you are creating `gh-pages` for existing project.

1. Create an orphan branch (no commit history) `gh-pages`:

```bash
git checkout --orphan gh-pages

# Unstage all files
git rm --cached $(git ls-files)

# Grab one file from the master branch to make a commit
git checkout master README.md

# Add and commit that file
git add .
git commit -m "INIT: initial commit on gh-pages branch"

# Push to remote gh-pages branch
git push origin gh-pages
```

2. Now, we will configure workflow on the branch that has Hugo files, here we assume it is on `master` branch, but it could be any.

```bash
git checkout master # Return to master branch

git checkout -b website # Or create new branch for the website

3. Create or copy your Hugo project if you have not got it ready, yet.

4. Set up workflow:
```bash 
# Remove the public folder to make room for the gh-pages subtree
rm -rf public

# Add the gh-pages branch of the repository.
git subtree add --prefix=public git@github.com:<your-username>/<your-project>.git gh-pages --squash

# Pull down the file we just committed to avoid merge conflicts.
# It is the same as above, except for the word `add` that is replaced with word `pull`.
git subtree pull --prefix=public git@github.com:<your-username>/<your-project>.git gh-pages

# Generate static pages with Hugo.
# You may need to use some of the below options:
#   * -b=http://<your-username>.github.io/<your-project>
#   * --theme=<your-theme-name>
#   * --buildDrafts   # include drafts
#   * -d=<static-pages-dir>
#   * -v   # verbose
hugo 


# Commit changes
git add -A
git commit -m "Updating site"
git push origin master

# Push the `public` subtree to the `gh-pages`
git subtree push --prefix=public git@github.com:<your-username>/<your-project>.git gh-pages
```

### Deploy.sh

To automate the whole process add the below `deploy.sh` script. Remember, to update `<your-username>`, <your-project>, and if you used different prefix `--prefix` in the script. Finally, make the script executable with `chmod +x deploy.sh` and commit it to the repo. To use the script you just need to type `./deploy.sh <commit-message>`. If you leave `<commit-message>` empty then `rebuilding site <current-date>` will be used instead.

We format the terminal output with escape codes. Paremeter `-e` escapes the text before printing it to the terminal. Here

  * `\e[1m` makes text bold,
  * `\e[7m` reverse colors (will result with black on green background, if your terminal background is black),
  * `\e[32m` make text color green.

You can read more about bash colors and formatting escape codes [Flozz's website](http://misc.flogisoft.com/bash/tip_colors_and_formatting).

```bash
#!/bin/bash

# Build the project
# You may need to use some of the below options:
#   * -b=http://<your-username>.github.io/<your-project>
#   * --theme=<your-theme-name>
#   * --buildDrafts   # include drafts
#   * -d=<static-pages-dir>
#   * -v   # verbose
#
# Example: hugo -b=http://jhirniak.github.io/ --theme=hugo-steam-theme -d=public/ -v
echo -e "\e[1m\e[7m\e[32mBuilding the project...\e[0m"
hugo

# Add changes to git.
echo -e "\e[1m\e[7m\e[32mCommitting updates to code branch...\e[0m"
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push to master.
git push origin master

# Update website gh-pages branch from generate files.
echo -e "\e[1m\e[7m\e[32mPushing the changes to master branch...\e[0m"
echo -e "\e[1m\e[7m\e[32mUpdating the website...\e[0m"
# Example:
# git subtree push --prefix=public git@github.com:jhirniak/amaze.git gh-pages
git subtree push --prefix=public git@github.com:<your-username>/<your-project>.git gh-pages
```

## Deploy.sh demo

[![asciicast](https://asciinema.org/a/14.png)](static/static/deploy.anema)