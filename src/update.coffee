util = require 'util'

platformMap =
  'win32': 'win'
  'darwin': 'osx'
  'linux': 'linux'

compareVersion = (l, r) ->
  # compare two version numbers
  ls = l.split '.'
  rs = r.split '.'
  for i in [0..Math.min(ls.length, rs.length)]
    lp = ls[i]
    rp = rs[i]
    if lp != rp
      return lp - rp
  return ls.length - rs.length

checkUpdate = (callback) ->
  if callback?
    try
      packageInfo = require('./package.json')
    catch e
      util.log e
      return
    version = packageInfo.version
    arch = process.arch
    platform = platformMap[process.platform]
    # jQuery works well with node-webkit
    $ = window.$;
    re = /^.*shadowsocks-gui-([\d\.]+)-(\w+)-(\w+)\..*$/
    $.get('https://sourceforge.net/api/file/index/project-id/1817190/path/dist/mtime/desc/limit/4/rss',(data) ->
      results = []
      $(data).find('content').each ->
        url = $(this).attr('url')
        g = re.exec(url)
        if g?
          results.push g
      # sort versions desc
      results.sort (l, r) ->
        -compareVersion(l[1], r[1])
      # pick latest version
      for r in results
        if (r[2] == platform) and (r[3] == arch)
          if compareVersion(r[1], version) > 0
            callback r[0], r[1]
            return
    ).fail(->
      alert("error")
    )

exports.checkUpdate = checkUpdate
