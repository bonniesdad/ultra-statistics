function IsEnemyRareElite(unitGUID)
  if not unitGUID then
    return false
  end

  if UnitGUID('target') == unitGUID then
    local classification = UnitClassification('target')
    if classification == 'rareelite' then
      return true
    end
  end

  if IsInGroup() then
    if IsInRaid() then
      for i = 1, GetNumGroupMembers() do
        local unitID = 'raid' .. i .. 'target'
        if UnitGUID(unitID) == unitGUID then
          local classification = UnitClassification(unitID)
          if classification == 'rareelite' then
            return true
          end
        end
      end
    else
      for i = 1, GetNumGroupMembers() do
        local unitID = 'party' .. i .. 'target'
        if UnitGUID(unitID) == unitGUID then
          local classification = UnitClassification(unitID)
          if classification == 'rareelite' then
            return true
          end
        end
      end
    end
  end

  if EnemyClassificationCache and EnemyClassificationCache.RefreshFromUnits then
    EnemyClassificationCache.RefreshFromUnits()
  end
  local cached = EnemyClassificationCache and EnemyClassificationCache.Get and EnemyClassificationCache.Get(unitGUID)
  if cached == 'rareelite' then
    return true
  end

  return false
end
