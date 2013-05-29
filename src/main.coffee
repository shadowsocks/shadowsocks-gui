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

gui = require 'nw.gui'
# hack util.log
util = require 'util'
divWarning = $('#divWarning')
util.log = (s) ->
  console.log new Date().toLocaleString() + " - #{s}"
  divWarning.show()
  divWarning.text(s)
  
util.log require('./shadowsocks-nodejs/args').version

local = require('./shadowsocks-nodejs/local')

saveChanges = ->
  config = {}
  $('input,select').each ->
    key = $(this).attr 'data-key'
    val = $(this).val()
    config[key] = val
    localStorage.setItem key, val
  util.log 'config saved'
  restartServer config
  false

load = ->
  config = {}
  $('input,select').each ->
    key = $(this).attr 'data-key'
    val = localStorage.getItem(key) or ''
    if val
      $(this).val(val)
    config[key] = this.value
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
        window.local = local.createServer config.server, config.server_port, config.local_port, config.password, config.method, 1000 * (config.timeout or 600)
        $('#divError').fadeOut()
      catch e
        util.log e
    if window.local?
      try
        window.local.close ->
          start()
      catch e
        util.log e
        start()
    else
      start()
  else
    $('#divError').fadeIn()

$('#buttonSave').on 'click', saveChanges
$('#buttonConsole').on 'click', ->
  gui.Window.get().showDevTools()

tray = new gui.Tray icon: 'menu_icon.png'
menu = new gui.Menu()

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

load()