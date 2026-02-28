CritTracker = CritTracker or {}

function CritTracker.TrackCriticalHit(subEvent, sourceGUID, amount)
  if not UltraStatisticsCharacterStats then return end
  if sourceGUID ~= UnitGUID('player') then return end

  if subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE' or subEvent == 'RANGE_DAMAGE' then
    local critical
    if subEvent == 'SWING_DAMAGE' then
      critical = select(18, CombatLogGetCurrentEventInfo())
    else
      critical = select(21, CombatLogGetCurrentEventInfo())
    end

    if critical then
      local currentHighestCrit = UltraStatisticsCharacterStats:GetStat('highestCritValue') or 0
      if (amount or 0) > currentHighestCrit then
        UltraStatisticsCharacterStats:UpdateStat('highestCritValue', amount or 0)
      end
    end
  end
end

function CritTracker.TrackHealingCriticalHit(subEvent, sourceGUID)
  if not UltraStatisticsCharacterStats then return end
  if sourceGUID ~= UnitGUID('player') then return end

  if subEvent == 'SPELL_HEAL' or subEvent == 'SPELL_PERIODIC_HEAL' then
    local amount = select(15, CombatLogGetCurrentEventInfo())
    local critical = select(18, CombatLogGetCurrentEventInfo())
    if critical then
      local currentHighestHealCrit = UltraStatisticsCharacterStats:GetStat('highestHealCritValue') or 0
      if (amount or 0) > currentHighestHealCrit then
        UltraStatisticsCharacterStats:UpdateStat('highestHealCritValue', amount or 0)
      end
    end
  end
end
