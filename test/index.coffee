chai = require "chai"
should = chai.should()
spawn = require "../src/index.coffee"

waitingProcess = (time=10000) =>
  return "node -e 'console.log(\"waiting..\");setTimeout(function(){},#{time});'"
failingProcess = "node -e 'console.log(\"throwing error..\");throw new Error();'"

describe "better-spawn", =>
  it "should spawn a process", =>
    child = spawn waitingProcess(10), noOut:true
    child.closed.then =>
      child.exitCode.should.equal 0
      child.isClosed.should.equal true
      child.isKilled.should.equal false

  it "should spawn a failing process", =>
    child = spawn failingProcess, noErr:true
    child.closed.then =>
      child.exitCode.should.equal 1
      child.isClosed.should.equal true
      child.isKilled.should.equal false

  it "should close a process on close()",  =>
    child = spawn waitingProcess(10000)
    child.isClosed.should.equal false
    setTimeout child.close,50
    child.closed.then =>
      child.signalCode.should.equal "SIGTERM"
      child.isClosed.should.equal true
      child.isKilled.should.equal true
      return child.killed

  it "should work without Promise", =>
    child = spawn waitingProcess(10), noOut:true, Promise: false
    should.throw => child.closed.then =>
    