## Better spawn

Because `child_process.exec` lacks features and `child_process.spawn` acts weird `better-spawn` was made.

It is a very simple wrapper around `child_process.spawn` to make it work consistently in linux and windows.

### Install

```bash
npm install better-spawn
```

### Usage

```coffee
spawn = require "better-spawn"

# options same as for child_process.spawn
# cwd defaults to process.cwd
# env defaults to process.env
# windowsVerbatimArguments will be overwritten (to work on windows)
# detach will also be overwritten (to make close work)

# node will be run within sh or cmd
child = spawn "node", options

child.cmd # will be "node"

child.close() # to close reliable

child.killed # will be true if killed
child.closed # will be true if closed
```


## License
Copyright (c) 2016 Paul Pflugradt
Licensed under the MIT license.
