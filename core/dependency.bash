declare -p __STARTHERE_DEPENDENCY 2>/dev/null 1>&2 && return
export __STARTHERE_DEPENDENCY

###############################################################################
# [public] wrapper to _dependency::assert
# globals
#     none
# arguments
#     $1 : the command to be searched
#     $2 [optional] : the message to be logged, defaults to
#     Runtime error: command not found [ ${UI_COLOR_BOLD_ON}${cmd}${UI_COLOR_RESET} ]
###############################################################################
alias dependency::assert='_dependency::assert "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}"'

###############################################################################
# [public] check if a command is available in system
# globals
#     none
# arguments
#     $1 : the command to be searched
# outputs
#     none
# returns
#     0 if command exists, or 1 if no such command
###############################################################################
function dependency::available()
{
	local cmd="${1}"

	# https://stackoverflow.com/questions/592620/how-can-i-check-if-a-program-exists-from-a-bash-script/677212
	hash "${cmd}" 2>/dev/null
}

###############################################################################
# [protected] log and exits if command is unavailable
# globals
#     none
# arguments
#     $1 : file name that called this function, to be used in logger
#     $2 : function name that called this function, to be used in logger
#     $3 : line number that called this function, to be used in logger
#     $4 : the command to be searched
#     $5 [optional] : the message to be logged, defaults to
#     Runtime error: command not found [ ${UI_COLOR_BOLD_ON}${cmd}${UI_COLOR_RESET} ]
# outputs
#     none
# returns
#     0 if command exists, otherwise 127
###############################################################################
function _dependency::assert()
{
	local fileName="${1}"
	local funcName="${2}"
	local funcLineNumber="${3}"
	local cmd="${4}"
	local message="${5:-Runtime error: command not found [ ${UI_COLOR_BOLD_ON}${cmd}${UI_COLOR_RESET} ]}"

	if ! dependency::available "${cmd}" ; then
		logger::log "${fileName}" "${funcName}" "${funcLineNumber}" CRITICAL "${message}"
		exit 127
	fi
}
