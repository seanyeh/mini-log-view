# Mini Log View Generator

Generates a static HTML log viewer from JSONL files. Works with GitHub Actions and GitLab CI.

## JSONL Format

```jsonl
{"timestamp": "2026-01-13T14:32:01-06:00", "status": "info", "message": "Server started"}
{"timestamp": "2026-01-13T14:32:05-06:00", "status": "error", "message": "Database connection failed"}
```

Fields: `timestamp` (ISO 8601), `status` (info/error/warning/ok), `message`

## GitHub Actions

```yaml
name: Deploy Log Viewer
on:
  push:
    branches: [main]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate Pages
        uses: seanyeh/mini-log-view@main

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v4
        with:
          path: ./dist

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

## GitLab CI

```yaml
include:
  - remote: 'https://raw.githubusercontent.com/seanyeh/mini-log-view/main/gitlab-ci-template.yml'

pages:
  extends: .build-site
  only:
    - main
```
