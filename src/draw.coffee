ua = navigator.userAgent
iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i)
typeOfCanvas = typeof HTMLCanvasElement
nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function')
textSupport = nativeCanvasSupport && (typeof document.createElement('canvas').getContext('2d').fillText == 'function')
labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML'
nativeTextSupport = labelType == 'Native'
useGradients = nativeCanvasSupport
animate = !(iStuff || !nativeCanvasSupport)

buttons = [
  { 'title': 'Sprecher nach Kapiteln', 'method': 'track_chapter' }
  { 'title': 'Anteile', 'method': 'track_topic' }
  { 'title': 'Wortmeldungen', 'method': 'track_commitments' }
]

legendChapters = (data) ->
  table = $ '<table></table>'
  for i in [0..data.length-2]
    col = $ '<tr></tr>'
    col.append $ "<td>#{i}</td>"
    col.append $ "<td>#{data[i].title}</td>"
    table.append col
  $('#legend').append $ "<h3>Chapters</h3>"
  $('#legend').append table

legendTracks = (data, legend) ->
  table = $ '<table></table>'
  for i in [0..data.length-1]
    col = $ '<tr></tr>'
    col.append $ "<th><div class='query-color'
      style='background-color:#{legend[data[i].title]};'></div></th>"
    col.append $ "<td>#{data[i].title}</td>"
    table.append col
  $('#legend').append table

legendTopics = (data, master) ->
   table = $ '<table></table>'
   for host in data
     if master == host['master']
       col = $ '<tr></tr>'
       col.append $ "<td>#{host['chapter']}</td>"
       table.append col

   $('#legend').append $ "<h3>#{master}</h3>"
   $('#legend').append table

draw_chart = (json) ->
  areaChart = new $jit.AreaChart
    injectInto: 'infovis'
    animate: true
    Margin:
      top: 5
      left: 5
      right: 5
      bottom: 5
    labelOffset: 10
    showAggregates: true
    showLabels: true
    type: 'stacked'
  
  areaChart.loadJSON(json)
  areaChart.getLegend()

draw_bar = (json, o = 'horizontal') ->
  barChart = new $jit.BarChart
    injectInto: 'infovis'
    animate: true
    orientation: o
    barsOffset: 0.5
    Margin:
      top: 5
      left: 5
      right: 5
      bottom: 5
    labelOffset: 5
    type:'stacked'
    showAggregates: false
    showLabels: true

  barChart.loadJSON(json)
  barChart.getLegend()

menu_item = (title, url) ->
  link = $ "<a></a>"
  link.text title
  link.attr 'id', url
  link.click ->
    $('#infovis').empty()
    $('#legend').empty()
    $('#options').empty()

    file = stats $(this).attr('id')
    for button in buttons
      item = $ '<button></button>'
      item.text(button['title'])
      item.attr('value', button['method'])
      item.click ->
        $('#infovis').empty()
        $('#legend').empty()
        $('#container').css('display', 'block')
        window[$(this).attr('value')](file)
      $('#options').append item
  p = $ '<p></p>'
  p.append link
  $('#menu').append p

window.draw_bar = draw_bar
window.draw_chart = draw_chart
window.menu_item = menu_item
window.legendTopics = legendTopics
window.legendChapters = legendChapters
window.legendTracks = legendTracks

$(document).ready ->
  menu()
