module ApplicationHelper


  def formatKey(keyNum, modality)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    if modality
      modalityStr = "major"
    else
      modalityStr = "minor"
    end
    return "#{keyArray[keyNum]} #{modalityStr}"
  end



  def formatNote(keyNum)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    return keyArray[keyNum]
  end



  def isLive(liveness)
    if liveness > 0.8
      return "Live"
    else
      return "Not Live"
    end
  end


  def plusSeparate(string)
    return string.gsub(" ","+")
  end

  def trimTitle(string)
    return string.split(" - ",2).first
  end






end
