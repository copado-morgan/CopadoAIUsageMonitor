# CopadoAIUsageMonitor

An unlocked package for monitoring Copado AI usage across Salesforce orgs.

## Package Structure

```
force-app/
  main/
    default/
      classes/          # Apex classes and test classes
      triggers/         # Apex triggers
      lwc/              # Lightning Web Components
      aura/             # Aura components
      flows/            # Flows and Process Builders
      objects/          # Custom objects and fields
      permissionsets/   # Permission sets
      layouts/          # Page layouts
      staticresources/  # Static resources
      tabs/             # Custom tabs
      customMetadata/   # Custom metadata types and records
      labels/           # Custom labels
```

## Prerequisites

- Salesforce CLI (`sf`)
- A Dev Hub org enabled for unlocked packages

## Setup

1. Authorize your Dev Hub:
   ```bash
   sf org login web --set-default-dev-hub --alias MyDevHub
   ```

2. Create the package (first time only):
   ```bash
   sf package create --name "CopadoAIUsageMonitor" --type Unlocked --path force-app --target-dev-hub MyDevHub
   ```

3. Create a new package version:
   ```bash
   sf package version create --package "CopadoAIUsageMonitor" --installation-key-bypass --wait 10
   ```

4. Install in a target org:
   ```bash
   sf package install --package <04t_VERSION_ID> --target-org <TargetOrgAlias> --wait 10
   ```
