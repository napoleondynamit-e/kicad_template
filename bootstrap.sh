#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${ROOT_DIR}/$(basename -- "${BASH_SOURCE[0]}")"
TOOLS_DIR="${ROOT_DIR}/.tools"

TEMPLATE_REPO="${TEMPLATE_REPO:-https://github.com/napoleondynamit-e/kicad_template.git}"
TEMPLATE_REF="${TEMPLATE_REF:-master}"
KICAD_HAPPY_REPO="${KICAD_HAPPY_REPO:-https://github.com/napoleondynamit-e/kikcad-happy.git}"
KICAD_HAPPY_REF="${KICAD_HAPPY_REF:-main}"
DATASHEET_CLI_REPO="${DATASHEET_CLI_REPO:-https://github.com/napoleondynamit-e/datasheet-cli.git}"
DATASHEET_CLI_REF="${DATASHEET_CLI_REF:-master}"

KICAD_HAPPY_DIR="${TOOLS_DIR}/kicad-happy"

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

populate_project() {
  local temp_dir checkout_dir

  if [[ -f "${ROOT_DIR}/AGENTS.md" \
    && -f "${ROOT_DIR}/README.md" \
    && -f "${ROOT_DIR}/SETUP.md" ]]; then
    log "Project structure already exists; template copy skipped"
    return
  fi

  if find "${ROOT_DIR}" -mindepth 1 -maxdepth 1 ! -name bootstrap.sh -print -quit \
    | grep -q .; then
    die "Target directory must be empty except for bootstrap.sh: ${ROOT_DIR}"
  fi

  require_command git
  require_command tar

  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/kicad-template.XXXXXXXX")"
  checkout_dir="${temp_dir}/template"

  cleanup() {
    rm -rf -- "${temp_dir}"
  }
  trap cleanup EXIT

  log "Downloading project template ${TEMPLATE_REF}"
  git clone --quiet --depth 1 --branch "${TEMPLATE_REF}" \
    "${TEMPLATE_REPO}" "${checkout_dir}"
  git -C "${checkout_dir}" archive HEAD \
    | tar --exclude=bootstrap.sh -xf - -C "${ROOT_DIR}"
  chmod +x "${ROOT_DIR}/bootstrap.sh"

  cleanup
  trap - EXIT
  log "Created project structure"
}

install_datasheet_cli() {
  local installed_path

  installed_path="$(command -v datasheet 2>/dev/null || true)"
  if [[ -n "${installed_path}" ]]; then
    log "datasheet-cli already available: ${installed_path}"
    return
  fi

  require_command cargo
  log "Installing datasheet-cli"
  cargo install \
    --git "${DATASHEET_CLI_REPO}" \
    --branch "${DATASHEET_CLI_REF}" \
    --locked \
    datasheet-cli

  hash -r
  installed_path="$(command -v datasheet 2>/dev/null || true)"
  [[ -n "${installed_path}" ]] \
    || die "datasheet-cli was installed, but its bin directory is not in PATH"
  log "Installed datasheet-cli: ${installed_path}"
}

install_kicad_happy() {
  if [[ -d "${KICAD_HAPPY_DIR}/.git" ]]; then
    log "kicad-happy already installed: ${KICAD_HAPPY_DIR}"
    return
  fi

  [[ ! -e "${KICAD_HAPPY_DIR}" ]] \
    || die "Path exists but is not a Git checkout: ${KICAD_HAPPY_DIR}"

  require_command git
  mkdir -p "${TOOLS_DIR}"
  log "Installing kicad-happy ${KICAD_HAPPY_REF}"
  git clone --depth 1 --branch "${KICAD_HAPPY_REF}" \
    "${KICAD_HAPPY_REPO}" "${KICAD_HAPPY_DIR}"
}

link_kicad_happy_skills() {
  local skills_root="${ROOT_DIR}/.agents/skills"
  local skill_dir skill_name destination expected_target

  mkdir -p "${skills_root}"

  for skill_dir in "${KICAD_HAPPY_DIR}"/skills/*; do
    [[ -f "${skill_dir}/SKILL.md" ]] || continue
    skill_name="$(basename -- "${skill_dir}")"
    destination="${skills_root}/${skill_name}"
    expected_target="../../.tools/kicad-happy/skills/${skill_name}"

    if [[ -L "${destination}" ]] \
      && [[ "$(readlink -- "${destination}")" == "${expected_target}" ]]; then
      continue
    fi

    [[ ! -e "${destination}" && ! -L "${destination}" ]] \
      || die "Skill name collision at ${destination}"
    ln -s "${expected_target}" "${destination}"
  done

  log "kicad-happy skills are linked"
}

remove_downloaded_bootstrap() {
  if command -v git >/dev/null 2>&1 \
    && git -C "${ROOT_DIR}" ls-files --error-unmatch \
      -- "$(basename -- "${SCRIPT_PATH}")" >/dev/null 2>&1; then
    return
  fi

  log "Removing downloaded bootstrap script"
  rm -- "${SCRIPT_PATH}"
}

case "${1:-}" in
  "") ;;
  -h|--help)
    printf '%s\n' \
      'Usage: ./bootstrap.sh' \
      'Creates a project from the template and installs datasheet-cli and kicad-happy.' \
      'A downloaded copy removes itself after successful completion.'
    exit 0
    ;;
  *)
    die "Unknown argument: $1"
    ;;
esac

populate_project
install_datasheet_cli
install_kicad_happy
link_kicad_happy_skills

log "Done"
remove_downloaded_bootstrap
