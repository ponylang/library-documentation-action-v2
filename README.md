# library-documentation-action-v2

A GitHub Action that generates documentation for a Pony library and updates that documentation on GitHub pages. The library in question must have a Makefile with a target `docs` that can be used to generate the documentation that can be feed to `mkdocs`.

Generated docs can be uploaded for hosting anywhere you like. The examples below show them being hosted on GitHub pages.

You need to supply the url of your site to the action in the `site_url` option. For GitHub pages, that domain will be `https://USER_OR_ORG_NAME.github.io/REPOSITORY_NAME/`.

## Example workflow

In **release.yaml**, in addition the usual [release-bot-action](https://github.com/ponylang/release-bot-action) workflow entries.

```yml
name: Release

on:
  push:
    tags:
      - \d+.\d+.\d+

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "update-documentation"
  cancel-in-progress: true

jobs:
  generate-documentation:
    name: Generate documentation for release
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Generate documentation
        uses: ponylang/library-documentation-action@via-github-action
        with:
          site_url: "https://MYORG.github.io/MYLIBRARY/"
          library_name: "MYLIBRARY"
          docs_build_dir: "build/MY-LIBRARY-docs"
      - name: Setup Pages
        uses: actions/configure-pages@v2
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: 'build/MY-LIBRARY-docs/site/'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v1
```

## Manually triggering a documentation build and deploy

GitHub has a [`workflow_dispatch`](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#workflow_dispatch) event that provides a button the actions UI to trigger the workflow. You can set up a workflow to respond to a workflow_dispatch if you need to regenerate documentation from the last commit on a given branch without doing a full release.

We suggest that you install the a `workflow_dispatch` driven workflow to generate documentation the when you first install this action so you don't need to do a superfluous release.

```yml
name: Manually generate documentation

on:
  workflow_dispatch

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "update-documentation"
  cancel-in-progress: true

jobs:
  generate-documentation:
    name: Generate documentation for release
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Generate documentation
        uses: ponylang/library-documentation-action@via-github-action
        with:
          site_url: "https://MYORG.github.io/MYLIBRARY/"
          library_name: "MYLIBRARY"
          docs_build_dir: "build/MY-LIBRARY-docs"
      - name: Setup Pages
        uses: actions/configure-pages@v2
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: 'build/MY-LIBRARY-docs/site/'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v1
```

## Versioning

Releases for library-documentation-action-v2 are done on a "rolling basis". Each time a new nightly ponyc is released, a new version of the library-documentation-action-v2 is released and tagged with `latest`. For each release of ponyc, a new image of library-documentation-action-v2 is created and tagged with `release`. Lastly, if you want to stay pinned to specific version of ponyc, then you can use the corresponding tag for library-documentation-action-v2. For example, to use the library-documentation-action-v2 built with ponyc `0.53.0` you would use `ponylang/library-documentation-action-v2:0.53.0`.

You can get a list of all available images by checking out the [tags page](https://hub.docker.com/r/ponylang/library-documentation-action-v2/tags) of the Docker Hub repository for this image.
