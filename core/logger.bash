declare -p __STARTHERE_BASH_LOGGER 2>/dev/null 1>&2 && return
export __STARTHERE_BASH_LOGGER

# public constants
readonly LOGGER_INFINITE=-1			# disallow log rotation

###############################################################################
# [public] wrappers to logger::log
# globals
#     none
# arguments
#     $1 : message to be logged
###############################################################################
alias logger::trace='logger::log "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}" TRACE'
alias logger::debug='logger::log "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}" DEBUG'
alias logger::info='logger::log "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}" INFO'
alias logger::warning='logger::log "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}" WARNING'
alias logger::error='logger::log "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}" ERROR'
alias logger::critical='logger::log "${BASH_SOURCE[0]##*/}" "${FUNCNAME:-null}" "${LINENO}" CRITICAL'

###############################################################################
# [public] set log level
#          valid values are TRACE | DEBUG | INFO | WARNING | ERROR | CRITICAL
# globals
#     _loggerLogLevel
# arguments
#     $1 : log level, default is INFO
# outputs
#     none
# returns
#     0 or 1 if $1 not in TRACE | DEBUG | INFO | WARNING | ERROR | CRITICAL
###############################################################################
function logger::setLevel()
{
	local iReturnCode=0
	local level="$( tr '[:lower:]' '[:upper:]' <<< "${1:-INFO}" )"

	case "${level}" in
		TRACE|DEBUG|INFO|WARNING|ERROR|CRITICAL)
			_loggerLogLevel="${level}"
		;;

		*)
			iReturnCode=1
		;;
	esac

	return ${iReturnCode}
}

###############################################################################
# [public] set log rotation
# globals
#     _loggerRotateLines
# arguments
#     $1 : log max rows, default is LOGGER_INFINITE
# outputs
#     none
# returns
#     0 or 1 if $1 is not an integer
###############################################################################
function logger::setRotate()
{
	local iReturnCode=0
	local re='^[-]?[0-9]+$'

	_loggerRotateLines="${1:-${LOGGER_INFINITE}}"

	if ! [[ ${_loggerRotateLines} =~ ${re} ]] ; then
		_loggerRotateLines=${LOGGER_INFINITE}
		iReturnCode=1
	fi

	return ${iReturnCode}
}

###############################################################################
# [public] set log date/time format as in `date` command (see: `man date`)
# globals
#     _loggerDateFormat
# arguments
#     $1 : date/time format, default is "+%Y-%m-%d %H:%M:%S.%3N"
# outputs
#     none
# returns
#     0
###############################################################################
function logger::setDateFormat()
{
	_loggerDateFormat="${1:-+%Y-%m-%d %H:%M:%S.%3N}"
}

###############################################################################
# [public] set 1 or more handler to send log data, ie:
#          logger::setHandlers "/dev/stdout" "/var/log/myapp.log"
#          be sure to set proper permissions to file to avoid errors during logger::log
# globals
#     _loggerHandlers
# arguments
#     $@ : log handler(s), default is "/dev/stderr"
# outputs
#     none
# returns
#     0
###############################################################################
function logger::setHandlers()
{
	local IFS=$'\n'
	_loggerHandlers=( "${@:-/dev/stderr}" )
}

###############################################################################
# [public] log the message
# globals
#     _loggerLogLevel
#     _loggerRotateLines
#     _loggerDateFormat
#     _loggerHandlers
# arguments
#     $1 : file name where message was raised
#     $2 : function where message was raised
#     $3 : file line number where message was raised
#     $4 : severity level of this entry
#     $5 : message for this entry
# outputs
#     formatted message, only if log handler is /dev/stdout or /dev/stderr or
#     if not able to save log to file; in this case, it prints to stderr
# returns
#     0 if success or 1 if not able to add to file
###############################################################################
function logger::log()
{
	local fileName="${1}"
	local funcName="${2}"
	local funcLineNumber="${3}"
	local level="${4}"
	local message="${5}"

	_logger::handle "${level}" "$( _logger::formatMessage "${fileName}" "${funcName}" "${funcLineNumber}" "${level}" "${message}" )"
}

###############################################################################
# [protected] get formatted message
# globals
#     _loggerDateFormat
# arguments
#     $1 : file name where message was raised
#     $2 : function where message was raised
#     $3 : file line number where message was raised
#     $4 : severity level of this entry
#     $5 : message for this entry
# outputs
#     colorized formatted message
# returns
#     0
###############################################################################
function _logger::formatMessage()
{
	local fileName="${UI_COLOR_BOLD_ON}${1}${UI_COLOR_RESET}"
	local funcName="${UI_COLOR_BOLD_ON}${2}${UI_COLOR_RESET}"
	local funcLineNumber="${UI_COLOR_BOLD_ON}${3}${UI_COLOR_RESET}"
	local level="${4}"
	local message="${5}"
	local levelFormatted="${level}"
	local messageFormatted="${message}"

	case "${level}" in
		TRACE)
			levelFormatted="${UI_COLOR_BOLD_ON}${UI_F_COLOR_CYAN}TRACE   ${UI_COLOR_RESET}"
		;;

		DEBUG)
			levelFormatted="${UI_COLOR_BOLD_ON}${UI_F_COLOR_BLUE}DEBUG   ${UI_COLOR_RESET}"
		;;

		INFO)
			levelFormatted="${UI_COLOR_BOLD_ON}${UI_F_COLOR_BLUE}INFO    ${UI_COLOR_RESET}"
		;;

		WARNING)
			levelFormatted="${UI_COLOR_BOLD_ON}${UI_F_COLOR_YELLOW}WARNING ${UI_COLOR_RESET}"
		;;

		ERROR)
			levelFormatted="${UI_COLOR_BOLD_ON}${UI_F_COLOR_RED}ERROR   ${UI_COLOR_RESET}"
		;;

		CRITICAL)
			levelFormatted="${UI_COLOR_BOLD_ON}${UI_B_COLOR_RED}${UI_F_COLOR_WHITE}CRITICAL${UI_COLOR_RESET}"
		;;
	esac

	messageFormatted="$( date "${_loggerDateFormat}" ) | ${levelFormatted} | ${fileName}->${funcName}( ${funcLineNumber} ) | ${message}"
	printf "%b" "${messageFormatted}"
}

###############################################################################
# [protected] iterate through handlers to log to file and/or print in screen
#             fallback to stderr if not able to save log file
# globals
#     _loggerLogLevel
#     _loggerRotateLines
#     _loggerHandlers
# arguments
#     $1 : severity level of this entry
#     $2 : formated message for this entry
# outputs
#     colorized formatted message to stdout/stderr and/or decolorized to log file
# returns
#     0 if success or 1 if failed to save log file
###############################################################################
function _logger::handle()
{
	local IFS=$'\n'

	local iReturnCode=0		# everything went well
	local bLog=false		# is it needed to log this message?
	local level="${1}"		# log level
	local message="${2}"	# the message to be logged
	local logHandler=""

	# variables needed in case of failure while saving log
	local iTmpReturnCode=0
	local internalLogErrorMessage=""
	local internalLogErrorMessageFormatted=""

	case "${_loggerLogLevel}" in
		TRACE)
			bLog=true
		;;

		DEBUG)
			[[ "${level}" != "TRACE" ]] && bLog=true
		;;

		INFO)
			[[ "${level}" != "TRACE" ]] && [[ "${level}" != "DEBUG" ]] && bLog=true
		;;

		WARNING)
			[[ "${level}" != "TRACE" ]] && [[ "${level}" != "DEBUG" ]] && [[ "${level}" != "INFO" ]] && bLog=true
		;;

		ERROR)
			[[ "${level}" != "TRACE" ]] && [[ "${level}" != "DEBUG" ]] && [[ "${level}" != "INFO" ]] && [[ "${level}" != "WARNING" ]] && bLog=true
		;;

		CRITICAL)
			[[ "${level}" == "CRITICAL" ]] && bLog=true
		;;
	esac

	[[ ${bLog} == true ]] && for logHandler in "${_loggerHandlers[@]}" ; do

		case "${logHandler}" in
			/dev/stdout|/dev/stderr)
				printf "%b" "${message}\n" > "${logHandler}"
			;;

			*)
				internalLogErrorMessage=$( { printf "%b" "${message}\n" | ui::decolor >> "${logHandler}" ; } 2>&1 ) || iTmpReturnCode=$?

				if (( iTmpReturnCode != 0 )) ; then
					iReturnCode=${iTmpReturnCode}

					internalLogErrorMessageFormatted=$( \
						_logger::formatMessage \
							"${BASH_SOURCE[0]##*/}" \
							"${FUNCNAME[0]}" \
							"${LINENO}" \
							ERROR \
							"Runtime error: [ ${UI_COLOR_BOLD_ON}${internalLogErrorMessage}${UI_COLOR_RESET} ] while logging [ $( printf "%b" "${message}" | ui::decolor ) ]"
					)

					printf "%b" "${internalLogErrorMessageFormatted}\n" > /dev/stderr
				else
					_logger::rotate "${logHandler}"
				fi
			;;
		esac
	done

	return ${iReturnCode}
}

###############################################################################
# [protected] truncate log file up to max lines allowed
# globals
#     _loggerRotateLines
# arguments
#     $1 : the file to be rotated
# outputs
#     none
# returns
#     0
###############################################################################
function _logger::rotate()
{
	local logFileName="${1}"

	if (( _loggerRotateLines <= LOGGER_INFINITE )) ; then
		:
	elif (( _loggerRotateLines == 0 )) ; then
		# shellcheck disable=SC2188
		> "${logFileName}"
	else
		# shellcheck disable=SC2016
		sed --in-place --expression=':a' --expression='$q;N;'$(( _loggerRotateLines + 1 ))',$D;ba' "${logFileName}"
	fi
}

_loggerLogLevel=INFO
_loggerRotateLines=${LOGGER_INFINITE}
_loggerDateFormat="+%Y-%m-%d %H:%M:%S.%3N"
_loggerHandlers=( "/dev/stderr" )
