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

  def audio_analysis
    url = "audio-analysis/5aHkL7tyX2wMq6tiaM0ARq"

    sections = RSpotify.get(url)["segments"]
    sections.each do |section|
      bestFitPitch = -1
      bestFitModality = -1
      bestFitVal = 4 #higher than max possible distance
      chords = [[1,0,0,0,1,0,0,1,0,0,0,0],[1,0,0,1,0,0,0,1,0,0,0,0],[1,0,0,0,0,1,0,1,0,0,0,0],[1,0,1,0,0,0,0,1,0,0,0,0],[1,0,0,1,0,0,1,0,0,0,0,0],[1,0,0,0,1,0,0,0,1,0,0,0]]

      for i in 0..11
        for j in 0..1 #0..chords.length-1 #put that instead for more chord varieties
          distance = euclidean_distance(chords[j].rotate(-i), section["pitches"])
          if distance < bestFitVal
            bestFitPitch = i
            bestFitModality = j
            bestFitVal = distance
          end

        end
      end

      if section["confidence"] > 0.7
        puts "#{formatKey(bestFitPitch, bestFitModality)}, confidence is #{section["confidence"]}"
      end
      #puts("[#{section["pitches"].join(', ')}]")
    end
    #puts(sections.length)
    #puts('done')

    render({ :template => "general/home.html.erb"})
  end


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

  def formatKey(keyNum, modality)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    modeArray = ["major", "minor", "sus4", "sus2", "dim", "aug"]
    return "#{keyArray[keyNum]} #{modeArray[modality]}"
  end


end
