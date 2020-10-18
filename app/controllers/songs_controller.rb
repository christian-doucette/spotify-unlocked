class SongsController < ApplicationController
  require 'rspotify'



  def song_data
    #Displays search bar on song data page
    render({ :template => "songs/song_data.html.erb" })
  end



  def song_search
    #Processes the song search form submission
    search_string = params.fetch(:song_from_query)
    song = RSpotify::Track.search(search_string).first
    if !song.blank?
      redirect_to("/song_data/#{song.id}")
    else
      redirect_to("/song_data")
    end
  end



  def song_data_with_display
    #Displays a song and search bar on song data page, given song_id
    song_id = params.fetch(:song_id)
    @song = RSpotify::Track.find(song_id)
    @audio_features = RSpotify::AudioFeatures.find(song_id)
    render({ :template => "songs/song_data.html.erb" })
  end



  def chords_page
    song_id = params.fetch(:song_id)
    @song = RSpotify::Track.find(song_id)

    url = "audio-analysis/#{song_id}"
    audio_analysis = RSpotify.get(url)
    #puts(audio_analysis["beats"].length())
    #puts(audio_analysis["bars"].length())
    #puts(audio_analysis["segments"].length())

    #puts(audio_analysis["bars"].length())
    #audio_analysis["bars"].first(20).each do |bar|
    #  puts("Bar Start: #{bar["start"]}, duration: #{bar["duration"]}, end: #{bar["start"]+bar["duration"]}")
    #end
    @chords_per_beat = get_chords_per_beat(audio_analysis)
    @chords = get_chords(audio_analysis)
    render({ :template => "songs/chords.html.erb" })
  end



  #----------------------------------------------------------------------------#
  #-------Business logic functions that would usually go in a model------------#
  #----------------------------------------------------------------------------#



  def euclidean_distance(x, y) #smaller means closer
    dif_sum = 0
    i = 0
    while i<x.length
      dif_sum += (x[i]-y[i])**2
      i += 1
    end
    return Math.sqrt(dif_sum)
  end


  def dot(x, y) #larger means closer
    sum = 0
    i = 0
    while i<x.length
      sum += x[i]*y[i]
      i += 1
    end
    return sum
  end


  def div(vector, divisor)
    ret_array = Array.new
    for entry in vector
      ret_array.append(entry/divisor)
    end
    return ret_array
  end


  def cosine_distance(x, y) #larger means closer
    zero_vec = [0,0,0,0,0,0,0,0,0,0,0,0]
    return dot(x, y)/ (euclidean_distance(x, zero_vec) * dot(y, zero_vec))
  end


  def format_key(keyNum, modality)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    modeArray = ["major", "minor", "sus4", "sus2", "dim", "aug"]
    return "#{keyArray[keyNum]} #{modeArray[modality]}"
  end



  def get_chords(audio_analysis)
    chords = Array.new
    audio_analysis["segments"].each do |segment|
      if segment["confidence"] > 0.5 #0.7 is a strict one
        new_chord = get_chord_from_pitch_vec_dot(segment["pitches"])
        chords.append(new_chord)
      end
    end

    return chords
  end



  def get_chords_per_beat(audio_analysis)
    segments = audio_analysis["segments"]
    beats = audio_analysis["bars"]
    first_beat = {"start" => 0.0, "duration" => beats[0]["start"], "confidence" => 1}
    puts("added first beat")
    puts(first_beat["confidence"])

    beats.unshift(first_beat)
    #puts(segments.length())
    chords = Array.new
    beat_index = 0
    seg_index = 0
    beats.first(20).each do |beat|
      beat_start = beat["start"]
      beat_end = beat_start + beat["duration"]
      puts("Start: #{beat_start}, duration: #{beat["duration"]}, end: #{beat_end}")
      #puts(beat["duration"])
      if beat["confidence"] > 0.0 #0.7 is a strict one

        while segments[seg_index]["start"] + segments[seg_index]["duration"] < beat_start
          seg_index += 1
        end

        while segments[seg_index]["start"] < beat_end
          seg = segments[seg_index]
          seg_start = seg["start"]
          seg_end = seg_start + seg["duration"]
          chord_total = [0,0,0,0,0,0,0,0,0,0,0,0]


          if seg_start < beat_start
            duration = seg_end - beat_start
          elsif beat_end < seg_end
            duration = beat_end - seg_start
          else
            duration = seg_end - seg_start
          end

          for k in 0..11
            chord_total[k] += ((seg["pitches"][k] * duration) / beat["duration"] )
          end

          seg_index += 1
        end
        combined_chord = get_chord_from_pitch_vec(chord_total)
        chords.append("Beat: #{beat_index}, chord: #{combined_chord}")

        seg_index -= 1
        beat_index += 1
      end
    end

    return chords
  end



  def get_chord_from_pitch_vec(pitch_vec)
    bestFitPitch = -1
    bestFitModality = -1
    bestFitVal = 4 #higher than max possible distance
    chords = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0],[1,0,0,0,0,1,0,1,0,0,0,0],[1,0,1,0,0,0,0,1,0,0,0,0],[1,0,0,1,0,0,1,0,0,0,0,0],[1,0,0,0,1,0,0,0,1,0,0,0]]

    for i in 0..11
      for j in 0..1 #0..chords.length-1 #put that instead for more chord varieties
        distance = euclidean_distance(chords[j].rotate(-i), pitch_vec)
        if distance < bestFitVal
          bestFitPitch = i
          bestFitModality = j
          bestFitVal = distance
        end
      end
    end
    return "#{format_key(bestFitPitch, bestFitModality)}"
  end



  def get_chord_from_pitch_vec_dot(pitch_vec)
    bestFitPitch = -1
    bestFitModality = -1
    bestFitVal = 0 #higher than max possible distance
    chords = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0],[1,0,0,0,0,1,0,1,0,0,0,0],[1,0,1,0,0,0,0,1,0,0,0,0],[1,0,0,1,0,0,1,0,0,0,0,0],[1,0,0,0,1,0,0,0,1,0,0,0]]

    for i in 0..11
      for j in 0..1 #0..chords.length-1 #put that instead for more chord varieties
        distance = cosine_distance(chords[j].rotate(-i), pitch_vec)
        if distance > bestFitVal
          bestFitPitch = i
          bestFitModality = j
          bestFitVal = distance
        end
      end
    end
    return "#{format_key(bestFitPitch, bestFitModality)}"
  end


end
