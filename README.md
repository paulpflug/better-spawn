## Better spawn

Because `child_process.exec` lacks features and `child_process.spawn` acts weird, `better-spawn` was made.

It is a very simple wrapper around `child_process.spawn` to make opening and closing work consistently in linux and windows.  
Used by [script-runner](https://github.com/paulpflug/script-runner)

### Install

```bash
npm install better-spawn
```

### Usage

```js
spawn = require('better-spawn')

// options same as for child_process.spawn
// cwd defaults to process.cwd
// env defaults to process.env
// env.PATH defaults to process.env.PATH + ./node_modules/.bin
// windowsVerbatimArguments will be overwritten (to work on windows)
// detach will also be overwritten (to make close work)

// node will be run within sh or cmd
child = spawn('node', options)

child.cmd // will be 'node'

child.close(signal) // to close reliable, signal defaults to "SIGTERM"

child.killed // will be true if killed
child.closed // will be true if closed
```

### Examples

```js
// pipe to shell without losing color
child = spawn('node',{stdio:'inherit'})
// set empty env (default in node)
child = spawn('node',{env: {PATH:""}})
```

### Compare to other solutions

- `child_process.exec`, spawns in shell but output has to be piped - color information will be lost.
- `child_process.spawn`, doesn't spawn in shell, so it has to be done by hand (differs in linux and windows)
Main problem is, `sh` won't kill its children by `child.kill()`, see: [node#2098](https://github.com/nodejs/node/issues/2098)
- `cross-spawn-async` a wrapper for `child_process.spawn` to support windows quirks like `PATHEXT` or `shebangs` not working
- `execa` a wrapper for `cross-spawn-async` which adds the shell logic, to behave like `child_process.exec`, adds promises, modifies `PATH`

`better-spawn` doesn't support `PATHEXT` or `shebangs on windows`
## License
Copyright (c) 2016 Paul Pflugradt
Licensed under the MIT license.
