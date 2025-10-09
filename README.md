# cider-extensions

A collection of additional features for the cider mode in emacs.

Currently only provides the `cider-extensions-thread-first-completions`
command, that provides dynamic autocompletion for the `->` macro.

## Installation

Install `helm`.

Copy the repository to your `~/.emacs.d/cider-extensions`. Insert these to your `init.el`:

```
(load "~/.emacs.d/cider-extensions/init.el")
(define-key cider-mode-map (kbd "C-o j") 'cider-extensions-thread-first-completions)
```

# cider-extensions-thread-first-completions

Put your cursor like this

```
(-> a-map <cursor>)
```

Run the `cider-extensions-thread-first-completions` command and if the
expression evaluates to a map, provides a helm menu for the keys of
the map. If the value is not a map, the value is printed to the cider
result buffer.
