-- Track lowest health percentage (ported/minimized from UltraHardcore)

local pvpPauseLowestHealth = false
local pvpPauseLowestHealthThisLevel = false
local pvpPauseLowestHealthThisSession = false
local pvpPauseLowestHealthCloseEscape = false

-- A health drop below this percentage is considered a close escape
closeEscapeHealthPercent = 15

if type(GLOBAL_SETTINGS) ~= 'table' then
  GLOBAL_SETTINGS = {}
end
GLOBAL_SETTINGS.isDueling = GLOBAL_SETTINGS.isDueling or false

local combatLowest = nil

local function IsFeigningDeath()
  for i = 1, 40 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitBuff('player', i)
    if not name then
      break
    end
    if spellId == 5384 or name == 'Feign Death' then
      return true
    end
  end
  return false
end

local function UpdateLowestHealthStat(stat, value)
  if CharacterStats and not UnitIsDeadOrGhost('player') and value ~= nil and value > 0 then
    CharacterStats:UpdateStat(stat, value)
  end
end

local function leftCombat()
  if combatLowest == nil then return end
  if not CharacterStats then return end

  local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
  local currentLowestHealthThisLevel = CharacterStats:GetStat('lowestHealthThisLevel') or 100
  local currentLowestHealthThisSession = CharacterStats:GetStat('lowestHealthThisSession') or 100
  local currentCloseEscapes = CharacterStats:GetStat('closeEscapes') or 0

  if not pvpPauseLowestHealth and combatLowest < currentLowestHealth then
    UpdateLowestHealthStat('lowestHealth', combatLowest)
  end
  if not pvpPauseLowestHealthThisLevel and combatLowest < currentLowestHealthThisLevel then
    UpdateLowestHealthStat('lowestHealthThisLevel', combatLowest)
  end
  if not pvpPauseLowestHealthThisSession and combatLowest < currentLowestHealthThisSession then
    UpdateLowestHealthStat('lowestHealthThisSession', combatLowest)
  end

  if not pvpPauseLowestHealthCloseEscape and combatLowest < closeEscapeHealthPercent then
    if not UnitIsDeadOrGhost('player') then
      CharacterStats:UpdateStat('closeEscapes', currentCloseEscapes + 1)
    end
  end

  combatLowest = nil
end

local function TrackLowestHealth(event)
  if not CharacterStats then return end

  local health = UnitHealth('player')
  local maxHealth = UnitHealthMax('player')
  if not maxHealth or maxHealth <= 0 then return end

  local inCombat = UnitAffectingCombat('player')
  local healthPercent = (health / maxHealth) * 100

  local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
  local currentLowestHealthThisLevel = CharacterStats:GetStat('lowestHealthThisLevel') or 100
  local currentLowestHealthThisSession = CharacterStats:GetStat('lowestHealthThisSession') or 100

  if inCombat then
    combatLowest = math.min(healthPercent, combatLowest or 100)
    return
  end

  if event == 'UNIT_HEALTH' and not pvpPauseLowestHealth and healthPercent < currentLowestHealth then
    UpdateLowestHealthStat('lowestHealth', healthPercent)
  end
  if event == 'UNIT_HEALTH' and not pvpPauseLowestHealthThisLevel and healthPercent < currentLowestHealthThisLevel then
    UpdateLowestHealthStat('lowestHealthThisLevel', healthPercent)
  end
  if event == 'UNIT_HEALTH' and not pvpPauseLowestHealthThisSession and healthPercent < currentLowestHealthThisSession then
    UpdateLowestHealthStat('lowestHealthThisSession', healthPercent)
  end

  if event == 'UNIT_HEALTH' and not pvpPauseLowestHealthCloseEscape and healthPercent < closeEscapeHealthPercent then
    pvpPauseLowestHealthCloseEscape = true
  end

  if pvpPauseLowestHealthCloseEscape and healthPercent > closeEscapeHealthPercent then
    pvpPauseLowestHealthCloseEscape = false
  end
end

local function HandleSessionLowestReset(eventType)
  if not CharacterStats then return end

  if eventType == 'PLAYER_LOGOUT' then
    local currentTime = GetServerTime and GetServerTime() or time()
    CharacterStats:UpdateStat('lastLogoutTime', currentTime)
  end
  if eventType == 'PLAYER_LOGIN' then
    local currentTime = GetServerTime and GetServerTime() or time()
    local lastLogoutTime = CharacterStats:GetStat('lastLogoutTime')
    if lastLogoutTime and (currentTime - lastLogoutTime) > 1800 then
      CharacterStats:ResetLowestHealthThisSession()
    end
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('UNIT_HEALTH')
frame:RegisterEvent('DUEL_REQUESTED')
frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
frame:RegisterEvent('DUEL_FINISHED')
frame:RegisterEvent('PLAYER_REGEN_ENABLED')
frame:RegisterEvent('PLAYER_LEVEL_UP')
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('PLAYER_LOGOUT')

frame:SetScript('OnEvent', function(_, event, arg1, _, arg3)
  if event == 'UNIT_HEALTH' and arg1 ~= 'player' then return end

  if event == 'DUEL_REQUESTED' or (event == 'UNIT_SPELLCAST_SUCCEEDED' and arg1 == 'player' and arg3 == 7266) then
    pvpPauseLowestHealth = true
    pvpPauseLowestHealthThisLevel = true
    pvpPauseLowestHealthThisSession = true
    pvpPauseLowestHealthCloseEscape = true
    if type(GLOBAL_SETTINGS) ~= 'table' then
      GLOBAL_SETTINGS = {}
    end
    GLOBAL_SETTINGS.isDueling = true
  elseif event == 'DUEL_FINISHED' then
    if type(GLOBAL_SETTINGS) ~= 'table' then
      GLOBAL_SETTINGS = {}
    end
    GLOBAL_SETTINGS.isDueling = false
  elseif event == 'PLAYER_LEVEL_UP' then
    if CharacterStats and CharacterStats.ResetLowestHealthThisLevel then
      CharacterStats:ResetLowestHealthThisLevel()
    end
  elseif event == 'PLAYER_LOGIN' or event == 'PLAYER_LOGOUT' then
    HandleSessionLowestReset(event)
  elseif event == 'PLAYER_REGEN_ENABLED' then
    leftCombat()
    return
  end

  if IsFeigningDeath() then return end
  TrackLowestHealth(event)
end)


