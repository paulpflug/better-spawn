{spawn} = require "child_process"
isWin = process.platform == "win32"
{resolve, delimiter} = require "path"

module.exports = (cmd, options) ->

  if isWin
    sh = "cmd"
    shFlag = "/c"
    cmd = cmd.replace(/"/g,"\"")
  else
    sh = "sh"
    shFlag = "-c"

  options ?= {}
  options.cwd ?= process.cwd()
  Promise = options.Promise or global.Promise

  unless options.env?
    options.env = JSON.parse JSON.stringify process.env
    tmp = options.env.PATH.split(delimiter)
    tmp.push resolve(options.cwd,"./node_modules/.bin")
    options.env.PATH = tmp.join(delimiter)

  unless options.stdio?
    stdio = ["pipe"]
    stdio.push if options.noOut then "pipe" else "inherit"
    stdio.push if options.noErr then "pipe" else "inherit"
    options.stdio = stdio

  options.windowsVerbatimArguments = isWin
  options.detached = !isWin
  
  child = spawn sh,[shFlag,cmd], options

  child.cmd = cmd
  child.isClosed = false
  child.isKilled = false

  child.closed = new Promise (res) ->
    child.on "close", -> 
      child.isClosed = true
      res(child)

  child.killed = new Promise (res) ->
    child.on "exit", (exitCode, signal) ->
      if signal?
        child.isKilled = true
        res(child)

  child.close = (signal) ->
    signal ?= "SIGTERM"
    unless child.isClosed or child.isKilled
      child.isKilled = true
      child.exitCode = 1
      if isWin
        child.kill signal
      else
        process.kill -child.pid, signal
        #spawn sh, [shFlag, "kill -INT -"+child.pid]

  return child
