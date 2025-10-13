# cider-extensions

A collection of additional features for the cider mode in emacs.

Currently only provides the `cider-extensions-autocompletions`
command, that provides autocompletions based on the repl runtime
state.

## Installation

Install `helm`.

Copy the repository to your `~/.emacs.d/cider-extensions`. Insert these to your `init.el`:

```
(load "~/.emacs.d/cider-extensions/init.el")
(define-key cider-mode-map (kbd "C-o j") 'cider-extensions-autocompletions)
```

# cider-extensions-autocompletions

Put your cursor in one of these positions

```
(<cursor> a-map)
(-> a-map <cursor>)
(select-keys [<cursor>])
```

Run the `cider-extensions-autocompletions` command and you will see a
helm menu for the possible autocompletions.

Click this image to see a demo in YouTube:

[![Demo](https://img.youtube.com/vi/OQvpqp8W5gk/hqdefault.jpg)](https://www.youtube.com/embed/OQvpqp8W5gk)
