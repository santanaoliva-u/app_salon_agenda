## GitHub Copilot Chat

- Extension Version: 0.30.3 (prod)
- VS Code: vscode/1.103.0
- OS: Linux

## Network

User Settings:
```json
  "github.copilot.advanced.debug.useElectronFetcher": true,
  "github.copilot.advanced.debug.useNodeFetcher": false,
  "github.copilot.advanced.debug.useNodeFetchFetcher": true
```

Connecting to https://api.github.com:
- DNS ipv4 Lookup: 140.82.113.6 (20 ms)
- DNS ipv6 Lookup: Error (1 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (48 ms)
- Electron fetch (configured): HTTP 200 (226 ms)
- Node.js https: HTTP 200 (237 ms)
- Node.js fetch: HTTP 200 (287 ms)

Connecting to https://api.githubcopilot.com/_ping:
- DNS ipv4 Lookup: 140.82.114.21 (37 ms)
- DNS ipv6 Lookup: Error (22 ms): getaddrinfo ENOTFOUND api.githubcopilot.com
- Proxy URL: None (10 ms)
- Electron fetch (configured): HTTP 200 (233 ms)
- Node.js https: HTTP 200 (239 ms)
- Node.js fetch: HTTP 200 (265 ms)

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).