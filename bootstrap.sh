#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="${ROOT_DIR}/.tools"
STATE_DIR="${TOOLS_DIR}/state"

TEMPLATE_REPO="${TEMPLATE_REPO:-https://github.com/napoleondynamit-e/kicad_template.git}"
TEMPLATE_REF="${TEMPLATE_REF:-master}"
KICAD_HAPPY_REPO="${KICAD_HAPPY_REPO:-https://github.com/napoleondynamit-e/kikcad-happy.git}"
KICAD_HAPPY_REF="${KICAD_HAPPY_REF:-main}"
KICAD_MCP_REPO="${KICAD_MCP_REPO:-https://github.com/mixelpixx/KiCAD-MCP-Server.git}"
KICAD_MCP_REF="${KICAD_MCP_REF:-v2.7.0}"
KICAD_MCP_PYTHON="${KICAD_MCP_PYTHON:-}"
DATASHEET_CLI_REPO="${DATASHEET_CLI_REPO:-https://github.com/napoleondynamit-e/datasheet-cli.git}"
DATASHEET_CLI_REF="${DATASHEET_CLI_REF:-master}"
DATASHEET_CLI_INSTALL_ROOT="${DATASHEET_CLI_INSTALL_ROOT:-}"

KICAD_HAPPY_DIR="${TOOLS_DIR}/kicad-happy"
KICAD_MCP_DIR="${TOOLS_DIR}/kicad-mcp"
CHECK_ONLY=false

usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh [--check]

Without arguments, installs or updates the project tools, builds the KiCad MCP
server, and links the kicad-happy skills into .agents/skills. datasheet-cli is
installed into the user's Cargo bin directory, which must be in PATH.

When bootstrap.sh is the only file in its directory, the script first populates
that directory with this template. It does not initialize or modify Git state.

Options:
  --check    Verify prerequisites and the installation without changing it.
  -h, --help Show this help.

Repository URLs and branches can be overridden with TEMPLATE_REPO,
TEMPLATE_REF, KICAD_HAPPY_REPO, KICAD_HAPPY_REF, KICAD_MCP_REPO,
KICAD_MCP_REF, DATASHEET_CLI_REPO, and DATASHEET_CLI_REF. Override the Python
used by KiCad MCP with KICAD_MCP_PYTHON and the user-level Cargo install
location with DATASHEET_CLI_INSTALL_ROOT.
EOF
}

log() {
  printf '[bootstrap] %s\n' "$*"
}

die() {
  printf '[bootstrap] ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

ensure_project_structure() {
  local temp_dir checkout_dir

  if [[ -f "${ROOT_DIR}/AGENTS.md" \
    && -f "${ROOT_DIR}/Makefile" \
    && -f "${ROOT_DIR}/README.md" \
    && -d "${ROOT_DIR}/docs/requirements" ]]; then
    log "Project structure already exists; template sync is intentionally skipped"
    return
  fi

  require_command git
  require_command tar

  if find "${ROOT_DIR}" -mindepth 1 -maxdepth 1 ! -name bootstrap.sh -print -quit \
    | grep -q .; then
    die "Project structure is missing and the directory is not empty: ${ROOT_DIR}"
  fi

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/kicad-template.XXXXXXXX")"
  checkout_dir="${temp_dir}/template"

  cleanup_template_checkout() {
    rm -rf -- "${temp_dir}"
  }
  trap cleanup_template_checkout EXIT

  log "Downloading template ${TEMPLATE_REPO} (${TEMPLATE_REF})"
  git clone --quiet --depth 1 --branch "${TEMPLATE_REF}" \
    "${TEMPLATE_REPO}" "${checkout_dir}"

  if [[ -f "${ROOT_DIR}/bootstrap.sh" ]]; then
    git -C "${checkout_dir}" archive HEAD \
      | tar --exclude=bootstrap.sh -xf - -C "${ROOT_DIR}"
    chmod +x "${ROOT_DIR}/bootstrap.sh"
  else
    git -C "${checkout_dir}" archive HEAD | tar -xf - -C "${ROOT_DIR}"
  fi

  cleanup_template_checkout
  trap - EXIT

  log "Populated project structure in ${ROOT_DIR}"
}

check_prerequisites() {
  require_command git
  require_command python3
  require_command kicad-cli
  require_command node
  require_command npm

  if ! command -v codex >/dev/null 2>&1 \
    && ! command -v cursor-agent >/dev/null 2>&1 \
    && ! command -v cursor >/dev/null 2>&1; then
    log "WARNING: no supported AI agent command found (codex or Cursor)."
  fi
}

sync_tool_repo() {
  local repo="$1"
  local ref="$2"
  local destination="$3"

  if [[ -d "${destination}/.git" ]]; then
    local actual_repo
    actual_repo="$(git -C "${destination}" remote get-url origin)"
    [[ "${actual_repo}" == "${repo}" ]] \
      || die "${destination} uses ${actual_repo}, expected ${repo}"
    [[ -z "$(git -C "${destination}" status --porcelain)" ]] \
      || die "Tool checkout has local changes: ${destination}"

    log "Updating tool dependency ${destination#"${ROOT_DIR}/"} (${ref})"
    git -C "${destination}" fetch --prune --tags origin
    if git -C "${destination}" show-ref --verify --quiet "refs/remotes/origin/${ref}"; then
      git -C "${destination}" checkout --quiet "${ref}"
      git -C "${destination}" merge --ff-only "origin/${ref}"
    else
      git -C "${destination}" fetch origin "${ref}"
      git -C "${destination}" checkout --quiet --detach FETCH_HEAD
    fi
    return
  fi

  [[ ! -e "${destination}" ]] \
    || die "Path exists but is not a Git checkout: ${destination}"

  log "Cloning tool dependency ${repo} (${ref})"
  mkdir -p "$(dirname -- "${destination}")"
  git clone --branch "${ref}" --single-branch "${repo}" "${destination}"
}

resolve_kicad_mcp_python() {
  local candidate resolved

  if [[ -n "${KICAD_MCP_PYTHON}" ]]; then
    candidate="${KICAD_MCP_PYTHON}"
    if [[ ! -x "${candidate}" ]]; then
      resolved="$(command -v "${candidate}" 2>/dev/null || true)"
      [[ -n "${resolved}" ]] \
        || die "KICAD_MCP_PYTHON is not executable: ${candidate}"
      candidate="${resolved}"
    fi
    "${candidate}" -c 'import pcbnew' >/dev/null 2>&1 \
      || die "KICAD_MCP_PYTHON cannot import pcbnew: ${candidate}"
    printf '%s\n' "${candidate}"
    return
  fi

  candidate="$(command -v python3 2>/dev/null || true)"
  if [[ -n "${candidate}" ]] \
    && "${candidate}" -c 'import pcbnew' >/dev/null 2>&1; then
    printf '%s\n' "${candidate}"
    return
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    for candidate in \
      /Applications/KiCad/KiCad.app/Contents/Frameworks/Python.framework/Versions/*/bin/python3 \
      /Applications/KiCAD/KiCad.app/Contents/Frameworks/Python.framework/Versions/*/bin/python3; do
      if [[ -x "${candidate}" ]] \
        && "${candidate}" -c 'import pcbnew' >/dev/null 2>&1; then
        printf '%s\n' "${candidate}"
        return
      fi
    done
  fi

  die "No Python interpreter can import pcbnew. Set KICAD_MCP_PYTHON to the Python shipped with KiCad."
}

install_kicad_mcp() {
  local python_exe venv_python exclude_file pattern

  python_exe="$(resolve_kicad_mcp_python)"
  exclude_file="${KICAD_MCP_DIR}/.git/info/exclude"
  for pattern in '/.venv/' '/node_modules/' '/dist/'; do
    grep -Fxq "${pattern}" "${exclude_file}" 2>/dev/null \
      || printf '%s\n' "${pattern}" >>"${exclude_file}"
  done

  log "Installing KiCad MCP Node dependencies"
  npm --prefix "${KICAD_MCP_DIR}" ci
  npm --prefix "${KICAD_MCP_DIR}" run build

  if [[ ! -x "${KICAD_MCP_DIR}/.venv/bin/python" ]]; then
    log "Creating KiCad MCP Python environment with ${python_exe}"
    "${python_exe}" -m venv --system-site-packages "${KICAD_MCP_DIR}/.venv" \
      || die "Unable to create the KiCad MCP virtual environment. Install Python venv support or set KICAD_MCP_PYTHON."
  fi
  venv_python="${KICAD_MCP_DIR}/.venv/bin/python"

  log "Installing KiCad MCP Python dependencies"
  "${venv_python}" -m pip install --disable-pip-version-check \
    --requirement "${KICAD_MCP_DIR}/requirements.txt"
  "${venv_python}" -c 'import pcbnew' >/dev/null 2>&1 \
    || die "KiCad MCP virtual environment cannot import pcbnew"

  log "Installed KiCad MCP ${KICAD_MCP_REF}"
}

link_kicad_happy_skills() {
  local skills_root="${ROOT_DIR}/.agents/skills"
  local manifest="${STATE_DIR}/kicad-happy-skills"
  local new_manifest="${manifest}.new"
  local skill_dir skill_name destination

  mkdir -p "${skills_root}" "${STATE_DIR}"
  : >"${new_manifest}"

  for skill_dir in "${KICAD_HAPPY_DIR}"/skills/*; do
    [[ -f "${skill_dir}/SKILL.md" ]] || continue
    skill_name="$(basename -- "${skill_dir}")"
    destination="${skills_root}/${skill_name}"

    if [[ -e "${destination}" && ! -L "${destination}" ]]; then
      die "Skill name collision at ${destination}"
    fi

    ln -sfn "../../.tools/kicad-happy/skills/${skill_name}" "${destination}"
    printf '%s\n' "${skill_name}" >>"${new_manifest}"
  done

  if [[ -f "${manifest}" ]]; then
    while IFS= read -r skill_name; do
      [[ -n "${skill_name}" ]] || continue
      if ! grep -Fxq "${skill_name}" "${new_manifest}" \
        && [[ -L "${skills_root}/${skill_name}" ]]; then
        rm "${skills_root}/${skill_name}"
      fi
    done <"${manifest}"
  fi

  mv "${new_manifest}" "${manifest}"
  log "Linked $(wc -l <"${manifest}") kicad-happy skills into .agents/skills"
}

install_datasheet_cli() {
  local installed_path cargo_install_root cargo_bin_dir

  if installed_path="$(command -v datasheet 2>/dev/null)" \
    && [[ "${installed_path}" != "${TOOLS_DIR}/bin/datasheet" ]]; then
    log "datasheet-cli is already installed: ${installed_path}"
    if [[ -e "${TOOLS_DIR}/bin/datasheet" || -L "${TOOLS_DIR}/bin/datasheet" ]]; then
      rm -f -- "${TOOLS_DIR}/bin/datasheet"
      log "Removed legacy project-local datasheet-cli"
    fi
    return
  fi

  if [[ -n "${installed_path:-}" ]]; then
    log "Ignoring legacy project-local datasheet-cli: ${installed_path}"
  fi

  require_command cargo
  require_command rustc

  if [[ -n "${DATASHEET_CLI_INSTALL_ROOT}" ]]; then
    cargo_install_root="${DATASHEET_CLI_INSTALL_ROOT}"
  elif [[ -n "${CARGO_INSTALL_ROOT:-}" ]]; then
    cargo_install_root="${CARGO_INSTALL_ROOT}"
  elif [[ -n "${CARGO_HOME:-}" ]]; then
    cargo_install_root="${CARGO_HOME}"
  elif [[ ":${PATH}:" == *":${HOME:?HOME is required}/.cargo/bin:"* ]]; then
    cargo_install_root="${HOME}/.cargo"
  elif [[ ":${PATH}:" == *":${HOME}/.local/bin:"* ]]; then
    cargo_install_root="${HOME}/.local"
  else
    cargo_install_root="${HOME}/.cargo"
  fi
  cargo_bin_dir="${cargo_install_root}/bin"

  case ":${PATH}:" in
    *":${cargo_bin_dir}:"*) ;;
    *)
      die "Cargo bin directory is not in PATH: ${cargo_bin_dir}. Add it to PATH and rerun bootstrap.sh."
      ;;
  esac

  log "Installing datasheet-cli into ${cargo_bin_dir}"
  cargo install \
    --git "${DATASHEET_CLI_REPO}" \
    --branch "${DATASHEET_CLI_REF}" \
    --root "${cargo_install_root}" \
    --locked \
    datasheet-cli

  if [[ -e "${TOOLS_DIR}/bin/datasheet" || -L "${TOOLS_DIR}/bin/datasheet" ]]; then
    rm -f -- "${TOOLS_DIR}/bin/datasheet"
    log "Removed legacy project-local datasheet-cli"
  fi

  hash -r
  installed_path="$(command -v datasheet 2>/dev/null || true)"
  [[ -n "${installed_path}" ]] \
    || die "datasheet-cli was installed but datasheet is still unavailable in PATH"
  log "Installed datasheet-cli: ${installed_path}"
}

write_environment() {
  cat >"${TOOLS_DIR}/env" <<EOF
# Generated by bootstrap.sh. Source this file in an interactive shell.
export KICAD_HAPPY_DIR="${KICAD_HAPPY_DIR}"
export KICAD_MCP_DIR="${KICAD_MCP_DIR}"
EOF
}

check_local_installation() {
  local failed=false installed_path

  [[ -d "${KICAD_HAPPY_DIR}/.git" ]] \
    || { log "MISSING: ${KICAD_HAPPY_DIR}"; failed=true; }
  [[ -d "${KICAD_MCP_DIR}/.git" ]] \
    || { log "MISSING: ${KICAD_MCP_DIR}"; failed=true; }
  [[ -f "${KICAD_MCP_DIR}/dist/index.js" ]] \
    || { log "MISSING: ${KICAD_MCP_DIR}/dist/index.js"; failed=true; }
  [[ -x "${KICAD_MCP_DIR}/.venv/bin/python" ]] \
    || { log "MISSING: ${KICAD_MCP_DIR}/.venv/bin/python"; failed=true; }

  if [[ -x "${KICAD_MCP_DIR}/.venv/bin/python" ]] \
    && ! "${KICAD_MCP_DIR}/.venv/bin/python" -c 'import pcbnew' >/dev/null 2>&1; then
    log "MISSING: pcbnew is unavailable in the KiCad MCP Python environment"
    failed=true
  fi

  if [[ -f "${KICAD_MCP_DIR}/dist/index.js" ]] \
    && ! node --check "${KICAD_MCP_DIR}/dist/index.js" >/dev/null 2>&1; then
    log "INVALID: KiCad MCP Node entry point"
    failed=true
  fi

  installed_path="$(command -v datasheet 2>/dev/null || true)"
  if [[ -z "${installed_path}" ]]; then
    log "MISSING: datasheet-cli is not available in PATH"
    failed=true
  elif [[ "${installed_path}" == "${TOOLS_DIR}/bin/datasheet" ]]; then
    log "MISSING: only the legacy project-local datasheet-cli was found"
    failed=true
  else
    log "FOUND: datasheet-cli at ${installed_path}"
  fi

  [[ -f "${TOOLS_DIR}/env" ]] \
    || { log "MISSING: ${TOOLS_DIR}/env"; failed=true; }

  if [[ -d "${KICAD_HAPPY_DIR}/skills" ]]; then
    local skill_dir skill_name
    for skill_dir in "${KICAD_HAPPY_DIR}"/skills/*; do
      [[ -f "${skill_dir}/SKILL.md" ]] || continue
      skill_name="$(basename -- "${skill_dir}")"
      [[ -L "${ROOT_DIR}/.agents/skills/${skill_name}" ]] \
        || { log "MISSING skill link: ${skill_name}"; failed=true; }
    done
  fi

  [[ "${failed}" == false ]] || exit 1
  log "Tool installation is ready"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      CHECK_ONLY=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      die "Unknown argument: $1"
      ;;
  esac
  shift
done

if [[ "${CHECK_ONLY}" == false ]]; then
  ensure_project_structure
fi

check_prerequisites

if [[ "${CHECK_ONLY}" == true ]]; then
  check_local_installation
  exit 0
fi

mkdir -p "${TOOLS_DIR}" "${STATE_DIR}"
sync_tool_repo "${KICAD_HAPPY_REPO}" "${KICAD_HAPPY_REF}" "${KICAD_HAPPY_DIR}"
link_kicad_happy_skills
sync_tool_repo "${KICAD_MCP_REPO}" "${KICAD_MCP_REF}" "${KICAD_MCP_DIR}"
install_kicad_mcp
install_datasheet_cli
write_environment
check_local_installation

log "Done. datasheet-cli and the project KiCad MCP server are ready"
