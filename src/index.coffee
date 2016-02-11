# out: ../index.js
{spawn} = require "child_process"
isWin = process.platform == "win32"

module.exports = (cmd, options) ->
  if isWin
    sh = "cmd"
    shFlag = "/c"
    cmd = cmd.replace(/"/g,"\"")
  else
    sh = "sh"
    shFlag = "-c"
  options ?= {}
  options.cwd ?= process.cwd
  options.env ?= process.env
  options.windowsVerbatimArguments = isWin
  options.detached = !isWin
  child = spawn sh,[shFlag,cmd], options
  child.cmd = cmd
  child.closed = false
  child.killed = false
  child.on "close", ->
    child.closed = true
  child.on "exit", (code, signal) ->
    child.killed = true if signal?
  child.close =  ->
    if isWin
      child.kill "SIGINT"
    else
      spawn sh, [shFlag, "kill -INT -"+child.pid]
  return child
