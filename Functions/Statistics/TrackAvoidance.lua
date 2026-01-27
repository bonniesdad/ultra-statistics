-- TrackAvoidance.lua
-- Tracks how many times the player blocks, parries, dodges, or resists (full resist) attacks.

local function isPlayerGUID(guid)
  return guid and guid == UnitGUID('player')
end

local function increment(statKey)
  if not _G.CharacterStats or not _G.CharacterStats.GetStat or not _G.CharacterStats.UpdateStat then return end
  local current = _G.CharacterStats:GetStat(statKey) or 0
  _G.CharacterStats:UpdateStat(statKey, current + 1)
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
frame:SetScript('OnEvent', function()
  local _, subEvent, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
  if not isPlayerGUID(destGUID) then return end

  local missType
  if subEvent == 'SWING_MISSED' then
    missType = select(12, CombatLogGetCurrentEventInfo())
  elseif subEvent == 'SPELL_MISSED' or subEvent == 'RANGE_MISSED' then
    missType = select(15, CombatLogGetCurrentEventInfo())
  else
    return
  end

  if missType == 'BLOCK' then
    increment('blocks')
  elseif missType == 'PARRY' then
    increment('parries')
  elseif missType == 'DODGE' then
    increment('dodges')
  elseif missType == 'RESIST' then
    increment('resists')
  end
end)


