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
  options.cwd ?= process.cwd()
  unless options.env?
    options.env = JSON.parse JSON.stringify process.env
    options.env.PATH += options.cwd+"/node_modules/.bin"
    if isWin
      options.env.PATH += ";"
    else
      options.env.PATH += ":"
  options.windowsVerbatimArguments = isWin
  options.detached = !isWin
  child = spawn sh,[shFlag,cmd], options
  child.cmd = cmd
  child.closed = false
  child.killed = false
  child.on "close", -> child.closed = true
  child.on "exit", (exitCode, signal) ->
    child.killed = true if signal?
  child.close = (signal="SIGTERM") ->
    unless child.closed or child.killed
      child.killed = true
      if isWin
        child.kill signal
      else
        process.kill -child.pid, signal
        #spawn sh, [shFlag, "kill -INT -"+child.pid]
  return child
