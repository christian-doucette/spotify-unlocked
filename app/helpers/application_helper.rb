module ApplicationHelper
  def formatKey(keyNum, modality)
    keyArray = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    if modality
      modalityStr = "minor"
    else
      modalityStr = "major"
    end
    return "#{keyArray[keyNum]} #{modalityStr}"
  end

  def isLive(liveness)
    if liveness > 0.8
      return "Live"
    else
      return "Not Live"
    end
  end




end
