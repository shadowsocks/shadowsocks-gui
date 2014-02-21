# Copyright (c) 2013 clowwindy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

$ ->
  gui = require 'nw.gui'
  # hack util.log
  
  divWarning = $('#divWarning')
  divWarningShown = false
  serverHistory = ->
    (localStorage['server_history'] || '').split('|')
   
  util = require 'util'
  util.log = (s) ->
    console.log new Date().toLocaleString() + " - #{s}"
    if not divWarningShown
      divWarning.show()
      divWarningShown = true
    divWarning.text(s)
  
  args = require './args'
  local = require 'shadowsocks'
  update = require './update'
  
  update.checkUpdate (url, version) ->
    divNewVersion = $('#divNewVersion')
    span = $("<span style='cursor:pointer'>New version #{version} found, click here to download</span>")
    span.click ->
      gui.Shell.openExternal url
    divNewVersion.find('.msg').append span 
    divNewVersion.fadeIn()
   
  addServer = (serverIP) ->
    servers = (localStorage['server_history'] || '').split('|')
    servers.push serverIP
    newServers = []
    for server in servers
      if server and server not in newServers
        newServers.push server
    localStorage['server_history'] = newServers.join '|'
  
  $('#inputServerIP').typeahead
    source: serverHistory
  
  chooseServer = ->
    index = +$(this).attr('data-key')
    args.saveIndex(index)
    load false
    reloadServerList()
  
  reloadServerList = ->
    currentIndex = args.loadIndex()
    configs = args.allConfigs()
    divider = $('#serverIPMenu .insert-point')
    serverMenu = $('#serverIPMenu .divider')
    $('#serverIPMenu li.server').remove()
    i = 0
    for configName of configs
      if i == currentIndex
        menuItem = $("<li class='server'><a tabindex='-1' data-key='#{i}' href='#'><i class='icon-ok'></i> #{configs[configName]}</a> </li>")
      else
        menuItem = $("<li class='server'><a tabindex='-1' data-key='#{i}' href='#'><i class='icon-not-ok'></i> #{configs[configName]}</a> </li>")
      menuItem.find('a').click chooseServer
      menuItem.insertBefore(divider, serverMenu)
      i++
  
  addConfig = ->
    args.saveIndex(NaN)
    reloadServerList()
    load false
  
  deleteConfig = ->
    args.deleteConfig(args.loadIndex())
    args.saveIndex(NaN)
    reloadServerList()
    load false
    
  publicConfig = ->
    args.saveIndex(-1)
    reloadServerList()
    load false
  
  save = ->
    config = {}
    $('input,select').each ->
      key = $(this).attr 'data-key'
      val = $(this).val()
      config[key] = val
    index = args.saveConfig(args.loadIndex(), config)
    args.saveIndex(index)
    reloadServerList()
    util.log 'config saved'
    restartServer config
    false
  
  load = (restart)->
    config = args.loadConfig(args.loadIndex())
    $('input,select').each ->
      key = $(this).attr 'data-key'
      val = config[key] or ''
      $(this).val(val)
      config[key] = this.value
    if restart
      restartServer config
    
  isRestarting = false
  
  restartServer = (config) ->
    if config.server and +config.server_port and config.password and +config.local_port and config.method and +config.timeout
      if isRestarting
        util.log "Already restarting"
        return
      isRestarting = true
      start = ->
        try
          isRestarting = false
          util.log 'Starting shadowsocks...'
          window.local = local.createServer config.server, config.server_port, config.local_port, config.password, config.method, 1000 * (config.timeout or 600)
          addServer config.server
          $('#divError').fadeOut()
          gui.Window.get().hide()
        catch e
          util.log e
      if window.local?
        try
          util.log 'Restarting shadowsocks'
          if window.local.address()
            window.local.close()
          setTimeout start, 1000
        catch e
          isRestarting = false
          util.log e
      else
        start()
    else
      $('#divError').fadeIn()
  
  $('#buttonSave').on 'click', save
  $('#buttonNewProfile').on 'click', addConfig
  $('#buttonDeleteProfile').on 'click', deleteConfig
  $('#buttonPublicServer').on 'click', publicConfig
  $('#buttonConsole').on 'click', ->
    gui.Window.get().showDevTools()
  $('#buttonAbout').on 'click', ->
    gui.Shell.openExternal 'https://github.com/shadowsocks/shadowsocks-gui'
  
  tray = new gui.Tray icon: 'menu_icon@2x.png'
  menu = new gui.Menu()
  
  tray.on 'click', ->
    gui.Window.get().show()
  
  show = new gui.MenuItem
    type: 'normal'
    label: 'Show'
    click: ->
      gui.Window.get().show()
  
  quit = new gui.MenuItem
    type: 'normal'
    label: 'Quit'
    click: ->
      gui.Window.get().close()
  
  show.add
  menu.append show
  menu.append quit
  tray.menu = menu
  window.tray = tray
  gui.Window.get().on 'minimize', ->
    gui.Window.get().hide()
  
  reloadServerList()
  load true
