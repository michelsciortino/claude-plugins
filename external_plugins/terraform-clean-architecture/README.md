# Terraform Clean Architecture

A Claude Code skill plugin for generating Terraform/OpenTofu infrastructure following HashiCorp official best practices.

## Installation

```bash
/plugin install terraform-clean-architecture@michelsciortino-marketplace
```

## What It Does

When you work with Terraform or OpenTofu files, this skill activates automatically and guides Claude to:

- Structure modules following the resource -> infrastructure -> composition hierarchy
- Apply correct naming conventions (singleton `"this"`, descriptive names, standard file layout)
- Choose the right testing strategy (static analysis, native tests 1.6+, Terratest)
- Set up CI/CD pipelines with cost optimization
- Follow security best practices (encryption, least-privilege, secrets management)
- Use modern Terraform features appropriately (try, optional, moved blocks, ephemeral vars)

## Coverage

| Area | Details |
|------|---------|
| Module structure | Hierarchy, file layout, anti-patterns |
| Naming conventions | Resources, variables, outputs, files, repos |
| Testing | Decision matrix, native tests, Terratest, mocking |
| CI/CD | GitHub Actions, GitLab CI, cost optimization |
| Security | Scanning (trivy/checkov), secrets, state, IAM |
| Code patterns | Block ordering, count vs for_each, locals |
| Version management | Constraints, pinning strategy, upgrades |
| Modern features | Terraform 1.0 through 1.11+ |

## Origin

Forked from [antonbabenko/terraform-skill](https://github.com/antonbabenko/terraform-skill) (v1.6.0, Apache 2.0) and extended with content from official HashiCorp documentation to fill identified gaps.

## License

Apache 2.0 — see [LICENSE](LICENSE).
