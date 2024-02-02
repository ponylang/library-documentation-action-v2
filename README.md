# library-documentation-action-v2

A GitHub Action that generates documentation for a Pony library and updates that documentation on GitHub pages. The library in question must have a Makefile with a target `docs` that can be used to generate the documentation that can be feed to `mkdocs`.

Generated docs can be uploaded for hosting anywhere you like. The examples below show them being hosted on GitHub pages.

You need to supply the url of your site to the action in the `site_url` option. For GitHub pages, that domain will be `https://USER_OR_ORG_NAME.github.io/REPOSITORY_NAME/`.

## Initial Repository Setup

New repositories on github have defaults that need to be changed before you can use the workflow below.  The two settings below must be changed in the following order:

### Build and Deployment Settings

The default method on new repositories for deployment to github pages is "Deploy from a branch".  As we are using "GitHub Actions", we need to change this setting.

From the repository page in github, select "Settings" from the horizontal tabs, then "Pages" in the vertical column on the left.  Under "Build and deployment", there's "Source".  Change that from "Deploy from a branch" to "GitHub Actions".

### Allow deployment from all branches

The default "github-pages" environment has a protection rule that only allows deployment from the main branch. This rule needs to be removed.

From the same "Settings" menu in the above section, select "Environments" from the vertical menu on the left. In the list of Environments that are shown, select "github-pages".

Under the "Deployment branches" section of the configuration, click the "Remove" button next to the rule that only allows the branch main.

## Example workflow

In **release.yaml**, in addition the usual [release-bot-action](https://github.com/ponylang/release-bot-action) workflow entries.

```yml
name: Release

on:
  push:
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'

permissions:
  contents: read
  pages: write
  id-token: write

concurrency: release

jobs:
  generate-documentation:
    name: Generate documentation for release
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4.1.1
      - name: Generate documentation
        uses: docker://ponylang/library-documentation-action-v2:release
        with:
          site_url: "https://MYORG.github.io/MY-LIBRARY/"
          library_name: "MY-LIBRARY"
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
        uses: actions/checkout@v4.1.1
      - name: Generate documentation
        uses: docker://ponylang/library-documentation-action-v2:release
        with:
          site_url: "https://MYORG.github.io/MY-LIBRARY/"
          library_name: "MY-LIBRARY"
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

## Private mkdocs-material-insiders images for the Pony organization projectws

The Pony project is a sponsor of the [insiders builds](https://squidfunk.github.io/mkdocs-material/insiders/) of the mkdocs-material theme. The insiders builds feature a number of improvements over the stock version of mkdocs-material. As such, if you are installing the library-documentation-action-v2 on a ponylang project, you should use an image that has been built with the insiders theme installed.

We maintain private images for ponylang organization use of this action that match the public versions. The only difference is the theme installed and where to get them. The private images are stored in a private GitHub Container Registry repository that you can see all the images in it by looking at the [repository page](https://github.com/ponylang/library-documentation-action-v2/pkgs/container/library-documentation-action-v2). Note, only members of the ponylang organization can view the page.

Please refer to existing usage of the action in ponylang projects for how to install. You'll need to use it as a job container instead of an action as you can't currently load actions from a private repository.
