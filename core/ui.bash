# shellcheck disable=SC2034

declare -p __STARTHERE_BASH_UI 2>/dev/null 1>&2 && return
export __STARTHERE_BASH_UI

###############################################################################
# [public] remove colors from string
#          also accepts being piped
# globals
#     none
# arguments
#     $* : the string
# outputs
#     decolorized string
# returns
#     0
###############################################################################
function ui::decolor()
{
	local s="${*}"

	if (( $# == 0 )) ; then
		sed --regexp-extended "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g"
	else
		printf "%b" "${s}" | sed --regexp-extended "s/\x1B\[(([0-9]{1,2})?(;)?([0-9]{1,2})?)?[m,K,H,f,J]//g"
	fi
}

###############################################################################
# [public] tests if the terminal is unicode
# globals
#    none
# arguments
#    none
# outputs
#    none
# returns
#    bool
###############################################################################
function ui::isUnicode() { [[ $( printf "%b" '\xe2\x82\xac' ) == '€' ]] ; }

# colors
readonly __UI_COLOR_ESC='\x1B'

# shellcheck disable=SC1009,SC1019,SC1072,SC1073
if (( $( tput colors 2>/dev/null || echo 0 ) >= 16 )) && [ -t ] ; then

	# foreground
	readonly UI_F_COLOR_BLACK="${__UI_COLOR_ESC}[30m"
	readonly UI_F_COLOR_RED="${__UI_COLOR_ESC}[31m"
	readonly UI_F_COLOR_GREEN="${__UI_COLOR_ESC}[32m"
	readonly UI_F_COLOR_YELLOW="${__UI_COLOR_ESC}[33m"
	readonly UI_F_COLOR_BLUE="${__UI_COLOR_ESC}[34m"
	readonly UI_F_COLOR_PURPLE="${__UI_COLOR_ESC}[35m"
	readonly UI_F_COLOR_CYAN="${__UI_COLOR_ESC}[36m"
	readonly UI_F_COLOR_WHITE="${__UI_COLOR_ESC}[37m"

	# background
	readonly UI_B_COLOR_BLACK="${__UI_COLOR_ESC}[40m"
	readonly UI_B_COLOR_RED="${__UI_COLOR_ESC}[41m"
	readonly UI_B_COLOR_GREEN="${__UI_COLOR_ESC}[42m"
	readonly UI_B_COLOR_YELLOW="${__UI_COLOR_ESC}[43m"
	readonly UI_B_COLOR_BLUE="${__UI_COLOR_ESC}[44m"
	readonly UI_B_COLOR_PURPLE="${__UI_COLOR_ESC}[45m"
	readonly UI_B_COLOR_CYAN="${__UI_COLOR_ESC}[46m"
	readonly UI_B_COLOR_WHITE="${__UI_COLOR_ESC}[47m"

	# bold, italic...
	readonly UI_COLOR_BOLD_ON="${__UI_COLOR_ESC}[1m"
	readonly UI_COLOR_BOLD_OFF="${__UI_COLOR_ESC}[22m"
	readonly UI_COLOR_ITALIC_ON="${__UI_COLOR_ESC}[3m"
	readonly UI_COLOR_ITALIC_OFF="${__UI_COLOR_ESC}[23m"
	readonly UI_COLOR_UNDERLINE_ON="${__UI_COLOR_ESC}[4m"
	readonly UI_COLOR_UNDERLINE_OFF="${__UI_COLOR_ESC}[24m"
	readonly UI_COLOR_INVERTED_ON="${__UI_COLOR_ESC}[7m"
	readonly UI_COLOR_INVERTED_OFF="${__UI_COLOR_ESC}[27m"

	# reset
	readonly UI_COLOR_RESET="${__UI_COLOR_ESC}[0m"

else

	# foreground
	readonly UI_F_COLOR_BLACK=""
	readonly UI_F_COLOR_RED=""
	readonly UI_F_COLOR_GREEN=""
	readonly UI_F_COLOR_YELLOW=""
	readonly UI_F_COLOR_BLUE=""
	readonly UI_F_COLOR_PURPLE=""
	readonly UI_F_COLOR_CYAN=""
	readonly UI_F_COLOR_WHITE=""

	# background
	readonly UI_B_COLOR_BLACK=""
	readonly UI_B_COLOR_RED=""
	readonly UI_B_COLOR_GREEN=""
	readonly UI_B_COLOR_YELLOW=""
	readonly UI_B_COLOR_BLUE=""
	readonly UI_B_COLOR_PURPLE=""
	readonly UI_B_COLOR_CYAN=""
	readonly UI_B_COLOR_WHITE=""

	# bold, italic...
	readonly UI_COLOR_BOLD_ON=""
	readonly UI_COLOR_BOLD_OFF=""
	readonly UI_COLOR_ITALIC_ON=""
	readonly UI_COLOR_ITALIC_OFF=""
	readonly UI_COLOR_UNDERLINE_ON=""
	readonly UI_COLOR_UNDERLINE_OFF=""
	readonly UI_COLOR_INVERTED_ON=""
	readonly UI_COLOR_INVERTED_OFF=""

	# reset
	readonly UI_COLOR_RESET=""

fi
