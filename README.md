# workflow

Common information and workflow scripts for running jobs at HPC centers

## Editing and building the Sphinx docs

In `sphinx_docs/source/`, edit any of the `.rst` files.  Then build the webpages
in `sphinx_docs/` as:
```
make html
```
This will copy the HTML into the main `docs/` directory that GitHub
Pages uses.  `git commit` and `git push` and the updates will appear
in https://amrex-astro.github.io/workflow/
