# Contributing to Mistral-7B dstack Demo

Thank you for your interest in contributing to this project! This demo showcases LLM deployment using dstack, and we
welcome contributions that improve the experience for learners and practitioners.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Contribution Workflow](#contribution-workflow)
- [Style Guidelines](#style-guidelines)
- [Testing Your Changes](#testing-your-changes)
- [Documentation Guidelines](#documentation-guidelines)

## Code of Conduct

This project follows a standard code of conduct. Please be respectful, constructive, and professional in all
interactions.

## How Can I Contribute?

### Asking Questions

Not sure how something works? Use the question template. We're here to help learners understand dstack and LLM
deployment patterns.

### Reporting Bugs

If you encounter a bug, please create an issue using the bug report template. Include:

- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, dstack version, cloud provider)
- Relevant logs or error messages

### Suggesting Enhancements

Have an idea to improve the demo? Create an issue using the suggestion template. Consider:

- Whether it aligns with the project's educational goals
- If it maintains simplicity and clarity
- How it benefits learners using this demo

### Improving Documentation

Documentation improvements are always welcome! This includes:

- Fixing typos or clarifying instructions
- Adding troubleshooting tips
- Improving code comments
- Expanding the exercises section

### Contributing Code

Code contributions should:

- Maintain the demo's simplicity and educational focus
- Follow existing patterns and conventions
- Include clear documentation
- Be tested with actual deployments when possible

## Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/toffee-dstack-demo.git
   cd toffee-dstack-demo
   ```

2. Follow the instructions in [README.md](./README.md) to configure your dstack server.

## Contribution Workflow

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   # or
   git checkout -b docs/your-documentation-update
   ```

2. **Make your changes**
    - Follow the style guidelines below
    - Keep changes focused and atomic
    - Write clear commit messages

3. **Test your changes**
    - For configuration changes: render and validate the service config
    - For script changes: test locally or in Docker
    - For deployment changes: test with actual dstack deployment
    - For documentation: ensure accuracy and clarity

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "type: brief description

   Detailed explanation of what changed and why."
   ```

   Commit types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

   Then create a PR using the pull request template.

## Style Guidelines

### Bash Scripts

- Use `#!/usr/bin/env bash` shebang
- Set strict error handling: `set -o errexit -o nounset -o pipefail`
- Define functions above `main()`
- Use lowercase for local variables: `local my_var="value"`
- Expand variables with braces: `"${VAR}"`
- Use `exec` for final server command (proper signal handling)
- Include `help()` function with `-h`/`--help` support
- Echo descriptive messages for each step

Example:

```bash
#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]
Description of what this script does.
EOF
}

main() {
    echo "Starting process..."
    local my_var="value"
    echo "Variable: ${my_var}"
    return 0
}

main "$@"
```

### YAML Files

- Use `.yaml` extension (not `.yml`)
- Use 2-space indentation
- Use environment variable substitution: `${VAR_NAME}`
- Add comments for non-obvious configurations

### Environment Variables

- Use SCREAMING_SNAKE_CASE: `SERVICE_NAME=mistral-7b`
- Group related variables with section headers
- Provide example values in `example.env`
- Document each variable's purpose

### Documentation

- Use clear, beginner-friendly language
- Include practical examples
- Add troubleshooting tips when relevant
- Use proper markdown formatting
- Break complex instructions into numbered steps

## Testing Your Changes

### Configuration Changes

```bash
cd services/mistral-7b
./scripts/render-config.bash --env-file ../../.env --output test.yaml

# Validate the rendered configuration
cat test.yaml
```

### Deployment Changes

If your changes affect deployments, test with actual dstack:

```bash
cd services/mistral-7b
set -a; source ../../.env; set +a
./scripts/render-config.bash --env-file ../../.env | dstack apply -f - --project mistral-7b

# Monitor deployment
dstack logs mistral-7b --follow --project mistral-7b

# Clean up after testing
dstack stop mistral-7b --project mistral-7b
```

## Documentation Guidelines

### README.md Updates

- Maintain the existing structure and TOC
- Keep instructions clear and sequential
- Include cost warnings for GPU-related changes
- Add troubleshooting tips when introducing new features

## Pull Request Checklist

Before submitting your PR, ensure:

- [ ] Code follows style guidelines
- [ ] Changes are tested (configuration rendering, scripts, deployments)
- [ ] Documentation is updated
- [ ] Commit messages are clear and descriptive
- [ ] PR description explains what and why
- [ ] No sensitive information (API keys, tokens) in commits
- [ ] `.dstackignore` is updated if new files should be excluded
- [ ] Example environment variables added to `example.env` if needed

## Questions?

If you have questions about contributing, feel free to:

- Open a question issue using the template
- Ask in your pull request
- Review existing issues for similar questions

Thank you for contributing to making LLM deployment with dstack more accessible! 🚀
