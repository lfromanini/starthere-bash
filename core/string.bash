# shellcheck disable=SC2119,SC2120

declare -p __STARTHERE_BASH_STRING 2>/dev/null 1>&2 && return
export __STARTHERE_BASH_STRING

###############################################################################
# [public] print string length
#          also accepts being piped
# globals
#     none
# arguments
#     $1 : the string
# outputs
#     the string size
# returns
#     0
###############################################################################
string::size()
{
	local s=""

	(( $# == 0 )) && s="$( </dev/stdin )" || s="${1}"
	printf "%d" "${#s}"
}

###############################################################################
# [public] trim string
#          also accepts being piped
# globals
#     none
# arguments
#     $1 : the string
# outputs
#     trimmed string
# returns
#     0
###############################################################################
function string::trim()
{
	local s=""

	(( $# == 0 )) && s="$( </dev/stdin )" || s="${1}"
	string::ltrim "${s}" | string::rtrim
}

###############################################################################
# [public] trim left side of string
#          also accepts being piped
# globals
#     none
# arguments
#     $1 : the string
# outputs
#     left-trimmed string
# returns
#     0
###############################################################################
function string::ltrim()
{
	local s="${1:-}"

	if (( $# == 0 )) ; then
		sed --regexp-extended 's/^[[:space:]\\t]*//'
	else
		printf "%b" "${s}" | sed --regexp-extended 's/^[[:space:]]*//'
	fi
}

###############################################################################
# [public] trim right side of string
#          also accepts being piped
# globals
#     none
# arguments
#     $1 : the string
# outputs
#     right-trimmed string
# returns
#     0
###############################################################################
function string::rtrim()
{
	local s="${1:-}"

	if (( $# == 0 )) ; then
		sed --regexp-extended 's/[[:space:]\\t]*$//'
	else
		printf "%b" "${s}" | sed --regexp-extended 's/[[:space:]]*$//'
	fi
}

###############################################################################
# [public] convert string to lowercase
#          also accepts being piped
# globals
#     none
# arguments
#     $* : the string
# outputs
#     string converted to lowercase
# returns
#     0
###############################################################################
function string::toLower()
{
	local s=""

	(( $# == 0 )) && s="$( </dev/stdin )" || s="${*}"
	printf "%b" "${s,,}"
}

###############################################################################
# [public] convert string to uppercase
#          also accepts being piped
# globals
#     none
# arguments
#     $* : the string
# outputs
#     string converted to uppercase
# returns
#     0
###############################################################################
function string::toUpper()
{
	local s=""

	(( $# == 0 )) && s="$( </dev/stdin )" || s="${*}"
	printf "%b" "${s^^}"
}

###############################################################################
# [public] convert string to ascii
#          also accepts being piped
# globals
#     none
# arguments
#     $* : the string
# outputs
#     string converted to ascii
# returns
#     0
###############################################################################
function string::ascii()
{
	local s="${*}"

	if (( $# == 0 )) ; then
		sed "y/àáâäæãåāǎçćčèéêëēėęěîïííīįìǐłñńôöòóœøōǒõßśšûüǔùǖǘǚǜúūÿžźżÀÁÂÄÆÃÅĀǍÇĆČÈÉÊËĒĖĘĚÎÏÍÍĪĮÌǏŁÑŃÔÖÒÓŒØŌǑÕẞŚŠÛÜǓÙǕǗǙǛÚŪŸŽŹŻ/aaaaaaaaaccceeeeeeeeiiiiiiiilnnooooooooosssuuuuuuuuuuyzzzAAAAAAAAACCCEEEEEEEEIIIIIIIILNNOOOOOOOOOSSSUUUUUUUUUUYZZZ/"
	else
		printf "%b" "${s}" | sed "y/àáâäæãåāǎçćčèéêëēėęěîïííīįìǐłñńôöòóœøōǒõßśšûüǔùǖǘǚǜúūÿžźżÀÁÂÄÆÃÅĀǍÇĆČÈÉÊËĒĖĘĚÎÏÍÍĪĮÌǏŁÑŃÔÖÒÓŒØŌǑÕẞŚŠÛÜǓÙǕǗǙǛÚŪŸŽŹŻ/aaaaaaaaaccceeeeeeeeiiiiiiiilnnooooooooosssuuuuuuuuuuyzzzAAAAAAAAACCCEEEEEEEEIIIIIIIILNNOOOOOOOOOSSSUUUUUUUUUUYZZZ/"
	fi
}
