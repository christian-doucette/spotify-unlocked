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
    @af = RSpotify::AudioFeatures.find(song_id)
    puts(@af.tempo)

    url = "audio-analysis/#{song_id}"
    audio_analysis = RSpotify.get(url)
    #puts(audio_analysis["beats"].length())
    #puts(audio_analysis["bars"].length())
    #puts(audio_analysis["segments"].length())

    #puts(audio_analysis["bars"].length())
    #audio_analysis["bars"].first(20).each do |bar|
    #  puts("Bar Start: #{bar["start"]}, duration: #{bar["duration"]}, end: #{bar["start"]+bar["duration"]}")
    #end
    @chords_per_bar = get_chords_per_bar(audio_analysis)
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



  def cosine_similarity(u, v)
    u_mag = 0
    v_mag = 0
    u_dot_v = 0

    for i in 0..(u.length()-1)
      u_mag += u[i]**2
      v_mag += v[i]**2
      u_dot_v += u[i] * v[i]
    end

    u_mag = Math.sqrt(u_mag)
    v_mag = Math.sqrt(v_mag)
    return u_dot_v / (u_mag * v_mag)
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
        new_chord = chord_fit_euclidean(segment["pitches"])
        chords.append(new_chord)
      end
    end

    return chords
  end



  def get_chords_per_bar(audio_analysis)
    segments = audio_analysis["segments"]
    bars = audio_analysis["bars"]
    first_bar = {"start" => 0.0, "duration" => bars[0]["start"], "confidence" => 1.0}
    bars.unshift(first_bar)


    chords = Array.new
    bar_index = 0
    seg_index = 0
    bars.first(20).each do |bar|
      bar_start = bar["start"]
      bar_end = bar_start + bar["duration"]
      puts("Start: #{bar_start}, duration: #{bar["duration"]}, end: #{bar_end}")
      if bar["confidence"] > 0.0 #0.7 is a strict one

        #Skips the segments before this one
        while segments[seg_index]["start"] + segments[seg_index]["duration"] < bar_start
          seg_index += 1
        end


        #For each segment included in this beat, creates a weighted sum of pitch vectors
        while segments[seg_index]["start"] < bar_end
          seg = segments[seg_index]
          seg_start = seg["start"]
          seg_end = seg_start + seg["duration"]
          chord_total = [0,0,0,0,0,0,0,0,0,0,0,0]


          if seg_start < bar_start
            duration = seg_end - bar_start
          elsif bar_end < seg_end
            duration = bar_end - seg_start
          else
            duration = seg_end - seg_start
          end

          for k in 0..11
            chord_total[k] += ((seg["pitches"][k] * duration) / bar["duration"] )
          end

          seg_index += 1
        end
        combined_chord = chord_fit_cosine(chord_total)
        chords.append("Bar: #{bar_index}, chord: #{combined_chord}")

        seg_index -= 1
        bar_index += 1
      end
    end

    return chords
  end



  def chord_fit_euclidean(pitch_vec)
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



  def chord_fit_cosine(pitch_vec)
    bestFitPitch = -1
    bestFitModality = -1
    bestFitVal = 0
    chord_templates = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0]]

    for i in 0..11
      for j in 0..1 #0..chords.length-1 #put that instead for more chord varieties
        similarity = cosine_similarity(chord_templates[j].rotate(-i), pitch_vec)
        if similarity > bestFitVal
          bestFitPitch = i
          bestFitModality = j
          bestFitVal = similarity
        end
      end
    end
    return "#{format_key(bestFitPitch, bestFitModality)}"
  end


end
