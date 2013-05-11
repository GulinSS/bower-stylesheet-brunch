bower-stylesheet-brunch
=======================

Adds Bower support to Brunch for stylesheet files.

Using
-----

In your brunch config, use this ignore :
`ignored: /^(vendor.*\.less|.+node_modules.+|.+_.+\..+)$/`

You also need to remove `"css-brunch": "1.5"` or something from package.json.
