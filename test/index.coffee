chai = require "chai"
should = chai.should()
spawn = require "../index.js"

waitingProcess = (time=10000) ->
  return "node -e 'setTimeout(function(){},#{time});'"
failingProcess = "node -e 'throw new Error();'"

describe "better-spawn", ->
  it "should spawn a process", (done) ->
    child = spawn waitingProcess(10)
    child.on "close", ->
      child.exitCode.should.equal 0
      child.closed.should.equal true
      child.killed.should.equal false
      done()
  it "should spawn a failing process", (done) ->
    child = spawn failingProcess
    child.on "close", ->
      child.exitCode.should.equal 1
      child.closed.should.equal true
      child.killed.should.equal false
      done()
  it "should close a process on close()", (done) ->
    child = spawn waitingProcess(10000)
    child.closed.should.equal false
    setTimeout child.close,50
    child.on "close", ->
      child.signalCode.should.equal "SIGTERM"
      child.closed.should.equal true
      child.killed.should.equal true
      done()
