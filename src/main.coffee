# Copyright (c) 2012 clowwindy
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
util.log = (s) ->
  console.log new Date().toLocaleString() + " - #{s}"
  $('#divWarning').show()
  $('#divWarning').text(s)
local = require('./shadowsocks-nodejs/local')
  
saveChanges = ->
  config = {}
  $('input,select').each ->
    key = $(this).attr('data-key')
    val = $(this).val()
    config[key] = val
    window.localStorage.setItem(key, val)
  util.log 'config saved'
  restartServer(config)
  false

load = ->
  config = {}
  $('input,select').each ->
    key = $(this).attr('data-key')
    val = window.localStorage.getItem(key) or ''
    if val
      $(this).val(val)
    config[key] = this.value
  restartServer(config)

restartServer = (config)->
  if config.server and +config.server_port and config.password and +config.local_port and config.method and +config.timeout
    start = ->
      if not window.local?
        try
          window.local = local.createServer(config.server, config.server_port, config.local_port, config.password, config.method, 1000 * (config.timeout or 600))
        catch e
          alert e
      $('#divError').fadeOut()
    if window.local?
      try
        window.local.close(->
          window.local = null
          start()
        )
      catch e
        util.log e
        window.local = null
        start()
    else
      start()
  else
    $('#divError').fadeIn()

$('#buttonSave').on('click', saveChanges)
$('#buttonConsole').on('click', ->
  gui.Window.get().showDevTools()
)
load()

