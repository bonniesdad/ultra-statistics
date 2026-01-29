PartyDeathTracker = PartyDeathTracker or {}

local function UnitIsFeigningDeath(unitID)
  if type(UnitIsFeignDeath) == 'function' then
    return UnitIsFeignDeath(unitID)
  end
  return false
end

local function IsPartyMember(destGUID)
  local playerGUID = UnitGUID('player')
  if destGUID == playerGUID or not IsInGroup() then
    return false, nil
  end

  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local name, _, _, _, _, _, _, _, _, _, _, guid = GetRaidRosterInfo(i)
      if guid == destGUID then
        return true, name
      end
    end
  else
    for i = 1, GetNumGroupMembers() do
      local unitID = 'party' .. i
      if UnitGUID(unitID) == destGUID then
        return true, UnitName(unitID)
      end
    end
  end

  return false, nil
end

local function IsPartyMemberFeigningDeath(destGUID)
  if not IsInGroup() then
    return false
  end
  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local _, _, _, _, _, _, _, _, _, _, _, guid = GetRaidRosterInfo(i)
      if guid == destGUID then
        return UnitIsFeigningDeath('raid' .. i)
      end
    end
  else
    for i = 1, GetNumGroupMembers() do
      local unitID = 'party' .. i
      if UnitGUID(unitID) == destGUID then
        return UnitIsFeigningDeath(unitID)
      end
    end
  end
  return false
end

function PartyDeathTracker.HandlePartyMemberDeath(destGUID)
  if not CharacterStats then return end

  local isPartyMember, deadPlayerName = IsPartyMember(destGUID)
  if not isPartyMember or not deadPlayerName then return end

  if IsPartyMemberFeigningDeath(destGUID) then return end

  local current = CharacterStats:GetStat('partyMemberDeaths') or 0
  CharacterStats:UpdateStat('partyMemberDeaths', current + 1)

  -- If this death was during a boss fight, record it for dungeon/raid stats.
  local inBossFight =
    (BossFightTracker and BossFightTracker.IsDeathDuringBossFight and BossFightTracker.IsDeathDuringBossFight(
      destGUID
    )) or false
  if inBossFight then
    local bossGUID =
      BossFightTracker.GetAnyBossGUIDInCombat and BossFightTracker.GetAnyBossGUIDInCombat()
    if bossGUID and DungeonRaidStats and DungeonRaidStats.RecordBossDeath then
      DungeonRaidStats.RecordBossDeath(bossGUID)
    end
  end
end
