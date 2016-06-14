(function() {
  var isWin, spawn;

  spawn = require("child_process").spawn;

  isWin = process.platform === "win32";

  module.exports = function(cmd, options) {
    var child, sh, shFlag;
    if (isWin) {
      sh = "cmd";
      shFlag = "/c";
      cmd = cmd.replace(/"/g, "\"");
    } else {
      sh = "sh";
      shFlag = "-c";
    }
    if (options == null) {
      options = {};
    }
    if (options.cwd == null) {
      options.cwd = process.cwd();
    }
    if (options.env == null) {
      options.env = JSON.parse(JSON.stringify(process.env));
      options.env.PATH += options.cwd + "/node_modules/.bin";
      if (isWin) {
        options.env.PATH += ";";
      } else {
        options.env.PATH += ":";
      }
    }
    options.windowsVerbatimArguments = isWin;
    options.detached = !isWin;
    child = spawn(sh, [shFlag, cmd], options);
    child.cmd = cmd;
    child.closed = false;
    child.killed = false;
    child.on("close", function() {
      return child.closed = true;
    });
    child.on("exit", function(exitCode, signal) {
      if (signal != null) {
        return child.killed = true;
      }
    });
    child.close = function(signal) {
      if (signal == null) {
        signal = "SIGTERM";
      }
      if (!(child.closed || child.killed)) {
        child.killed = true;
        if (isWin) {
          return child.kill(signal);
        } else {
          return process.kill(-child.pid, signal);
        }
      }
    };
    return child;
  };

}).call(this);
