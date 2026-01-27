-- Item Usage Tracker (ported from UltraHardcore)

ItemTracker = ItemTracker or {}

local healingPotionSpellIDs = {
  [439] = true,
  [440] = true,
  [2370] = true,
  [441] = true,
  [2024] = true,
  [4042] = true,
  [11387] = true,
  [21394] = true,
  [17534] = true,
  [21393] = true,
  [22729] = true,
}

local manaPotionSpellIDs = {
  [437] = true,
  [438] = true,
  [2023] = true,
  [11903] = true,
  [17530] = true,
  [17531] = true,
}

local targetDummySpellIDs = {
  [4071] = true,
  [4072] = true,
  [19805] = true,
}

local grenadeSpellIDs = {
  [4064] = true,
  [4065] = true,
  [4066] = true,
  [4067] = true,
  [4069] = true,
  [12421] = true,
  [12543] = true,
  [19784] = true,
  [4068] = true,
  [19769] = true,
  [12562] = true,
}

function ItemTracker.HandleBandageUsage(subEvent, destGUID, spellID)
  if not CharacterStats then return end
  -- "Recently Bandaged" debuff (Classic)
  if subEvent == 'SPELL_AURA_APPLIED' and destGUID == UnitGUID('player') and spellID == 11196 then
    local currentBandages = CharacterStats:GetStat('bandagesUsed') or 0
    CharacterStats:UpdateStat('bandagesUsed', currentBandages + 1)
  end
end

function ItemTracker.HandleHealthPotionUsage(subEvent, sourceGUID, spellID)
  if not CharacterStats then return end
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') and healingPotionSpellIDs[spellID] then
    local current = CharacterStats:GetStat('healthPotionsUsed') or 0
    CharacterStats:UpdateStat('healthPotionsUsed', current + 1)
  end
end

function ItemTracker.HandleManaPotionUsage(subEvent, sourceGUID, spellID)
  if not CharacterStats then return end
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') and manaPotionSpellIDs[spellID] then
    local current = CharacterStats:GetStat('manaPotionsUsed') or 0
    CharacterStats:UpdateStat('manaPotionsUsed', current + 1)
  end
end

function ItemTracker.HandleTargetDummyUsage(subEvent, sourceGUID, spellID)
  if not CharacterStats then return end
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') and targetDummySpellIDs[spellID] then
    local current = CharacterStats:GetStat('targetDummiesUsed') or 0
    CharacterStats:UpdateStat('targetDummiesUsed', current + 1)
  end
end

function ItemTracker.HandleGrenadeUsage(subEvent, sourceGUID, spellID)
  if not CharacterStats then return end
  if subEvent == 'SPELL_CAST_SUCCESS' and sourceGUID == UnitGUID('player') and grenadeSpellIDs[spellID] then
    local current = CharacterStats:GetStat('grenadesUsed') or 0
    CharacterStats:UpdateStat('grenadesUsed', current + 1)
  end
end

function ItemTracker.HandleItemUsage(subEvent, sourceGUID, destGUID, spellID)
  ItemTracker.HandleBandageUsage(subEvent, destGUID, spellID)
  ItemTracker.HandleHealthPotionUsage(subEvent, sourceGUID, spellID)
  ItemTracker.HandleManaPotionUsage(subEvent, sourceGUID, spellID)
  ItemTracker.HandleTargetDummyUsage(subEvent, sourceGUID, spellID)
  ItemTracker.HandleGrenadeUsage(subEvent, sourceGUID, spellID)
end


