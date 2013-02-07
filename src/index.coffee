sysPath = require 'path'
_ = require 'underscore'
Q = require 'q'
fs = require 'fs'
bowerList = require 'bower/lib/commands/list'

helper =
  monkeyPatchPaths: (bowerListResult) ->
    fixPath = (path) -> 
      path.split('/').join sysPath.sep

    result = {}

    _.each bowerListResult, (v, k) ->
      if _.isArray v
        resultv = []
        _.each v, (vv, i) ->
          resultv[i] = fixPath vv
        result[k] = resultv
      else result[k] = fixPath v
    return result

module.exports = class BowerCSSIncluder
  brunchPlugin: yes
  type: 'stylesheet'
  extension: 'css'

  constructor: (config) ->
    pathsDefered = Q.defer()
    mergedPathDefered = Q.defer()
    @public = config.paths?.public
    include = config.plugins?.bower?.extend

    pathsDefered.promise.then (paths) ->
      include = helper.monkeyPatchPaths include
      merged = _.extend {}, paths, include
      resolveResult = []

      _.each merged, (v, k) ->
        if _.isArray v
          _.each v, (vv, i) ->
            resolveResult.push vv
        else resolveResult.push v

      mergedPathDefered.resolve resolveResult

    @pathsPromise = mergedPathDefered.promise
    bowerList({paths: true}).on 'data', (paths) ->
      pathsDefered.resolve paths

  compile: (data, path, callback) ->
    @pathsPromise.then (paths) ->
      if path.indexOf('app') is 0
        callback null, data      

      # скобки нужны
      if paths.indexOf(path) >= 0
        callback null, data
      else callback null, ""

  onCompile: (compiled) ->
    #console.log compiled