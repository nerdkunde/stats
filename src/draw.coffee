buttons = [
  {
    'title': 'Aktivität'
    'desc': 'Aktivität nach Kapiteln'
    'method': 'track_chapter'
  }
  {
    'title': 'Anteile'
    'desc': 'Anteile im Gesamtüberblick'
    'method': 'track_topic'
  }
  {
    'title': 'Zeitstrahl'
    'desc': 'Wortmeldungen/Aktivität über die Zeit'
    'method': 'track_commitments'
  }
]

legendChapters = (data) ->
  table = $ '<table></table>'
  for i in [0..data.length-2]
    col = $ '<tr></tr>'
    col.append $ "<th>#{i}</th>"
    col.append $ "<td>#{data[i].title}</td>"
    table.append col
  $('#legend').append $ "<h3>Chapters</h3>"
  $('#legend').append table

legendTracks = (data, legend) ->
  table = $ '<table></table>'
  for i in [1..data.length-1]
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
    labelOffset: 1
    showAggregates: true
    showLabels: true
    type: 'stacked'
    Tips:
      enable: true
      onShow: (tip, elem) ->
        tip.innerHTML = "<span><b>" + elem.name +
          "</b>: " + elem.value + "</span>"
                                 
  areaChart.loadJSON(json)
  areaChart.getLegend()

draw_bar = (json, o = 'horizontal', s = 'min') ->
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
    labelOffset: 1
    type:'stacked'
    showAggregates: false
    showLabels: true
    Tips:
      enable: true
      onShow: (tip, elem) ->
        if s == 'min'
          sec = if elem.value < 60 then ' + ' +
            Math.round(elem.value) + 'sec</span>'
          else '</span>'
          tip.innerHTML = "<span><b>" + elem.name + "</b>: " +
            Math.round(elem.value/60) + "min" + sec
        else
          tip.innerHTML = "<span><b>" + elem.name + ":</b> " +
            Math.round(elem.value) + "%</span>"

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
    $('#description').empty()

    $.getJSON $(this).attr('id'), (json) ->
      file = stats json

      for button in buttons
        item = $ '<button></button>'
        item.text(button['title'])
        item.attr('value', button['method'])
        item.attr('title', button['desc'])
        item.click ->
          $('#infovis').empty()
          $('#legend').empty()
          $('#description').empty()
          $('#description').append $("<p>#{$(this).attr('title')}</p>")
          window[$(this).attr('value')](file)
        $('#options').append item

      window[buttons[0]['method']](file)
      $('#description').append $("<p>#{buttons[0]['title']}</p>")
      $('#container').css('display', 'block')
      $('#description').css('display', 'block')

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
