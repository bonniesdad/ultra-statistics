EnemyClassificationCache = EnemyClassificationCache or {}
EnemyClassificationCache.entries = EnemyClassificationCache.entries or {}

local CACHE_TTL_SECONDS = 30

local function cacheUnitClassification(unitID)
  if not unitID then
    return
  end
  local guid = UnitGUID(unitID)
  if not guid then
    return
  end
  local classification = UnitClassification(unitID)
  if not classification or classification == 'normal' then
    return
  end
  EnemyClassificationCache.entries[guid] = {
    classification = classification,
    time = (GetTime and GetTime()) or 0,
  }
end

function EnemyClassificationCache.RefreshFromUnits()
  cacheUnitClassification('target')
  cacheUnitClassification('focus')
  cacheUnitClassification('mouseover')

  if IsInGroup() then
    if IsInRaid() then
      for i = 1, GetNumGroupMembers() do
        cacheUnitClassification('raid' .. i .. 'target')
      end
    else
      for i = 1, GetNumGroupMembers() do
        cacheUnitClassification('party' .. i .. 'target')
      end
    end
  end

  if C_NamePlate and C_NamePlate.GetNamePlates then
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
      local unitID = plate and plate.namePlateUnitToken
      if unitID then
        cacheUnitClassification(unitID)
      end
    end
  end
end

function EnemyClassificationCache.Get(unitGUID)
  if not unitGUID then
    return nil
  end
  local entry = EnemyClassificationCache.entries[unitGUID]
  if not entry then
    return nil
  end
  local now = (GetTime and GetTime()) or 0
  if (now - (entry.time or 0)) > CACHE_TTL_SECONDS then
    EnemyClassificationCache.entries[unitGUID] = nil
    return nil
  end
  return entry.classification
end

do
  local frame = CreateFrame('Frame')
  frame:RegisterEvent('PLAYER_TARGET_CHANGED')
  frame:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
  frame:RegisterEvent('NAME_PLATE_UNIT_ADDED')
  frame:RegisterEvent('GROUP_ROSTER_UPDATE')
  frame:SetScript('OnEvent', function()
    if EnemyClassificationCache and EnemyClassificationCache.RefreshFromUnits then
      EnemyClassificationCache.RefreshFromUnits()
    end
  end)
end

function IsEnemyElite(unitGUID)
  if not unitGUID then
    return false
  end

  -- Check if the killed enemy is currently our target
  if UnitGUID('target') == unitGUID then
    local classification = UnitClassification('target')
    if classification == 'elite' or classification == 'rareelite' or classification == 'worldboss' then
      return true
    end
  end

  -- Check if the killed enemy is a party member's target
  if IsInGroup() then
    if IsInRaid() then
      for i = 1, GetNumGroupMembers() do
        local unitID = 'raid' .. i .. 'target'
        if UnitGUID(unitID) == unitGUID then
          local classification = UnitClassification(unitID)
          if classification == 'elite' or classification == 'rareelite' or classification == 'worldboss' then
            return true
          end
        end
      end
    else
      for i = 1, GetNumGroupMembers() do
        local unitID = 'party' .. i .. 'target'
        if UnitGUID(unitID) == unitGUID then
          local classification = UnitClassification(unitID)
          if classification == 'elite' or classification == 'rareelite' or classification == 'worldboss' then
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
  if cached == 'elite' or cached == 'rareelite' or cached == 'worldboss' then
    return true
  end

  return false
end
