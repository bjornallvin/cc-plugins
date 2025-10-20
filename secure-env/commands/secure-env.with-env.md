Execute the bash command with environment variables from .env:

```bash
source .env && {{prompt}}
```

Use the Bash tool to run this. Environment variables will be available to the command, but their values won't appear in the context unless explicitly echoed.

