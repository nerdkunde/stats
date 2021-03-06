// Generated by CoffeeScript 1.7.1
(function() {
  var Chapter, File, Track, files, fn, menu, stats, topics, track_chapter, track_commitments, track_topic;

  files = ["data/nk029.json", "data/nk030.json", "data/nk031.json"];

  topics = {};

  Chapter = (function() {
    function Chapter(title, obj) {
      this.title = title;
      this.obj = obj;
    }

    Chapter.prototype.start = function() {
      return parseFloat(this.obj['start_sec']);
    };

    return Chapter;

  })();

  Track = (function() {
    Track.prototype.TOPICS = {};

    Track.prototype.topic = function(head) {
      if (!this.TOPICS[this.title]) {
        this.TOPICS[this.title] = [];
      }
      return this.TOPICS[this.title].push(head);
    };

    function Track(title, activity, length) {
      this.title = title;
      this.activity = activity;
      this.length = length;
    }

    Track.prototype.total = function(start, end) {
      var time;
      if (start == null) {
        start = 0;
      }
      if (end == null) {
        end = this.length;
      }
      time = 0;
      $.each(this.activity, function(index, value) {
        if (parseFloat(value[0]) >= start && parseFloat(value[1]) <= end) {
          return time += parseFloat(value[1]) - parseFloat(value[0]);
        }
      });
      return time;
    };

    Track.prototype.count = function(start, end) {
      var i;
      if (end == null) {
        end = this.length;
      }
      i = 0;
      $.each(this.activity, function(index, value) {
        if (parseFloat(value[0]) >= start && parseFloat(value[1]) <= end) {
          return i += 1;
        }
      });
      return i;
    };

    Track.prototype.percent = function(start, end) {
      if (end == null) {
        end = this.length;
      }
      return 100 * (this.total(start, end) / end);
    };

    return Track;

  })();

  File = (function() {
    function File(json) {
      var chapters, tracks;
      chapters = [];
      tracks = [];
      $.each(json['chapters'].sort(fn), function(index, value) {
        return chapters.push(new Chapter(value['title'], value));
      });
      chapters.push(new Chapter('End', {
        'start_sec': json['length']
      }));
      tracks.push(new Track('Empty', [], 0));
      $.each(json['statistics']['tracks'], function(index, value) {
        if (value['activity']) {
          return tracks.push(new Track(value['identifier'], value['activity'], parseFloat(json['multi_input_files'][index]['input_length'])));
        }
      });
      this.chapters = chapters;
      this.tracks = tracks;
    }

    return File;

  })();

  menu = function() {
    var i, _i, _ref, _results;
    _results = [];
    for (i = _i = 0, _ref = files.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      _results.push($.getJSON(files[i], function(json) {
        return menu_item(json['metadata']['title'], "data/" + json['output_basename'] + ".json");
      }));
    }
    return _results;
  };

  stats = function(url) {
    return new File(url);
  };

  track_commitments = function(file) {
    var data, labels, legend, sixth1, sixth2, sixth3, sixth4, sixth5, sixth6, track, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
    labels = [];
    sixth1 = [];
    sixth2 = [];
    sixth3 = [];
    sixth4 = [];
    sixth5 = [];
    sixth6 = [];
    _ref = file.tracks;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      track = _ref[_i];
      if (track.length > 0) {
        labels.push(track.title);
        sixth1.push(track.count(0, track.length / 6));
      }
    }
    _ref1 = file.tracks;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      track = _ref1[_j];
      if (track.length > 0) {
        sixth2.push(track.count(track.length / 6, track.length / 3));
      }
    }
    _ref2 = file.tracks;
    for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
      track = _ref2[_k];
      if (track.length > 0) {
        sixth3.push(track.count(track.length / 3, track.length / 2));
      }
    }
    _ref3 = file.tracks;
    for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
      track = _ref3[_l];
      if (track.length > 0) {
        sixth4.push(track.count(track.length / 2, 2 * track.length / 3));
      }
    }
    _ref4 = file.tracks;
    for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
      track = _ref4[_m];
      if (track.length > 0) {
        sixth5.push(track.count(2 * track.length / 3, 5 * track.length / 6));
      }
    }
    _ref5 = file.tracks;
    for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
      track = _ref5[_n];
      if (track.length > 0) {
        sixth6.push(track.count(5 * track.length / 6, track.length));
      }
    }
    data = {
      'label': labels,
      'values': [
        {
          'label': '⅙',
          'values': sixth1
        }, {
          'label': '⅓',
          'values': sixth2
        }, {
          'label': '½',
          'values': sixth3
        }, {
          'label': '⅔',
          'values': sixth4
        }, {
          'label': '⅚',
          'values': sixth5
        }, {
          'label': '1',
          'values': sixth6
        }
      ]
    };
    legend = draw_chart(data);
    return legendTracks(file.tracks, legend);
  };

  track_topic = function(file) {
    var data, hosts, i, labels, legend, t, track, values, _i, _j, _k, _l, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _results;
    t = file.tracks[0];
    labels = [];
    values = [];
    hosts = [];
    _ref = file.tracks;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      track = _ref[_i];
      if (track.length > 0) {
        values.push(track.percent(0));
        labels.push(track.title);
      }
    }
    data = {
      'label': labels,
      'values': [
        {
          'label': [],
          'values': values
        }
      ]
    };
    legend = draw_bar(data, 'vertical', '%');
    for (i = _j = 0, _ref1 = file.chapters.length - 2; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
      _ref2 = file.tracks;
      for (_k = 0, _len1 = _ref2.length; _k < _len1; _k++) {
        track = _ref2[_k];
        if (track.percent(file.chapters[i].start(), file.chapters[i + 1].start()) > t.percent(file.chapters[i].start(), file.chapters[i + 1].start())) {
          t = track;
        }
        t.topic(file.chapters[i].title);
      }
      hosts.push({
        'chapter': file.chapters[i].title,
        'master': t.title
      });
    }
    legendTracks(file.tracks, legend);
    _ref3 = file.tracks;
    _results = [];
    for (_l = 0, _len2 = _ref3.length; _l < _len2; _l++) {
      track = _ref3[_l];
      if (track.length > 0) {
        console.log(Track.prototype.TOPICS[track.title]);
        _results.push(legendTopics(hosts, track.title));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  track_chapter = function(file) {
    var data, i, labels, legend, t, track, v, values, _i, _j, _k, _len, _len1, _ref, _ref1, _ref2;
    t = file.tracks[0];
    labels = [];
    values = [];
    for (i = _i = 0, _ref = file.chapters.length - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      v = [];
      _ref1 = file.tracks;
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        track = _ref1[_j];
        if (track.length > 0) {
          if (track.percent(file.chapters[i].start(), file.chapters[i + 1].start()) > t.percent(file.chapters[i].start(), file.chapters[i + 1].start())) {
            t = track;
          }
          v.push(track.total(file.chapters[i].start(), file.chapters[i + 1].start()));
        }
      }
      values.push({
        'label': i,
        'values': v
      });
    }
    _ref2 = file.tracks;
    for (_k = 0, _len1 = _ref2.length; _k < _len1; _k++) {
      track = _ref2[_k];
      if (track.length > 0) {
        labels.push(track.title);
      }
    }
    data = {
      'label': labels,
      'values': values
    };
    legend = draw_bar(data);
    legendTracks(file.tracks, legend);
    return legendChapters(file.chapters);
  };

  window.track_chapter = track_chapter;

  window.track_commitments = track_commitments;

  window.track_topic = track_topic;

  window.menu = menu;

  window.stats = stats;

  fn = function(a, b) {
    if (parseFloat(a['start_sec']) < parseFloat(b['start_sec'])) {
      return -1;
    } else {
      return 1;
    }
  };

}).call(this);
