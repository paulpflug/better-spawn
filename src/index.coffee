# out: ../index.js
{spawn} = require "child_process"
isWin = process.platform == "win32"

module.exports = (cmd, options) =>
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
  unless options.stdio?
    stdio = ["pipe"]
    stdio.push if options.noOut then "pipe" else "inherit"
    stdio.push if options.noErr then "pipe" else "inherit"
    options.stdio = stdio
  options.windowsVerbatimArguments = isWin
  options.detached = !isWin
  options.Promise ?= Promise
  child = spawn sh,[shFlag,cmd], options
  child.cmd = cmd
  child.isClosed = false
  child.isKilled = false
  if options.Promise
    child.closed = new options.Promise (resolve) =>
      child.on "close", => 
        child.isClosed = true
        resolve()
    child.killed = new options.Promise (resolve) =>
      child.on "exit", (exitCode, signal) =>
        if signal?
          child.isKilled = true
          resolve()
  else
    console.warn "better-spawn: no Promise lib supplied"
    child.on "close", => child.isClosed = true
    child.on "exit", (exitCode, signal) => child.isKilled = true if signal?
  child.close = (signal="SIGTERM") =>
    unless child.isClosed or child.isKilled
      child.isKilled = true
      if isWin
        child.kill signal
      else
        process.kill -child.pid, signal
        #spawn sh, [shFlag, "kill -INT -"+child.pid]
  return child
