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
end
