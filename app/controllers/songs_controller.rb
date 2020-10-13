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

    @chords = get_chords(audio_analysis)
    render({ :template => "songs/chords.html.erb" })
  end



  #----------------------------------------------------------------------------#
  #-------Business logic functions that would usually go in a model------------#
  #----------------------------------------------------------------------------#



  def euclidean_distance(x, y)
    #only call this with two integer arrays of equal length
    dif_sum = 0
    i = 0
    while i<x.length
      dif_sum += (x[i]-y[i])**2
      i += 1
    end
    return Math.sqrt(dif_sum)
  end



  def format_key(keyNum, modality)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    modeArray = ["major", "minor", "sus4", "sus2", "dim", "aug"]
    return "#{keyArray[keyNum]} #{modeArray[modality]}"
  end



  def get_chords(audio_analysis)
    chords = Array.new
    audio_analysis["segments"].each do |segment|
      if segment["confidence"] > 0.7
        new_chord = get_chord_from_segment(segment)
        chords.append(new_chord)
      end
    end

    return chords
  end



  def get_chord_from_segment(segment)
    bestFitPitch = -1
    bestFitModality = -1
    bestFitVal = 4 #higher than max possible distance
    chords = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0],[1,0,0,0,0,1,0,1,0,0,0,0],[1,0,1,0,0,0,0,1,0,0,0,0],[1,0,0,1,0,0,1,0,0,0,0,0],[1,0,0,0,1,0,0,0,1,0,0,0]]

    for i in 0..11
      for j in 0..1 #0..chords.length-1 #put that instead for more chord varieties
        distance = euclidean_distance(chords[j].rotate(-i), segment["pitches"])
        if distance < bestFitVal
          bestFitPitch = i
          bestFitModality = j
          bestFitVal = distance
        end
      end
    end

    return "#{format_key(bestFitPitch, bestFitModality)} (confidence: #{segment["confidence"]})"
  end



end
