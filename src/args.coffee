
allConfigs = ->
  if localStorage['configs']
    result = []
    try
      configs = JSON.parse(localStorage['configs'])
      for c of configs
        result.push "#{c.server}:#{c.port}"
      return result
    catch e
  []
  
saveConfigs = (configs) ->
  localStorage['configs'] = JSON.stringify(configs)

saveConfig = (index, config)->
  configs = JSON.parse(localStorage['configs'])
  if not configs
    configs = []
  if index == -1
    configs.push config
  else
    configs[index] = config
  saveConfigs configs

loadConfig = (index) ->
  configs = JSON.parse(localStorage['configs'])
  return config[index]
      
deleteConfig = (index) ->
  configs = JSON.parse(localStorage['configs'])
  configs.splice index, 1
  saveConfigs configs

exports.allConfigs = allConfigs
exports.saveConfig = saveConfig
exports.loadConfig = loadConfig
exports.deleteConfig = deleteConfig
