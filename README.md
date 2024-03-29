# Oh My Zsh XDG Base Directory Environment Variables Plugin

This repository contains an [ohmyzsh] plugin to set these environment variables for your macOS
zsh shell:

```sh
export XDG_CACHE_HOME=$(dirname "$TMPDIR")/C/.cache
export XDG_CONFIG_DIRS=:
export XDG_CONFIG_HOME=$HOME/Library/Application\ Support/.config
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_DATA_HOME=$HOME/Library/Application\ Support/.local/share
export XDG_RUNTIME_DIR=$(dirname "$TMPDIR")/T/.local/runtime
export XDG_STATE_HOME=$HOME/Library/Application\ Support/.local/state
```

## Installation

* Copy `xdg.plugin.zsh` to `$ZSH_CUSTOM/plugins/xdg/xdg.plugin.zsh`

* Add `xdg` to your `plugins` array in `~/.zshrc`

* Run `tmutil localsnapshot` in case things go so badly you're willing to rewind your entire
  machine to this point

* Run `migrare.zsh` to **WARNING DESTROY YOUR CACHE WARNING** and move your `.config` and `.local`

The migration script destroys your caches because we can't quite predict where to put them.
We can link `.cache` to `~/Library/Caches`, and do. Anything you catch writing to there will have
used the symlink. Anything you catch writing XDG_CACHE_HOME used the environment variable. That's
in the future, though. Right now we don't know which is which. If you come up with a good
alternative, please do let me know.

I've left, as an exercise for the reader, chasing the rest of the utilities' files out of your
home directory. For many, you can set environment variables.

## Background

The plugin is shorter than the explanation below, and supports a combination of two attitude
problems:⁰

* We [SHOULD]² set and use the XDG Base Directory Environment Variables to control where the
  command line utilities we use put their data because otherwise many default to their historical
  dot-file habits leaving us with&hellip; \[`ls -lad ~/.??* | wc -l`] 90-odd dot-files despite our
  best efforts to date.

* We SHOULD use macOS' native locations for cache and runtime data so they're not indexed for
  search or backed up, and so they're cleaned out when necessary.

I chose the paths above to minimise surprise whether you're coming at this from Linux or macOS.

The [XDG Base Directory Specification][basedir-spec] defines:

> [XDG_CACHE_HOME] defines the base directory relative to which user-specific non-essential data
> files should be stored. If XDG_CACHE_HOME is either not set or empty, a default equal to
> `$HOME/.cache` should³ be used.
>
> [XDG_CONFIG_HOME] defines the base directory relative to which user-specific configuration files
> should be stored. If XDG_CONFIG_HOME is either not set or empty, a default equal to
> `$HOME/.config` should be used.
>
> [XDG_DATA_HOME] defines the base directory relative to which user-specific data files should be
> stored. If XDG_DATA_HOME is either not set or empty, a default equal to `$HOME/.local/share`
> should be used.
>
> [XDG_STATE_HOME] defines the base directory relative to which user-specific state files should
> be stored. If XDG_STATE_HOME is either not set or empty, a default equal to `$HOME/.local/state`
> should be used.
>
> [XDG_RUNTIME_DIR] defines the base directory relative to which user-specific non-essential
> runtime files and other file objects (such as sockets, named pipes, ...) should be stored.
> The directory [MUST] be owned by the user, and she MUST be the only one having read and write
> access to it. Its Unix access mode MUST be 0700.

macOS provides similar directories for temporary and cached data. `man 3 confstr` describes:

> _CS_DARWIN_USER_TEMP_DIR provides the path to a user's temporary items directory. The directory
> will be created it if does not already exist. This directory is created with access permissions
> of 0700 and restricted by the `umask`(2) of the calling process and is a good location for
> temporary files.
>
> By default, files in this location may be cleaned (removed) by the system if they are not
> accessed in 3 days.
>
> _CS_DARWIN_USER_CACHE_DIR provides the path to the user's cache directory. The directory will be
> created if it does not already exist. This directory is created with access permissions of 0700
> and restricted by the `umask`(2) of the calling process and is a good location for user cache
> data as it will not be automatically cleaned by the system. Files in this location will be
removed during safe boot.

macOS sets TMPDIR to the DARWIN_USER_TEMP_DIR, and we can find both with `getconf`(1):

```plaintext
$ declare -p TMPDIR
export TMPDIR=/var/folders/27/06dcfxnwg2k94n8s3z0060gdkh50rw/T/

$ ls -lad ${TMPDIR?}
drwx------@ 252 garth  staff  8064 Mar 29 11:22 /var/folders/27/06dcfxnwg2k94n8s3z0060gdkh50rw/T/

$ getconf DARWIN_USER_TEMP_DIR
/var/folders/27/06dcfxnwg2k94n8s3z0060gdkh50rw/T/

$ getconf DARWIN_USER_CACHE_DIR
/var/folders/27/06dcfxnwg2k94n8s3z0060gdkh50rw/C/
```

Given its mode I'm treating the DARWIN_USER_TEMP_DIR as close enough for XDG_RUNTIME_DIR.
Do get in touch if your attitude problem is stronger than mine and you find a simple way to
configure expiration of a subdirectory at logout.

I'm using `$HOME/Library/Application Support` for the config, data, and state homes because that's
where Apple's [File System Programming Guide] leads us.

Within those directories I'm using the XDG `.cache`, `.config`, and `.local` paths so it's
possible to distinguish between apps that chose Application Support and those that followed
XDG_CONFIG_HOME there.

## Alternatives

You'll get a lot of the benefit without the plugin if you run `migrate.zsh`.

But, maybe even that demonstrates more care than is cool with your scene. Do nothing. It's safe.

## Footnotes

00. I use "attitude problem" here to describe taking more care than the observer might value. You
    might think it more emotive than necessary. With respect, I disagree. If you don't catch on to
    the norm enforcement¹ when it starts with a seeingly idle comment&emdash;"wow, you care a lot
    about X"&emdash;beware it might escalate until you get the point. As Yossi Kreinin unpacked in
    great detail in 2015, [any work management don't value is left to the insane][yk15]. Hazel
    Weakly [later][hw24] nailed it in a single sentence:

    > New definition of tech debt: work that is considered so unvalued by the company that
    > you can get fired for doing it

    Here's the soft end at work in [ohmyzsh/ohmyzsh#9543] regarding its lack of support for
    XDG_oh_whatever_piss_off:

    > I will not call this a bug

00. &hellip; or, as accident investigators call it when it goes too far, [normalised deviance].

00. The key words [MUST], [MUST NOT], [REQUIRED][MUST], [SHALL][MUST], [SHALL NOT][MUST NOT],
    [SHOULD], [SHOULD NOT], [RECOMMENDED][SHOULD], [MAY], and [OPTIONAL][MAY] in this document
    are to be interpreted as described in [RFC 2119], but I'm not such a stickler I won't remove
    the double quotes from the mandatory paragraph because I think they look messy.

00. XDG are happy to shout MUST but aren't as consistent with SHOULD.

[MAY]: https://tools.ietf.org/html/rfc2119#section-5
[MUST NOT]: https://tools.ietf.org/html/rfc2119#section-2
[MUST]: https://tools.ietf.org/html/rfc2119#section-1
[RFC 2119]: https://tools.ietf.org/html/rfc2119
[SHOULD NOT]: https://tools.ietf.org/html/rfc2119#section-4
[SHOULD]: https://tools.ietf.org/html/rfc2119#section-3
[XDG_CACHE_HOME]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#:~:text=%24XDG_CACHE_HOME%20defines,used.
[XDG_CONFIG_HOME]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#:~:text=%24XDG_CONFIG_HOME%20defines,used.
[XDG_DATA_HOME]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#:~:text=%24XDG_DATA_HOME%20defines,used.
[XDG_STATE_HOME]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#:~:text=%24XDG_STATE_HOME%20defines,used.
[XDG_RUNTIME_DIR]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html#:~:text=%24XDG_RUNTIME_DIR%20defines,0700.
[basedir-spec]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
[hw24]: https://hachyderm.io/@hazelweakly/111819889174981570
[normalised deviance]: https://en.wikipedia.org/wiki/Normalization_of_deviance
[ohmyzsh/ohmyzsh#9543]: https://github.com/ohmyzsh/ohmyzsh/issues/9543
[ohmyzsh]: https://github.com/ohmyzsh/ohmyzsh
[yk15]: https://yosefk.com/blog/people-can-read-their-managers-mind.html#:~:text=Who%20can,these%20things%2e
