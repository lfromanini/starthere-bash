<img align="right" src="https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg">

# StartHere.bash
A starting point to write bash scripts, with a framework that doesn't step on your way

```
 ____  _             _   _   _                 _               _     
/ ___|| |_ __ _ _ __| |_| | | | ___ _ __ ___  | |__   __ _ ___| |__  
\___ \| __/ _` | '__| __| |_| |/ _ \ '__/ _ \ | '_ \ / _` / __| '_ \ 
 ___) | || (_| | |  | |_|  _  |  __/ | |  __/_| |_) | (_| \__ \ | | |
|____/ \__\__,_|_|   \__|_| |_|\___|_|  \___(_)_.__/ \__,_|___/_| |_|

```

## Description

[StartHere.bash](https://github.com/lfromanini/starthere-bash) is a simple but very effective framework written to facilitate the process of creating [bash](https://en.wikipedia.org/wiki/Bash_(Unix_shell)) scripts without having to repeat common functionality like arguments parsing, dependency management or logging. It's designed to let the programmer decide the way the software will operate, so it's not intrusive; and in the majority of Linux distributions will not demand any additional package to be installed (see [Requirements](https://github.com/lfromanini/starthere-bash#requirements)). If a functionallity requires more dependencies, it will be provided as an add-on, and it will have to be sourced separatelly. StartHere.bash also doesn't assume anything besides aliases expansion, which is already set in StartHere.bash main script. It's up to the developer to decide to use or not to use `set -o nounset` to disallow unbound variables, `set -o pipefail`, to prevents errors in a pipeline from being masked, `set -o errexit`...

StartHere.bash uses the following standards:

* constants are written in UPPERCASE.
* if a function or variable starts with two underscores, it's intended to be private, and should not be directly accessed.
* if a function or variable starts with a single underscore, it's intended to be protected, and it can be accessed or overwritten by an add-on.
* if not starting with underscores, it's public and can be directly accessed.

All functions are commented, in a way to make clear which internal variables are changed, and, mainly, what's the expected parameters for that function.
For `logger::setRotate`, we have:

```text
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
```

Meaning that it's a public function, that intends to configure the log rotation policy, changing the protected variable `_loggerRotateLines`. It accepts one argument with the maximum row number that should be kept in log files. If not provided, `LOGGER_INFINITE` will be assumed. No output is generated, ie: nothing will be echoed. This function returns `0` if success or `1` if a not integer number was informed (so this must be handled carefully, if using `set -o errexit`).

## Examples

In a real use case, you might clone this repository as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) and put your script in the root path. These samples assumes:

```text
( your script location )
└── starthere-bash
    ├── core
    │   ├── args.bash
    │   ├── dependency.bash
    │   └── ( ... )
    ├── LICENSE
    ├── README.md
    └── starthere.bash
```

### string

String functions are helpers with common string operations. They usually accepts arguments or can even be piped! Some examples are: `string::trim`, `string::rtrim`, `string::size`, `string::toUpper`, `string::toLower`...

```bash
source "$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/starthere-bash/starthere.bash

printf "   trim_my_data   " | string::trim
```

### ui

Functions relative with user interface, as well some constants to colorize/decolorize the output. Some functions are: `ui::isUnicode` and `ui::decolor`.

```bash
source "$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/starthere-bash/starthere.bash

printf "${UI_COLOR_BOLD_ON}${UI_B_COLOR_BLUE}${UI_F_COLOR_CYAN}Colored output${UI_COLOR_RESET}"
```

### dependency

Checks if a dependency is available or abort the program execution with "command not found". Ie:

```bash
source "$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/starthere-bash/starthere.bash

AWK=gawk

if ! dependency::available "gawk" ; then
	# GNU awk not available, fallback to mawk
	AWK=mawk
fi
```

Or quit the program if the dependency is mandatory:

```bash
source "$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/starthere-bash/starthere.bash

dependency::assert "gawk"
```

### logger

Functions to facilitate logging. Defaults to `stderr`, but it's possible to log to a file as well. Log rotation and date/time format are configurable!

```bash
source "$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/starthere-bash/starthere.bash

logFile="/var/log/myProgram.log"

# logs to stderr and to log file
logger::setHandlers "/dev/stderr" "${logFile}"

logger::info "StartHere.bash is amazing"
logger::warning "Do not forget to check other functions"
```

### args

Functions to handle arguments in a cli program. Example:

```bash
source "$( builtin cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/starthere-bash/starthere.bash

handleArgs()
{
	# long and/or short options are accepted
	args::define "--help" "-h"
	args::define "--myArgument"

	args::parse "$@"

	if [[ "$( args::getValue "--help" )" ]] ; then
		printf "Help wanted"
	fi

	myArgument="$( args::getValue "--myArgument" )"
	printf "myArgument is [ ${myArgument} ]"
}

handleArgs "$@"
```

#### Requirements

* The [GNU Core Utilities](https://en.wikipedia.org/wiki/GNU_Core_Utilities) are the basic file, shell, and text manipulation utilities of the GNU operating system. These are the core utilities which are expected to exist on every operating system.
* The stream editor [sed](https://linux.die.net/man/1/sed) is used to perform basic text transformations on an input stream.

## LICENSE

The [MIT License](https://github.com/lfromanini/starthere-bash/blob/main/LICENSE) (MIT)
