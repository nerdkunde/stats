files = []
files.push 'data/fs133-ich-werde-noch-meinen-kindern-davon-erzaehlen.json'
files.push 'data/fs132-005-clemens.json'
files.push 'data/SZ011.json'
files.push 'data/lnp102-nur-wenige-admins-haben-zugriff.json'

class Chapter
  constructor: (@title, @obj) ->
  start: -> parseFloat(@obj['start_sec'])

class Track
  constructor: (@title, @activity, @length) ->

  total: (start = 0, end = @length) ->
    time = 0
    $.each @activity, (index, value) ->
      if parseFloat(value[0]) >= start && parseFloat(value[1]) <= end
        time += (parseFloat(value[1]) - parseFloat(value[0]))
    time

  count: (start, end = @length) ->
    i = 0
    $.each @activity, (index, value) ->
      i += 1 if parseFloat(value[0]) >= start && parseFloat(value[1]) <= end
    i

  percent: (start, end = @length) ->
    100*(this.total(start, end)/end)

class File
  constructor: (@url) ->
    chapters = []
    tracks = []

    $.getJSON @url, (json) ->
      $.each json['chapters'].sort(fn), (index, value) ->
        chapters.push new Chapter value['title'], value
      chapters.push new Chapter 'End',
        'start_sec': json['length']

      $.each json['statistics']['tracks'], (index, value) ->
        if value['activity']
          tracks.push new Track(value['identifier'],
            value['activity'],
            parseFloat(json['multi_input_files'][index]['input_length']))

    @chapters = chapters
    @tracks = tracks


menu = ->
  for i in [0..files.length-1]
    $.getJSON files[i], (json) ->
      menu_item(json['metadata']['title'], "data/#{json['output_basename']}.json")

stats = (url) ->
  new File(url)

track_commitments = (file) ->
  labels = []
  quarter1 = []
  quarter2 = []
  quarter3 = []
  quarter4 = []

  for track in file.tracks
    labels.push track.title
    quarter1.push track.count(0, track.length/4)

  for track in file.tracks
    quarter2.push track.count(track.length/4, track.length/3)

  for track in file.tracks
    quarter3.push track.count(track.length/3, track.length/2)

  for track in file.tracks
    quarter4.push track.count(track.length/2, track.length)

  data =
    'label': labels
    'values': [
      {
        'label': '¼'
        'values': quarter1
      },
      {
        'label': '½'
        'values': quarter2
      },
      {
        'label': '¾'
        'values': quarter3
      },
      {
        'label': '1'
        'values': quarter4
      }
    ]

  legend = draw_chart(data)
  legendTracks(file.tracks, legend)

track_topic = (file) ->
  t = file.tracks[0]
  labels = []
  values = []
  hosts = []

  for track in file.tracks
    values.push track.percent(0)
    labels.push track.title

  data =
    'label': labels
    'values': [
      'label': []
      'values': values
     ]

  legend = draw_bar(data, 'vertical')

  for i in [0..file.chapters.length-2]
    for track in file.tracks
      t = track if track.percent(file.chapters[i].start(),
        file.chapters[i+1].start()) > t.percent(file.chapters[i].start(),
          file.chapters[i+1].start())
    hosts.push
      'chapter': file.chapters[i].title
      'master': t.title

  legendTracks(file.tracks, legend)
  for track in file.tracks
    legendTopics(hosts, track.title)

track_chapter = (file) ->
    t = file.tracks[0]
    labels = []
    values = []

    for i in [0..file.chapters.length-2]
      v = []
      for track in file.tracks
        t = track if track.percent(file.chapters[i].start(),
            file.chapters[i+1].start()) > t.percent(file.chapters[i].start(),
              file.chapters[i+1].start())
        v.push track.percent(file.chapters[i].start(), file.chapters[i+1].start())
      values.push
        'label': i
        'values': v

    for track in file.tracks
      labels.push track.title

    data =
      'label': labels
      'values': values

    legend = draw_bar(data)
    legendTracks(file.tracks, legend)
    legendChapters(file.chapters)

window.track_chapter = track_chapter
window.track_commitments = track_commitments
window.track_topic = track_topic
window.menu = menu
window.stats = stats

fn = (a,b) ->
  if parseFloat(a['start_sec']) < parseFloat(b['start_sec']) then -1
  else 1
