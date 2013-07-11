
localStorage = window.localStorage

# This is a public server
publicConfig =
  server: '209.141.36.62'
  server_port: 8348
  local_port: 1080
  password: '$#HAL9000!'
  method: 'aes-256-cfb'
  timeout: 600
  
defaultConfig =
  server_port: 8388
  local_port: 1080
  method: 'aes-256-cfb'
  timeout: 600


loadConfigs = ->
  JSON.parse(localStorage['configs'] or '[]')

allConfigs = ->
  if localStorage['configs']
    result = []
    try
      configs = loadConfigs()
      for i of configs
        c = configs[i]
        result.push "#{c.server}:#{c.server_port}"
      return result
    catch e
  []
  
saveIndex = (index) ->
  localStorage['index'] = index

loadIndex = ->
  +localStorage['index']
 
saveConfigs = (configs) ->
  localStorage['configs'] = JSON.stringify(configs)

saveConfig = (index, config) ->
  if index == -1
    # if modified based on public server, add a profile, not to modify public server
    index = NaN
  configs = loadConfigs()
  if isNaN(index)
    configs.push config
    index = configs.length - 1
  else
    configs[index] = config
  saveConfigs configs
  index

loadConfig = (index) ->
  if isNaN(index)
    return defaultConfig
  if index == -1
    return publicConfig
  configs = loadConfigs()
  return configs[index] or defaultConfig
      
deleteConfig = (index) ->
  if not isNaN(index) and not index == -1
    configs = loadConfigs()
    configs.splice index, 1
    saveConfigs configs

exports.allConfigs = allConfigs
exports.saveConfig = saveConfig
exports.loadConfig = loadConfig
exports.deleteConfig = deleteConfig
exports.loadIndex = loadIndex
exports.saveIndex = saveIndex
exports.publicConfig = publicConfig
