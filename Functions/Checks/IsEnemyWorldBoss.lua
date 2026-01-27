function IsEnemyWorldBoss(unitGUID)
  if not unitGUID then return false end

  if UnitGUID('target') == unitGUID then
    local classification = UnitClassification('target')
    if classification == 'worldboss' then
      return true
    end
  end

  for i = 1, GetNumGroupMembers() do
    local unitID = 'party' .. i .. 'target'
    if UnitGUID(unitID) == unitGUID then
      local classification = UnitClassification(unitID)
      if classification == 'worldboss' then
        return true
      end
    end
  end

  return false
end


