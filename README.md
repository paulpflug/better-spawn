## Better spawn

Because `child_process.exec` lacks features and `child_process.spawn` acts weird, `better-spawn` was made.

It is a very simple wrapper around `child_process.spawn` to make opening and closing work consistently in linux and windows.  
Used by [script-runner](https://github.com/paulpflug/script-runner)

### Install

```bash
npm install better-spawn
```

### Breaking changes @1
`child.closed` and `child.killed` are now promises.
The boolean states are now available at `child.isClosed` and `child.isKilled`.

### Usage

```js
spawn = require('better-spawn')
child = spawn('node', options)
```

### Options

Name | type | default | description
---:| --- | ---| ---
cwd | String | process.cwd | current working directory
env | Object | process.env | environment variables
env.PATH  | String | process.env.PATH + ./node_modules/.bin | used to resolve commands
stdio | [See documentation](https://nodejs.org/api/child_process.html#child_process_options_stdio) | `["pipe","inherit","inherit"]` | to control output
noOut | Boolean | `null` | sets `stdio[1] = "pipe"`
noErr | Boolean | `null` | sets `stdio[2] = "pipe"`
windowsVerbatimArguments | Boolean | isWindows | to support windows
detach | Boolean | !isWindows | to support killing on unix
Promise | Function | global.Promise | supply your own Promise lib

#### Props
Name | type | description
---:| --- | ---
cmd | String | cmd called
isKilled | Boolean | is child process killed
isClosed | Boolean | is child process closed
killed | Promise | fulfilled when child process killed
closed | Promise | fulfilled when child process closed
close | Function | call to kill child process
### Examples

```js
// pipe to shell without losing color
child = spawn('node')
// suppress normal output, but maintain err output
child = spawn('node',{noOut:true})
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
