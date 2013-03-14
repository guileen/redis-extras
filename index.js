var fs = require('fs')
  , path = require('path')
  , glob = require('glob')
  , RedisClient = require('redis').RedisClient
  , _slice = Array.prototype.slice
  , snippets = {}
  ;

function addScriptFolder(baseDir) {
  baseDir = path.normalize(baseDir);
  baseDir = baseDir + '/';
  var baseDirLen = baseDir.length
    , filenames = glob.sync(__dirname + '/scripts/**/*.lua')
    ;
  filenames.forEach(function(filename) {
      var code = fs.readFileSync(filename, 'utf-8')
        , scriptName = filename.substring(baseDirLen, filename.length - 4).toLowerCase()
        , ret = / *\-\- *keys *: *(\d+) *\n([\s\S]*)/ig.exec(code)
        , numKeys = ret ? Number(ret[1]) : 0
        ;

      if(!ret) {
        console.log('no keys defined for %s, set to 0 keys. Add below to the first line of you lua code set 4 keys:', scriptName.toUpperCase());
        console.log('-- keys : 4')
      }
      snippets[scriptName] = [numKeys, code];
  });
}

addScriptFolder(__dirname + '/scripts');

/**
 * @param string scriptName
 * @param keys
 * @param args
 * @param callbak
 */
RedisClient.prototype.extra = function(/* scriptName, keys..., args..., callback */) {
  var args = _slice.call(arguments);
  var scriptName = args.shift();
  scriptName = scriptName.toLowerCase();
  var snip = snippets[scriptName];
  args.unshift(snip[0]);
  args.unshift(snip[1]);
  this.eval.apply(this, args);
}

exports.addScriptFolder = addScriptFolder;
