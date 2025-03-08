# Setup

This repo is a collection of scripts that are handy for setting up a new pc.

[![pipeline status](https://gitlab.com/perobertson/setup/badges/main/pipeline.svg)](https://gitlab.com/perobertson/setup/pipelines?scope=branches&ref=main)

## Supported Operating Systems

Python3 is a main component of the tools that are installed and used. This
limits which OS versions that are supported since Python2 is EOL. In general,
this list will be the latest LTS release for the distribution. OSes that become
EOL or use EOL languages can still be run as manual jobs in the CI pipeline and
will be cleaned up after a period of time. Other versions may still work, they
are just not tested in CI.

- Fedora: 41, 42
- Ubuntu: 24.04(LTS)

Please see the [latest pipeline] for `main` for the complete list.

[latest pipeline]: https://gitlab.com/perobertson/setup/pipelines?scope=branches&ref=main

## Usage

To run the script, all you need to do is run this from a console on the machine that you are setting up.
This will checkout the project to `"${CODE_PATH:-~/workspace}/gitlab.com/perobertson/setup"` before applying other changes.

Using `curl`:

```bash
/usr/bin/curl -sSL https://gitlab.com/perobertson/setup/raw/main/setup.sh | bash
```

Using `wget`:

```bash
/usr/bin/wget -qO- https://gitlab.com/perobertson/setup/raw/main/setup.sh | bash
```

## Updating

The scripts are designed to be rerun to get the latest updates.

```bash
cd "${CODE_PATH:-~/workspace}/gitlab.com/perobertson/setup"
git pull --rebase
./setup.sh
```

You can also rerun the `curl` or `wget` commands from above.

## Adding new OS versions

To add a new OS version you need to add a build definition in `.gitlab-ci.yml`.
If this version requires specific install steps, you need to add a directory under the OS type and a `bootstrap.sh` file.
The `bootstrap.sh` script should only install `ansible`.
The rest of the setup script should be done as ansible tasks so that all systems benefit.

## Keybindings

This is a non exhaustive list of the keybindings that have been configured.

### Desktop environments

**Cinnamon:**

- `<Shift><Super>exclam` will toggle 1Password
- `<Primary><Shift>space` will toggle 1Password quick access
    - primary is ctrl
