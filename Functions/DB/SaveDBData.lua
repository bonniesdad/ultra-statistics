-- Save values persistently to UltraStatisticsDB

function SaveDBData(name, newValue)
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end
  UltraStatisticsDB[name] = newValue
end

function SaveCharacterSettings(settings)
  if not UltraStatisticsDB then
    UltraStatisticsDB = {}
  end
  if not UltraStatisticsDB.characterSettings then
    UltraStatisticsDB.characterSettings = {}
  end

  local characterGUID = UnitGUID('player')
  UltraStatisticsDB.characterSettings[characterGUID] = settings
end


