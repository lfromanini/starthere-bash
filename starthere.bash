declare -p __STARTHERE_BASH 2>/dev/null 1>&2 && return
export __STARTHERE_BASH

# bash options
shopt -s expand_aliases				# allow alias

# public constants
readonly STARTHERE_BASH_PATH="$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly STARTHERE_BASH_CORE_PATH="${STARTHERE_BASH_PATH}"/core
readonly STARTHERE_BASH_ADDON_PATH="${STARTHERE_BASH_PATH}"/addon

# load starthere.bash libraries
source "${STARTHERE_BASH_CORE_PATH}"/args.bash
source "${STARTHERE_BASH_CORE_PATH}"/dependency.bash
source "${STARTHERE_BASH_CORE_PATH}"/logger.bash
source "${STARTHERE_BASH_CORE_PATH}"/string.bash
source "${STARTHERE_BASH_CORE_PATH}"/ui.bash

# check for mandatory tools
dependency::assert \
	sed \
	"${UI_COLOR_BOLD_ON}${UI_COLOR_UNDERLINE_ON}${UI_F_COLOR_YELLOW}starthere.bash${UI_COLOR_RESET}: command not found [ ${UI_COLOR_BOLD_ON}sed${UI_COLOR_RESET} ]"
