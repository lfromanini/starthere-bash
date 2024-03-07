declare -p __STARTHERE_BASH_ARGS 2>/dev/null 1>&2 && return
export __STARTHERE_BASH_ARGS

###############################################################################
# [public] define valid arguments
#          long format and/or short format must be suplied
# globals
#     _argsLongFormat
#     _argsShortFormat
#     _argsValue
# arguments
#     $1 : argument long format, ie --myArgument
#     $2 : argument short format, ie -a
# outputs
#     none
# returns
#     0 if at least a non-empty $1 or $2 is provided, otherwise, 1
###############################################################################
function args::define()
{
	local IFS=$'\n'

	local longFormat="${1}"
	local shortFormat="${2}"
	local iReturnCode=0

	[[ "${longFormat:0:2}" == "--" ]] && longFormat="${longFormat:2}"
	[[ "${shortFormat:0:1}" == "-" ]] && shortFormat="${shortFormat:1}"

	if [[ -z "${longFormat}" && -z "${shortFormat}" ]] ; then
		iReturnCode=1
	else
		_argsLongFormat+=( "${longFormat}" )
		_argsShortFormat+=( "${shortFormat}" )
		_argsValue+=( "" )
	fi

	return ${iReturnCode}
}

###############################################################################
# [public] used to parse arguments received as input from cli
# globals
#     _argsLongFormat
#     _argsShortFormat
#     _argsValue
#     _argsUnknown
# arguments
#     $@ : all arguments to be parsed
# outputs
#     none
# returns
#     0 if no undefined argument found, otherwise, 1
###############################################################################
function args::parse()
{
	local IFS=$'\n'

	local iReturnCode=0
	local idx=-1
	local bFound=false
	local arg=""
	local lValue=""
	local rValue=""

	for arg in "$@" ; do

		case "${arg}" in
			--)
				break								# stops parsing parameters
			;;

			--*=*)
				lValue=$( cut --delimiter="=" --field=1 <<< "${arg}" | cut --delimiter="-" --field=3 )
				rValue=$( cut --delimiter="=" --field="2-" <<< "${arg}" )

				for idx in "${!_argsLongFormat[@]}" ; do
					if [[ "${lValue}" == "${_argsLongFormat[idx]}" ]] ; then
						_argsValue[idx]="${rValue}"
						idx=-1
						bFound=true
						break
					fi
				done

				if [[ ${bFound} == true ]] ; then
					bFound=false
				else								# argument not defined
					_argsUnknown+=( "${arg}" )
					idx=-1
					iReturnCode=1
				fi
			;;

			--*)
				lValue=$( cut --delimiter="-" --field="3-" <<< "${arg}" )
				rValue=true							# default value

				for idx in "${!_argsLongFormat[@]}" ; do
					if [[ "${lValue}" == "${_argsLongFormat[idx]}" ]] ; then
						_argsValue[idx]="${rValue}"
						bFound=true
						break
					fi
				done

				if [[ ${bFound} == true ]] ; then
					bFound=false
				else								# argument not defined
					_argsUnknown+=( "${arg}" )
					iReturnCode=1
				fi
			;;

			-*)
				lValue=$( cut --delimiter="-" --field="2-" <<< "${arg}" )
				rValue=true							# default value

				for idx in "${!_argsShortFormat[@]}" ; do
					if [[ "${lValue}" == "${_argsShortFormat[idx]}" ]] ; then
						_argsValue[idx]="${rValue}"
						bFound=true
						break
					fi
				done

				if [[ ${bFound} == true ]] ; then
					bFound=false
				else								# argument not defined
					_argsUnknown+=( "${arg}" )
					iReturnCode=1
				fi
			;;

			*)
				if (( idx == -1 )) ; then		# argument not defined
					_argsUnknown+=( "${arg}" )
					iReturnCode=1
				else
					rValue="${arg}"
					_argsValue[idx]="${rValue}"		# overwrite default value
					idx=-1							# reset index
				fi
			;;
		esac
	done

	return ${iReturnCode}
}

###############################################################################
# [public] get argument value
# globals
#     _argsLongFormat
#     _argsShortFormat
#     _argsValue
# arguments
#     $1 : long or shor argument to search value
# outputs
#     argument value
# returns
#     0
###############################################################################
function args::getValue()
{
	local strSearch="${1}"
	local strValue=""

	strValue=$( args::getValueByLongFormat "${strSearch}" )
	[[ -z "${strValue}" ]] && strValue=$( args::getValueByShortFormat "${strSearch}" )

	printf "%s" "${strValue}"
}

###############################################################################
# [public] get all undefined arguments
# globals
#     _argsUnknown
# arguments
#     $1 [optional] : separator, default is "\n"
# outputs
#     all undefined arguments, separated by $1
# returns
#     0
###############################################################################
function args::getUndefinedArgs()
{
	local IFS=$'\n'

	local separator="${1:-\n}"
	local arg=""

	for arg in "${_argsUnknown[@]}" ; do
		printf "%s%b" "${arg}" "${separator}"
	done
}

###############################################################################
# [public] get argument value using long format as input
# globals
#     _argsLongFormat
#     _argsValue
# arguments
#     $1 : long argument to search value
# outputs
#     argument value
# returns
#     0
###############################################################################
function args::getValueByLongFormat()
{
	local IFS=$'\n'

	local strSearch="${1}"
	local strValue=""
	local idx=0

	[[ "${strSearch:0:2}" == "--" ]] && strSearch="${strSearch:2}"

	for idx in "${!_argsLongFormat[@]}" ; do
		if [[ "${strSearch}" == "${_argsLongFormat[idx]}" ]] ; then
			strValue="${_argsValue[idx]}"
			break
		fi
	done

	printf "%s" "${strValue}"
}

###############################################################################
# [public] get argument value using short format as input
# globals
#     _argsShortFormat
#     _argsValue
# arguments
#     $1 : short argument to search value
# outputs
#     argument value
# returns
#     0
###############################################################################
function args::getValueByShortFormat()
{
	local IFS=$'\n'

	local strSearch="${1}"
	local strValue=""
	local idx=0

	[[ "${strSearch:0:1}" == "-" ]] && strSearch="${strSearch:1}"

	for idx in "${!_argsShortFormat[@]}" ; do
		if [[ "${strSearch}" == "${_argsShortFormat[idx]}" ]] ; then
			strValue="${_argsValue[idx]}"
			break
		fi
	done

	printf "%s" "${strValue}"
}

_argsLongFormat=()
_argsShortFormat=()
_argsValue=()
_argsUnknown=()
