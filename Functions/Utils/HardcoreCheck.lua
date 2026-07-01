-- Utility function to check if the player is on a non-Hardcore server
-- Returns true when not on a Hardcore server, false on Hardcore
function UltraStatistics_IsHardcore()
  local isHardcoreActive = C_GameRules and C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive() or false
  return not isHardcoreActive
end