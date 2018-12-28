# Bash Shorten Directory

[![CircleCI](https://circleci.com/gh/daxelrod/bash-shorten-directory.svg?style=svg)](https://circleci.com/gh/daxelrod/bash-shorten-directory)

A pure-bash function that can be used as part of `PS1` to intelligently shorten
the working directory.

Path components are shortened starting from the beginning of the path until the
path is shorter than a certain length.

```
/v/w/http/projects
```

## Features

* Pure Bash for efficiency. Never needs to exec.
* Only shortens as much of the path as necessary to fit.
* Ignores zero-width characters when computing length, using the same rules as readline. Ignores characters enclosed between `\[` and `\]`.
* Customizable. Change the total length, length of individual components, or completely change how shortened components are formatted.
* Abbreviates the home directory with tilde, like `\W`.
* Complete test suite, and linted via Shellcheck.


## Quick Start

1. `git clone https://github.com/daxelrod/bash-shorten-directory.git ~/bash-shorten-directory`
2. In your `.bash_profile` or `.profile`, before setting `PS1`, source `$HOME/bash-shorten-directory/share/shorten-directory.bash`.
3. When setting `PS1`, replace `\w` or `\W` with `$(__shorten_directory)`.

For example, replace
```bash
# localhost:~/.ssh jdoe $
PS1='\h:\w \u\$ '
```

with
```bash
source $HOME/bash-shorten-directory/share/shorten-directory.bash
# localhost:~/.ssh jdoe $
PS1='\h:$(__shorten_directory) \u\$ '
```

Note that if you're using the [Git Prompt's `__git_ps1`](https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh) in `PROMPT_COMMAND` mode, you'll want to make sure that the string `$(__shorten_directory)` gets passed to `__git_ps1` verbatim so that it is evaluated every time the prompt is generated, rather than once at the beginning:
```bash
PROMPT_COMMAND=__git_ps1 '\h:$(__shorten_directory)' '\u\$ '
```

## Complete Reference

It is possible to customize a number of aspects of the shortening.

The `__shorten_directory` function takes the following arguments, all of which are optional:

1. **Total length**: The maximum desired length of the shortened string.
    * *Default*: The width of the terminal divided by 4 (as reported by `$COLUMNS`. You may want to add `shopt -s checkwinsize` to your profile so that Bash updates $COLUMNS any time a process ends.)
    * *Details*: `__shorten_directory` will shorten each path component starting at the beginning until the path is shorter than the **Total length**. However, it will never shorten the basename (last component), even if this would make the path longer than the specified length. It is also possible that even with shortening, the shortened result is longer than the specified length. You may need to add `shopt -s checkwinsize` in order for Bash to update `$COLUMNS`
    * *Examples*:
        ```bash
        $ cd /var/www/http/projects
        $ __shorten_directory 100
        /var/www/http/projects
        $ __shorten_directory 20
        /v/www/http/projects
        $ __shorten_directory 1
        /v/w/h/projects
        ```
1. **Long path**: The path to shorten.
    * *Default*: The current working directory (as reported by `$PWD`)
1. **Component length**: When shortening a path component, how long should it be?
    * *Default*: 1
    * *Details*: This length applies to the component only, and not separators around it.
    * *Examples*:
        ```bash
        $ __shorten_directory 15 /var/www/http/projects 2
        /va/ww/ht/projects
        ```
1. **Shortened component format**: A `printf` format string to apply to each part when shortening it.
    * *Default*: `%.*s/`
    * *Details*: `printf` will be passed this format string and two additional arugments: the **component length** and a single long path component itself with no separators. The format should output a trailing separator. If you wish to ignore the **component length**, include a `%.0s` at the beginning of the format string; this will consume the length without printing anything. Recall that you may need to apply additional escaping beyond what Bash would normally require in `PS1` in order to satisfy `printf`'s requirements.
    * *Examples*:
        ```bash
        $ __shorten_directory 21 "$PWD" 1 '…%.*s>'
        …>…v>…w>http/projects
        ```

## Dependencies

* Runtime
  * Bash >=3.2 (works with macOS's ancient Bash)
* Development
  * [bats-core](https://github.com/bats-core/bats-core) >=1.0 for running tests
  * [ShellCheck](https://www.shellcheck.net/) >=0.6.0 for linting

## Prior Art
* [bash-dir-collapse](https://github.com/jkern888/bash-dir-collapse): A less customizable, but much simpler version of the same thing. Adds neat colors and underlining to shortened components. (These should be possible with bash-shorten-directory with the right printf format string supplied as the fourth argument.)
* [nicerobot's answer to "Abbreviated current directory in shell prompt?"](https://unix.stackexchange.com/questions/26844/abbreviated-current-directory-in-shell-prompt): Always collapses all path components.
* [many answers to "Bash prompt: how to have the initials of directory path"](https://superuser.com/questions/180257/bash-prompt-how-to-have-the-initials-of-directory-path): Lots of great answers.

## License
[MIT](LICENSE)
