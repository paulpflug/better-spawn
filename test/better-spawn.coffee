{test} = require "snapy"

spawn = require "../src/better-spawn.coffee"

waitingProcess = (time=10000) =>
  return "node -e 'console.log(\"waiting..\");setTimeout(function(){},#{time});'"
failingProcess = "node -e 'console.log(\"throwing error..\");throw new Error();'"

filter = ["resolved.exitCode","resolved.isClosed","resolved.isKilled"]

test (snap) =>
  child = spawn waitingProcess(10), noOut:true
  # process should be successful
  snap promise: child.closed, filter: filter

test (snap) =>
  child = spawn failingProcess, noErr:true
  # process should fail
  snap promise: child.closed, filter: filter

test (snap) =>
  child = spawn waitingProcess(10000), noOut:true
  # should be running
  snap obj: child.isClosed
  # process should be killed
  snap promise: child.closed, filter: filter
  child.close()
