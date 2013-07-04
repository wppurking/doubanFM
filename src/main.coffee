http = require 'http'

# http://zonyitoo.github.io/blog/2013/01/22/doubanfmbo-fang-qi-kai-fa-shou-ji/ 参考地址

drawChannels = (json) ->
  channels = JSON.parse(json)['channels']
  for channel in channels
    drawOneChannel(channel)

drawOneChannel = (channel) ->
  obj = $("<li class='channel'><a class='chl_name'>#{channel['name']}</a><span class='st_playing'></span></li>").appendTo('#channels')
  obj.find('a').data('chl', channel)


# 1. 获取渠道列表
do getChannels = ->
  json = ''

  # debug 用
  json = '{"channels":[{"name":"私人兆赫","seq_id":0,"abbr_en":"My","channel_id":0,"name_en":"Personal Radio"},{"name":"华语","seq_id":1,"abbr_en":"CH","channel_id":1,"name_en":"Chinese"},{"name":"欧美","seq_id":2,"abbr_en":"EN","channel_id":2,"name_en":"Euro-American"},{"name":"八零","seq_id":3,"abbr_en":"80","channel_id":4,"name_en":"80"},{"name":"粤语","seq_id":4,"abbr_en":"HK","channel_id":6,"name_en":"Cantonese"},{"name":"咖啡","seq_id":5,"abbr_en":"Caf","channel_id":32,"name_en":"Cafe"},{"name":"轻音乐","seq_id":6,"abbr_en":"Easy","channel_id":9,"name_en":"Easy Listening"},{"name":"电影原声","seq_id":7,"abbr_en":"Ori","channel_id":10,"name_en":"Original"},{"name":"民谣","seq_id":8,"abbr_en":"Folk","channel_id":8,"name_en":"Folk"},{"name":"古典","seq_id":9,"abbr_en":"Cla","channel_id":27,"name_en":"Classic"},{"name":"R&B","seq_id":10,"abbr_en":"R&B","channel_id":16,"name_en":"R&B"},{"name":"九零","seq_id":11,"abbr_en":"90","channel_id":5,"name_en":"90"},{"name":"爵士","seq_id":12,"abbr_en":"Jazz","channel_id":13,"name_en":"Jazz"},{"name":"小清新","seq_id":13,"abbr_en":"Indie Pop","channel_id":76,"name_en":"Indie Pop"},{"name":"女声","seq_id":14,"abbr_en":"FEM","channel_id":20,"name_en":"Female"},{"name":"中国好声音","seq_id":15,"abbr_en":"The Voice Of China","channel_id":94,"name_en":"The Voice Of China"},{"name":"摇滚","seq_id":16,"abbr_en":"Rock","channel_id":7,"name_en":"Rock"},{"name":"新歌","seq_id":17,"abbr_en":"NewSongs","channel_id":61,"name_en":"New Songs"},{"name":"法语","seq_id":18,"abbr_en":"FR","channel_id":22,"name_en":"French"},{"name":"日语","seq_id":19,"abbr_en":"JPA","channel_id":17,"name_en":"Japanese"},{"name":"韩语","seq_id":20,"abbr_en":"KRA","channel_id":18,"name_en":"Korea"},{"name":"电子","seq_id":21,"abbr_en":"Elec","channel_id":14,"name_en":"Electronic"},{"name":"说唱","seq_id":22,"abbr_en":"Rap","channel_id":15,"name_en":"Rap"},{"name":"七零","seq_id":23,"abbr_en":"70","channel_id":3,"name_en":"70"},{"name":"Easy","seq_id":24,"abbr_en":"Easy","channel_id":77,"name_en":"Easy"},{"name":"91.1","seq_id":25,"abbr_en":"91.1","channel_id":78,"name_en":"91.1"},{"name":"动漫","seq_id":26,"abbr_en":"Ani","channel_id":28,"name_en":"Anime"},{"name":"308选择出色","seq_id":27,"abbr_en":"308","channel_id":83,"name_en":"308"},{"name":"全新宝来","seq_id":28,"abbr_en":"New Bora","channel_id":98,"name_en":"New Bora"},{"name":"扬天敢留白","seq_id":29,"abbr_en":"YangTian","channel_id":105,"name_en":"Lenovo YangTian"},{"name":"earthmusic","seq_id":30,"abbr_en":"LOVEearth LOVEmusic","channel_id":107,"name_en":"LOVEearth LOVEmusic"},{"name":"翼搏新生","seq_id":31,"abbr_en":"Wing Fight New Born","channel_id":108,"name_en":"Wing Fight New Born"},{"name":"全新奥迪Q3","seq_id":32,"abbr_en":"AudiQ3","channel_id":109,"name_en":"AudiQ3"},{"name":"Polo信仰年轻","seq_id":33,"abbr_en":"Polo","channel_id":111,"name_en":"Polo"},{"name":"奥迪见地未来行","seq_id":34,"abbr_en":"Audi","channel_id":112,"name_en":"Audi"},{"name":"行乐嘉年华","seq_id":35,"abbr_en":"Carnival","channel_id":142,"name_en":"Carnival"},{"name":"迈锐宝先生俱乐部","seq_id":36,"abbr_en":"Malibu","channel_id":143,"name_en":"Malibu"},{"name":"新CC共听优雅","seq_id":37,"abbr_en":"cc","channel_id":144,"name_en":"cc"}]}'
  if json
    drawChannels(json)
    return

  http.get('http://www.douban.com/j/app/radio/channels',(res) ->
    res.on('data', (data) ->
      json += data
    )

    res.on('end', ->
      drawChannels(json)
    )
  ).on('error', (e) ->
    console.log(e.message)
  )


$('#channels').on('click', 'li.channel', (ev)->
  ev.preventDefault()
  $('li.channel').removeClass('selected')
  chl = $(ev.target).parents('li').addClass('selected').end()
  if chl.data('songs')
    chl.trigger('play')
  else
    ajaxLoadSongs(chl.data('chl'), chl)
)

$('#channels').on('play', 'li.channel', (ev) ->
  chl = $(ev.target)
  song = popSong(chl)
  if song
    chl.data('playing_song', song)
    $('#song_img').attr('src', song['picture'])
    $('#song_info').html("Title: #{song['title']}<br>Artist: #{song['artist']}")
    audio = new Audio()
    audio.src = song['url']
    audio.controls = true
    audio.play()
    chl.data('audio', audio)
    $('#song').html('').append(audio)
    autoNext(chl)
  else
    ajaxLoadSongs(chl.data('chl'), chl)
)

popSong = (chl) ->
  songs = chl.data('songs')
  if songs == undefined or songs.length <= 0
    false
  else
    song = songs.pop()
    song

# 监控自动下一首歌
autoNext = (chl)->
  setTimeout(->
    audio = chl.data('audio')
    if audio and audio.buffered.length > 0 and audio.played.end(audio.played.length - 1) >= audio.duration
      chl.trigger('play')
    else
      # TODO: 在进行 channel 切换的时候, 需要将原始的 timeout 给取消
      # TODO: 如果歌曲在同一个时间点检测的次数太多, 表示卡在这里了, 需要进行自动换歌
      autoNext(chl)
      console.log "keep monitor played?: #{audio.played.end(audio.played.length - 1)}/#{audio.duration}"
  , 2000)

ajaxLoadSongs = (channel, channelLinkA)->
  json = ''
  params =
    app_name: 'radio_desktop_win'
    version: '100'
    channel: channel['channel_id']
    type: 'n'
  options =
    host: 'www.douban.com'
    path: "/j/app/radio/people?#{$.param(params)}"

  http.get(options,(res) ->
    res.on('data', (data) ->
      json += data
    )

    res.on('end', ->
      result = JSON.parse(json)
      if result['err']
        console.log result['err']
      else
        channelLinkA.data('songs', result['song'])
        channelLinkA.trigger('play')
    )
  ).on('error', (e) ->
    console.log(e.message)
  )
