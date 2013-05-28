{print} = require 'util'
{spawn} = require 'child_process'

build = () ->
  os = require 'os'
  if os.platform() == 'win32'
    coffeeCmd = 'coffee.cmd'
  else
    coffeeCmd = 'coffee'
  coffee = spawn coffeeCmd, ['-c', '-o', '.', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    if code != 0
      process.exit code

task 'build', 'Build ./ from src/', ->
  build()

