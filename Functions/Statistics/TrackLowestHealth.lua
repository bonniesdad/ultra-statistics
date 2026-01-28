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

local function leftCombat()
  if combatLowest == nil then return end
  if not CharacterStats then return end

  local currentCloseEscapes = CharacterStats:GetStat('closeEscapes') or 0

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

  if inCombat then
    combatLowest = math.min(healthPercent, combatLowest or 100)
    return
  end

  if event == 'UNIT_HEALTH' and not pvpPauseLowestHealthCloseEscape and healthPercent < closeEscapeHealthPercent then
    pvpPauseLowestHealthCloseEscape = true
  end

  if pvpPauseLowestHealthCloseEscape and healthPercent > closeEscapeHealthPercent then
    pvpPauseLowestHealthCloseEscape = false
  end
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('UNIT_HEALTH')
frame:RegisterEvent('DUEL_REQUESTED')
frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
frame:RegisterEvent('DUEL_FINISHED')
frame:RegisterEvent('PLAYER_REGEN_ENABLED')
frame:RegisterEvent('PLAYER_LOGOUT')

frame:SetScript('OnEvent', function(_, event, arg1, _, arg3)
  if event == 'UNIT_HEALTH' and arg1 ~= 'player' then return end

  if event == 'DUEL_REQUESTED' or (event == 'UNIT_SPELLCAST_SUCCEEDED' and arg1 == 'player' and arg3 == 7266) then
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
  elseif event == 'PLAYER_LOGOUT' then
    local currentTime = GetServerTime and GetServerTime() or time()
    CharacterStats:UpdateStat('lastLogoutTime', currentTime)
  elseif event == 'PLAYER_REGEN_ENABLED' then
    leftCombat()
    return
  end

  if IsFeigningDeath() then return end
  TrackLowestHealth(event)
end)
