## Welcome!

I'm so glad you've found this project interesting and useful enough that you'd
like to contribute to its development.

Please take time to review the policies and procedures in this document prior
to making and submitting any changes.

This guide was drafted with tips from [Wrangling Web Contributions: How to
Build a CONTRIBUTING.md](https://mozillascience.github.io/working-open-workshop/contributing/)
and with some inspiration from [the Atom project's CONTRIBUTING.md
file](https://github.com/atom/atom/blob/master/CONTRIBUTING.md).

## Table of contents

- [Quick links](#quick-links)
- [Code of conduct](#code-of-conduct)
- [Reporting issues](#reporting-issues)
- [Updating documentation](#updating-documentation)
- [Environment setup](#environment-setup)
- [Workflow](#workflow)
- [Testing](#testing)
- [Coding conventions](#coding-conventions)
- [Public domain](#public-domain)

## Quick links

- [README](README.md)
- [Code of conduct](CODE_OF_CONDUCT.md)
- [License information](LICENSE.md)
- [Original repository](https://github.com/mbland/go-script-bash/)
- [Issues](https://github.com/mbland/go-script-bash/issues)
- [Pull requests](https://github.com/mbland/go-script-bash/pulls)
- [Issues](https://github.com/mbland/go-script-bash/issues)

## Code of conduct

Harrassment or rudeness of any kind will not be tolerated, period. For
specifics, see the [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md) file.

## Reporting issues

Before reporting an issue, please use the search feature on the [issues
page](https://github.com/mbland/go-script-bash/issues) to see if an issue
matching the one you've observed has already been filed.

If you do find one...

### Do not add a +1 comment!

If you find an issue that interests you, but you have nothing material to
contribute to the thread, use the *Subscribe* button on the right side of the
page to receive notifications of further conversations or a resolution. Comments
consisting only of "+1" or the like tend to clutter the thread and make it more
painful to follow the discussion.

If you _do_ have something to add to the conversation, or _don't_ find a
matching issue...

### File a new issue or update an existing one

Try to be as specific as possible about your environment and the problem you're
observing. At a minimum, include:

- The version of bash you're using, from either `bash --version` or `echo
  $BASH_VERSION`
- The version of the go-script-bash library you're using
- Command line steps or code snippets that reproduce the issue

Also consider using:

- bash's `time` builtin to collect running times
- a regression test to add to the suite
- memory usage as reported by a tool such as
  [memusg](https://gist.github.com/netj/526585)

## Updating documentation

## Environment setup

Make sure you have Bash installed per the [Environment setup in the
README](README.md#environment-setup).

You will also need [Git](https://git-scm.com/downloads) installed on your
system. If you are not familiar with Git, you may wish to reference the [Git
documentation](https://git-scm.com/doc).

## Workflow

The basic workflow for submitting changes resembles that of the [GitHub Git
Flow](https://guides.github.com/introduction/flow/), except that you will be
working with your own fork of the repository and issuing pull requests to the
original.

1. Fork the repo on GitHub (look for the "Fork" button)
2. Clone your forked repo to your local machine
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Develop _and [test](#testing)_ your changes as necessary.
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new [GitHub pull
   request](https://help.github.com/articles/using-pull-requests/) for your
   feature branch based against the original repository's `master` branch
7. If your request is accepted, you can [delete your feature
   branch](https://help.github.com/articles/deleting-unused-branches/) and
   pull the updated `master` branch from the original repository into your
   fork. You may even [delete your
   fork](https://help.github.com/articles/deleting-a-repository/) if you don't
   anticipate making further changes.

## Testing

No bug fixes or new features will be accepted without accompanying tests.

## Coding conventions

- [Formatting](#formatting)
- [Naming](#naming)
- [Variable and parameter declarations](#variable-and-parameter-declarations)
- [Command substitution](#command-substitution)
- [Conditions and loops](#conditionals-and-loops)
- [Output](#output)
- [Gotchas](#gotchas)

### Formatting

- Keep all files 80 characters wide. (Yes, the maintainer is a dinosaur who
  likes viewing files side-by-side in a 161-column terminal window.)
- Indent using two spaces.
- Enclose all variables in double-quotes when used, to avoid having them
  interpreted as glob patterns (unless the variable contains a glob pattern).
  - Exception: Do not quote them within `[[` and `]]` condition tests.

The following are intended to prevent too-compact code:

- Declare only one variable per `declare` or `local` line.
  - _Note:_ This also helps avoid subtle bugs, as trying to initialize one
    variable using the value of another declared in the same statement will
    not do what you may expect. The initialization of the first variable will
    not yet be complete when the second variable is declared, so the first
    variable will have an empty value.
- Do not use one-line `if`, `for`, `while`, `until`, `case`, or `select`
  statements.
- Do not use `&&` or `||` to avoid writing `if` statements.
- Do not write functions entirely on one line.
- For `case` statements: put each pattern on a line by itself; put each command
  on a line by itself; put the `;;` terminator on a line by itself.

_Confession:_ I have used one-liners like crazy in the past. Looking back at my
own code, I've found them difficult to understand. Spreading out declarations,
statements, and functions makes the code easier to follow, as the behavior is
more explicit. It also makes it more `grep`-pable, as "one thing per line" makes
it easier to find, count, and possibly transform things.

### Naming

- Use `snake_case` for all identifiers.
- Constants and globals should be in `ALL_CAPS`, prefixed with `_GO_`.
  - Exception: a global variable used for initialization that isn't used
    anywhere else or intended for export should be prefixed with `__go_`, as
    seen at the top of `libexec/builtins`:
    ```bash
    declare __go_builtin_cmds=()
    function __go_glob_builtin_scripts {
      local c
      for c in "$_GO_CORE_DIR/libexec/"*; do
        if [[ -f $c && -x $c ]]; then
          __go_builtin_cmds+=("${c##*/}")
        fi
      done
    }
    __go_glob_builtin_scripts

    declare -r _GO_BUILTIN_CMDS=("${__go_builtin_cmds[@]}")
    ```
- Prefix API functions with `@go.`.
- Prefix internal functions with `_@go.`.
- Prefix variables used to return values to the caller with `__go_`.

### Files

- If the file is a pure library with no executable behavior of its own, put it
  in `lib/`.
- If the file is executable, put it in `libexec/`.
- All logic that is not a constant or global declaration or initializer should
  be contained within a function declaration.
- `libexec/` files should execute a function that represents its main logic and
  which uses `return 1` (or some other value) to indicate an error, e.g. from
  `libexec/help`:
  ```bash
  _@go.help() {
    if [[ $# -eq 0 ]]; then
      _@go.usage
    else
      _@go.help_message_for_command "$@"
    fi
  }

  _@go.help "$@"
  ```
  - This makes it easier for other scripts to source the executable script and
    take action on error.

### Function declarations

- Declare functions without the `function` keyword.
- Strive to always use `return`, never `exit`, unless an error condition is
  severe enough to warrant it.
  - Calling `exit` makes it difficult for the caller to recover from an error,
    or to compose new commands from existing ones.

### Variable and parameter declarations

- Declare all constants near the top of the file using `declare -r`.
- Avoid globals; but if you must, declare all globals near the top of the file,
  outside of any function, using `declare`.
- Declare all variables inside functions using `local`.
  - Exception: If an internal function needs to return more than one distinct
    result value, or an array of values, it should use _undeclared_ variables
    prefixed with `__go_`, and all callers should declare these variables as
- Don't use `local -r`, as a readonly local variable in one scope can cause a
  conflict when it calls a function that declares a `local` variable of the same
  name.
- Don't use type flags with `declare` or `local`. Assignments to integer
  variables in particular may behave differently, and it has no effect on array
  variables.
- For most functions, the first lines should use `local` declarations to
  assign the original positional parameters to more meaningful names, e.g.:
  ```bash
  _@go.format_summary() {
    local cmd_name="$1"
    local summary="$2"
    local longest_name_len="$3"
  ```
  For very short functions, this _may not_ be necessary, e.g.:
  ```bash
  _@go.has_spaces() {
    [[ $1 != ${1//[[:space:]]/} ]]
  }
  ```

### Command substitution

- Use `$()` instead of backticks.

### Process substitution

- Avoid it, since it is not available on Windows platforms (yet).

### Conditionals and loops

- Always use `[[` and `]]` for evaluating variables. Do not quote variables
  within the brackets.

### Output

- Use `@go.printf` for most console output to ensure that the text fits the
  terminal width.

### Gotchas

- If you wish to use command substitution to initialize a `local` variable, and
  then check the exit status of the command substitution, you _must_ declare the
  variable on one line and perform the substitution on another. If you don't,
  the exit status will always indicate success, as it is the status of the
  `local` declaration, not the command substitution:
  ```bash
  local defined
  defined=($(declare -F "${_COMMANDS[@]}")) && [[ $? -eq 0 ]] && return
  ```

## Public domain

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.

For more information, see the [LICENSE](LICENSE.md) file.