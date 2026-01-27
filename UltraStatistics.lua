addonName = ...
UltraStatistics = CreateFrame('Frame')

-- Globals expected by the ported UltraHardcore UI
GLOBAL_SETTINGS = GLOBAL_SETTINGS or {}

UltraStatistics:RegisterEvent('PLAYER_LOGIN')
UltraStatistics:RegisterEvent('ADDON_LOADED')

UltraStatistics:SetScript('OnEvent', function(_, event, arg1)
  if event == 'ADDON_LOADED' then
    if arg1 ~= addonName then return end
    -- SavedVariables are loaded at this point; ensure we have base tables.
    if not UltraStatisticsDB then
      UltraStatisticsDB = {}
    end
  end

  if event == 'PLAYER_LOGIN' then
    if LoadDBData then
      LoadDBData()
    end
    if _G.UpdateStatistics then
      _G.UpdateStatistics()
    end
  end
end)


