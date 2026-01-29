BossFightTracker = BossFightTracker or {}

-- Boss GUIDs we're currently in combat with (any party member engaged).
local bossesInCombat = {}

local function IsPlayerOrPartyMember(guid)
  if not guid then
    return false
  end
  local playerGUID = UnitGUID('player')
  if guid == playerGUID then
    return true
  end
  if not IsInGroup() then
    return false
  end
  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local _, _, _, _, _, _, _, _, _, _, raidGUID = GetRaidRosterInfo(i)
      if raidGUID == guid then
        return true
      end
    end
  else
    for i = 1, GetNumGroupMembers() do
      local unitID = 'party' .. i
      if UnitGUID(unitID) == guid then
        return true
      end
    end
  end
  return false
end

local function IsBoss(guid)
  if not IsDungeonBoss then
    return false
  end
  local isDungeon, isRaid = IsDungeonBoss(guid)
  return isDungeon or isRaid
end

-- Combat log events where we see source and dest (damage/heal).
local COMBAT_EVENTS = {
  SWING_DAMAGE = true,
  SWING_MISSED = true,
  RANGE_DAMAGE = true,
  RANGE_MISSED = true,
  SPELL_DAMAGE = true,
  SPELL_MISSED = true,
  SPELL_PERIODIC_DAMAGE = true,
  SPELL_HEAL = true,
  SPELL_PERIODIC_HEAL = true,
  ENVIRONMENTAL_DAMAGE = true,
}

local function OnCombatLogEvent()
  local _, subEvent, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()

  -- Party/player engaged with a boss: add boss to set
  if COMBAT_EVENTS[subEvent] then
    if IsBoss(sourceGUID) and IsPlayerOrPartyMember(destGUID) then
      bossesInCombat[sourceGUID] = true
    elseif IsBoss(destGUID) and IsPlayerOrPartyMember(sourceGUID) then
      bossesInCombat[destGUID] = true
    end
    return
  end

  -- Boss died: we're no longer in combat with that boss
  if subEvent == 'PARTY_KILL' and destGUID then
    bossesInCombat[destGUID] = nil
  end
end

-- Returns true if the party is currently in combat with at least one boss.
function BossFightTracker.IsInBossFight()
  for _ in next, bossesInCombat do
    return true
  end
  return false
end

-- Returns one boss GUID we're in combat with (for attributing party deaths to a boss). Nil if none.
function BossFightTracker.GetAnyBossGUIDInCombat()
  for guid in next, bossesInCombat do
    return guid
  end
  return nil
end

-- Returns true if the given GUID is a player/party member and they died while
-- the party was in a boss fight (so the death counts as "died to the boss").
function BossFightTracker.IsDeathDuringBossFight(destGUID)
  if not destGUID then
    return false
  end
  if not IsPlayerOrPartyMember(destGUID) then
    return false
  end
  return BossFightTracker.IsInBossFight()
end

-- Clear state (e.g. when leaving instance). Optional; PARTY_KILL already clears per-boss.
function BossFightTracker.Clear()
  wipe(bossesInCombat)
end

-- Register for combat log and zone changes.
local frame = CreateFrame('Frame')
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function(_, event)
  if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    OnCombatLogEvent()
  elseif event == 'PLAYER_ENTERING_WORLD' then
    BossFightTracker.Clear()
  end
end)
