-- Central combat log dispatcher for statistic tracking

local frame = CreateFrame('Frame')
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

frame:SetScript('OnEvent', function()
  local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, spellID =
    CombatLogGetCurrentEventInfo()

  local amount
  if subEvent == 'SWING_DAMAGE' then
    amount = select(12, CombatLogGetCurrentEventInfo())
  elseif subEvent == 'SPELL_DAMAGE' or subEvent == 'RANGE_DAMAGE' then
    amount = select(15, CombatLogGetCurrentEventInfo())
  else
    amount = select(12, CombatLogGetCurrentEventInfo())
  end

  if CritTracker then
    CritTracker.TrackCriticalHit(subEvent, sourceGUID, amount)
    CritTracker.TrackHealingCriticalHit(subEvent, sourceGUID)
  end

  if subEvent == 'PARTY_KILL' and KillTracker then
    KillTracker.HandlePartyKill(destGUID)
  end

  -- Some boss deaths do NOT fire PARTY_KILL for the player/party (no killing blow credit),
  -- but they DO fire UNIT_DIED. Use this to count boss kills reliably.
  if subEvent == 'UNIT_DIED' and KillTracker and KillTracker.HandleUnitDied then
    KillTracker.HandleUnitDied(destGUID)
  end

  if ItemTracker then
    ItemTracker.HandleItemUsage(subEvent, sourceGUID, destGUID, spellID)
  end

  if subEvent == 'UNIT_DIED' and PartyDeathTracker then
    PartyDeathTracker.HandlePartyMemberDeath(destGUID)
  end
end)
