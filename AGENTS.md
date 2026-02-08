# AGENTS.md - Cloud Saves muOS Development Guide

This document provides guidelines for agentic coding assistants working on the muOS Cloud Saves repository. It covers build/lint/test commands, code style conventions, and development practices for this shell script-based project.

## Build/Lint/Test Commands

### Shell Script Validation
```bash
# Check syntax of all shell scripts
bash -n copy_to_tasks_directory/*.sh

# Lint with shellcheck (install if needed: brew install shellcheck)
shellcheck copy_to_tasks_directory/*.sh

# Check individual script
shellcheck copy_to_tasks_directory/Cloud_Upload_Saves.sh
```

### Testing Scripts
```bash
# Test script execution (dry run mode if supported)
# Note: Full testing requires muOS environment with rclone installed
# Use verbose mode to see detailed output
bash -x copy_to_tasks_directory/Cloud_Upload_Saves.sh --dry-run 2>&1 | head -50

```

### File Validation
```bash
# Check for executable permissions on scripts
ls -la copy_to_tasks_directory/*.sh

# Validate PNG files are not corrupted
file copy_to_tools_directory/*.png

# Check configuration file syntax (if applicable)
# Note: rclone.conf files are generated externally
```

## Code Style Guidelines

### Shell Script Conventions

#### File Structure
- Use `.sh` extension for all shell scripts
- Start with shebang: `#!/bin/sh`
- Include header comment block with description
- Separate logical sections with `##################################################################################` comments
- Use consistent variable declaration order

#### Variable Naming
- Use `UPPER_CASE` for global configuration variables
- Use `lower_case` for local variables within functions
- Prefix related variables consistently (e.g., `CLOUD_*`, `MUOS_*`, `TASK_*`)
- Use descriptive names: `CLOUD_REMOTE_NAME` not `REMOTE`

#### Quotes and Strings
- Always quote variable expansions: `"${VARIABLE}"` not `$VARIABLE`
- Use double quotes for strings containing variables
- Single quotes for literal strings without expansion

#### Error Handling
- Check command success with `if ! command; then ... fi`
- Exit with meaningful error codes (1 for general errors)
- Use descriptive error messages with emojis for user-facing output
- Log errors to stderr: `echo "❌ ERROR: message" >&2`

#### Control Flow
- Use `if [ condition ]; then ... else ... fi` syntax
- Prefer `&&` and `||` for simple conditional execution
- Avoid complex nested conditionals; break into functions if needed

### Documentation Standards

#### Comments
- Use `#` for single-line comments
- Use block comments with `##################################################################################` for sections
- Document complex logic, especially rclone operations
- Explain why certain flags/options are used

#### Script Headers
```bash
##################################################################################
## Brief description of script purpose
## Additional context if needed
##################################################################################
```

#### Function Documentation
- Document function purpose above definition
- Explain parameters and return values
- Note any side effects

### Code Organization

#### Directory Structure
- `copy_to_tasks_directory/backup/`: Cloud backup scripts (Goose-compatible)
- `copy_to_tools_directory/`: Binary tools and icons
- `rclone_sample_conf_*/`: Sample configurations
- Root: Documentation and project files

#### File Naming
- Use descriptive names: `cloud_upload_saves.sh` not `upload.sh`
- Keep script names descriptive and consistent (e.g., `cloud_upload_saves.sh`)
- Organize in category subdirectories: `backup/` for cloud sync tasks

### Security Practices

#### File Permissions
- Scripts should be executable: `chmod +x script.sh`
- Configuration files should be readable but not world-writable
- Never commit sensitive credentials or API keys

#### Input Validation
- Validate file paths exist before using: `if [ ! -f "${FILE}" ]; then ... fi`
- Check command availability: `command -v rclone >/dev/null 2>&1`
- Sanitize user inputs if any are accepted

#### Error Messages
- Don't expose internal paths or sensitive information in errors
- Provide actionable guidance in error messages
- Use consistent error format: `❌ ERROR: description`

### Testing Guidelines

#### Manual Testing Checklist
- [ ] Script runs without syntax errors
- [ ] All required files exist (rclone binary, config)
- [ ] Network connectivity checks pass
- [ ] Cloud service authentication works
- [ ] File operations complete successfully
- [ ] Task icons install correctly
- [ ] No destructive operations occur

#### Edge Cases to Test
- Network disconnection during operation
- Missing source/target directories
- Invalid rclone configuration
- Insufficient permissions
- Large file transfers

### Git Workflow

#### Commit Messages
- Use imperative mood: "Add cloud sync validation" not "Added validation"
- Reference issue numbers when applicable
- Keep first line under 50 characters
- Use body for detailed explanations

#### Branching
- Use feature branches: `feature/add-error-handling`
- Use bugfix branches: `bugfix/fix-config-detection`
- Test on muOS hardware before merging

### Dependencies

#### Required Tools
- bash (POSIX compliant shell)
- rclone (ARMv7 binary for muOS)
- Standard Unix tools: grep, sed, cp, mkdir

#### Development Tools
- shellcheck (for linting)
- bash-completion (for development)
- git (for version control)

### muOS-Specific Considerations

#### Version Compatibility
- Target muOS Goose release only
- Tasks live under /opt/muos/share/task

#### Path Conventions
- Use absolute paths for muOS directories
- MUOS_ROOT="/mnt/mmc/MUOS"
- MUOS_USER_DATA="/run/muos/storage"
- Follow muOS directory structure conventions

#### Task Integration
- Task scripts live under `/opt/muos/share/task` and must be executable
- Icons are optional and provided via PNG files in `copy_to_tools_directory/`
- Descriptions should be user-friendly when referenced in documentation

#### Resource Constraints
- Scripts run on resource-limited handheld hardware
- Minimize memory usage and complex operations
- Use efficient commands (grep instead of awk when possible)

### Configuration Management

#### rclone Configuration
- Auto-detect remote name from config file
- Support multiple cloud providers (dropbox, gdrive, onedrive)
- Validate configuration before operations
- Never modify rclone.conf programmatically

#### Environment Variables
- Use environment variables for configurable paths
- Provide sensible defaults
- Document required vs optional variables

### Performance Optimization

#### rclone Operations
- Use appropriate flags: `-P` (progress), `-L` (follow symlinks)
- Use `--update` for bidirectional sync safety
- Minimize API calls and network requests
- Handle large file transfers gracefully

#### Script Efficiency
- Cache expensive operations when possible
- Use conditional execution to avoid unnecessary work
- Exit early on errors to save processing time

This guide ensures consistent, maintainable code across the muOS Cloud Saves project. Follow these guidelines when making changes or adding new features.</content>
<parameter name="filePath">AGENTS.md