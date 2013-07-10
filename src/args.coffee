
loadProfiles = ->
  if localStorage['config']
    try
      configs = JSON.parse(localStorage['config'])
    catch e
  else
    {}

saveProfiles = (profiles)->
  localStorage['config'] = JSON.stringify(profiles)

loadConfig = (profile) ->
  if localStorage['config']
    try
      configs = JSON.parse(localStorage['config'])
    catch e
      
deleteConfig = (profile) ->
  profiles = loadProfiles()
  if profiles[profile]
    delete profiles[profile]
  saveProfiles(profiles)
  