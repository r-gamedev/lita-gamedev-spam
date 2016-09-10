# lita-gamedev-spam

The IRC spamming component to the /r/gamedev monitoring system.

## Installation

Add lita-gamedev-spam to your Lita instance's Gemfile:

``` ruby
gem "lita-gamedev-spam", git: "https://github.com/r-gamedev/lita-gamedev-spam"
```

## Configuration

None.

## Usage

```irc
lita: list watch
lita: list follow
lita: watch submission.#
lita: unwatch submission.#
lita: follow submission.#
lita: unfollow submission.#
lita: follow submission.gamedev
lita: follow comment.gamedev.*
lita: unfollow submission.#
```
