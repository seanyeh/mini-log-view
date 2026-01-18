# Mini Log View Generator

A reusable GitHub Action that generates a static HTML log viewer from JSONL files.

## Usage

```yaml
name: Deploy Log Viewer
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Generate Log Viewer
        uses: seanyeh/mini-log-view
        with:
          log-directory: './logs'
          output-directory: './dist'
          
      - name: Deploy to Pages
        uses: actions/deploy-pages@v3
        with:
          path: './dist'
```

## Inputs

- `log-directory` (required): Directory containing JSONL log files
- `output-directory` (optional): Output directory for generated site (default: `./dist`)

## JSONL Format

Each log entry should be a JSON object with:
- `timestamp`: ISO 8601 timestamp (e.g., "2026-01-13T00:01:12-06:00")
- `status`: Log level ("info", "error", "warning", "ok")
- `message`: Log message

Example:
```jsonl
{"timestamp": "2026-01-13T14:32:01-06:00", "status": "info", "message": "Server started"}
{"timestamp": "2026-01-13T14:32:05-06:00", "status": "error", "message": "Database connection failed"}
```

## Local Development

```bash
./scripts/generate.sh /path/to/logs ./output
```# mini-log-view
