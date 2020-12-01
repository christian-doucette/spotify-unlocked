class SongsController < ApplicationController
  require 'rspotify'
  require 'open-uri'



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
    #@lyrics = lyrics_api(@song)
    #puts(@lyrics)
    audio_analysis = RSpotify.get("audio-analysis/#{song_id}")
    @chords = get_chords_per_bar(audio_analysis)
    render({ :template => "songs/chords.html.erb" })
  end



  def lyrics_page
    song_id = params.fetch(:song_id)
    @song = RSpotify::Track.find(song_id)
    @lyrics = lyrics_api(@song)
    render({ :template => "songs/lyrics.html.erb" })

  end


#----------------------------------------------------------------------------#
#-------Business logic functions that would usually go in a model------------#
#----------------------------------------------------------------------------#


  # Gets a list of best chords for each bar in the track
  def get_chords_per_bar(audio_analysis)
    segments = audio_analysis["segments"]
    bars = audio_analysis["bars"]
    first_bar = {"start" => 0.0, "duration" => bars[0]["start"], "confidence" => 1.0}
    bars.unshift(first_bar)


    chords = Array.new
    seg_index = 0
    bars.each do |bar|
      bar_start = bar["start"]
      bar_end = bar_start + bar["duration"]
      puts("Start: #{bar_start}, duration: #{bar["duration"]}, end: #{bar_end}")
      if bar["confidence"] > 0.0 #0.7 is a strict one

        #Skips the segments before this beat
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
        chords.append(combined_chord)
        seg_index -= 1
      end
    end

    return chords
  end





  # Formats key string from (keyNum, modality) pair - ex 5,1 -> F Minor
  def format_key(keyNum, modality)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    modeArray = ["major", "minor"]
    return "#{keyArray[keyNum]} #{modeArray[modality]}"
  end





  # Finds best major or minor chord fit using euclidean distance
  def chord_fit_euclidean(pitch_vec)
    bestFitPitch = -1
    bestFitModality = -1
    bestFitVal = 4 #higher than max possible distance
    chords = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0]]

    for i in 0..11
      for j in 0..1
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





  # Finds best major or minor chord fit using cosine similarity
  def chord_fit_cosine(pitch_vec)
    bestFitPitch = -1
    bestFitModality = -1
    bestFitVal = 0
    chord_templates = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0]]

    for i in 0..11
      for j in 0..1
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





  # Gets the lyrics for a track using APISeeds lyrics API
  def lyrics_api(track)
    song_name = track.name
    artist_name = track.artists.first.name
    key = ENV["APISEEDS_API_KEY"]
    api_link = "https://orion.apiseeds.com/api/music/lyric/#{artist_name}/#{song_name}?apikey=#{key}".gsub(/ /, "%20")
    puts(api_link)
    response = open(api_link).read
    response_JSON = JSON.parse(response)
    return response_JSON['result']['track']['text']
  end




#----------------------------------------------------------------------------#
#-----------------------------Vector functions-------------------------------#
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



    def cosine_similarity(u, v) #larger means closer
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


end
