-- Import Stats from Ultra (UltraHardcore)
-- UltraHardcoreDB is available as a global when the UltraHardcore addon is loaded
-- (its TOC declares ## SavedVariables: UltraHardcoreDB).

local LOWER_IS_BETTER = {
  lowestHealth = true,
  lowestHealthThisLevel = true,
  lowestHealthThisSession = true,
}

local STAT_DISPLAY_NAMES = {
  lowestHealth = 'Lowest Health (Total)',
  lowestHealthThisLevel = 'Lowest Health (This Level)',
  lowestHealthThisSession = 'Lowest Health (This Session)',
  closeEscapes = 'Close Escapes',
  enemiesSlain = 'Enemies Slain',
  elitesSlain = 'Elites Slain',
  rareElitesSlain = 'Rare Elites Slain',
  worldBossesSlain = 'World Bosses Slain',
  dungeonBossesKilled = 'Dungeon Bosses Slain',
  dungeonsCompleted = 'Dungeons Completed',
  petDeaths = 'Pet Deaths',
  partyMemberDeaths = 'Party Deaths Witnessed',
  playerDeaths = 'Player Deaths',
  playerDeathsThisSession = 'Deaths (This Session)',
  playerDeathsThisLevel = 'Deaths (This Level)',
  blocks = 'Blocks',
  parries = 'Parries',
  dodges = 'Dodges',
  resists = 'Resists',
  healthPotionsUsed = 'Health Potions Used',
  manaPotionsUsed = 'Mana Potions Used',
  bandagesUsed = 'Bandages Used',
  targetDummiesUsed = 'Target Dummies Used',
  grenadesUsed = 'Grenades Used',
  highestCritValue = 'Highest Crit Value',
  highestHealCritValue = 'Highest Heal Crit Value',
  duelsTotal = 'Duels Total',
  duelsWon = 'Duels Won',
  duelsLost = 'Duels Lost',
  duelsWinPercent = 'Duel Win %',
  playerJumps = 'Player Jumps',
  player360s = '360s During Jumps',
  goldGained = 'Gold Gained',
  goldSpent = 'Gold Spent',
}

local STAT_KEYS_IMPORT = {}
for k in pairs(STAT_DISPLAY_NAMES) do
  STAT_KEYS_IMPORT[k] = true
end

local function getUltraHardcoreStats()
  local uhc = _G.UltraHardcoreDB
  if not uhc or type(uhc) ~= 'table' then
    return nil, 'UltraHardcore addon data not found. Enable the Ultra addon and log in once, then try again.'
  end
  local cs = uhc.characterStats
  if not cs or type(cs) ~= 'table' then
    return nil, 'No character stats found in Ultra data. Has the Ultra addon recorded any stats for this character?'
  end
  local guid = UnitGUID('player')
  if not guid then
    return nil, 'Could not identify current character.'
  end
  local charData = cs[guid]
  if not charData or type(charData) ~= 'table' then
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or GetRealmName()
    local name = UnitName('player')
    local altKey = realm and name and (realm .. '-' .. name)
    charData = altKey and cs[altKey]
  end
  if not charData or type(charData) ~= 'table' then
    return nil, 'No stats found for this character in Ultra data. Play with the Ultra addon enabled to record stats, then import.'
  end
  return charData, nil
end

-- Returns { { statKey, ourVal, uhcVal, displayName }, ... } for stats where UHC is "better"
local function getImportableImprovements()
  local ours = {}
  if _G.CharacterStats and _G.CharacterStats.GetCurrentCharacterStats then
    ours = _G.CharacterStats:GetCurrentCharacterStats() or {}
  end
  local uhc, err = getUltraHardcoreStats()
  if err then
    return nil, err
  end

  local list = {}
  for statKey in pairs(STAT_KEYS_IMPORT) do
    local uv = uhc[statKey]
    if uv ~= nil then
      local numU = tonumber(uv)
      local numO = tonumber(ours[statKey])
      if numU and (numO == nil or (LOWER_IS_BETTER[statKey] and numU < numO) or (not LOWER_IS_BETTER[statKey] and numU > numO)) then
        table.insert(list, {
          statKey,
          numO or (LOWER_IS_BETTER[statKey] and 100 or 0),
          numU,
          STAT_DISPLAY_NAMES[statKey] or statKey,
        })
      end
    end
  end
  return list, nil
end

local dialogFrame
local function ensureDialog()
  if dialogFrame then return dialogFrame end

  dialogFrame = CreateFrame('Frame', 'UltraStatisticsImportDialog', UIParent, 'BackdropTemplate')
  dialogFrame:SetFrameStrata('FULLSCREEN_DIALOG')
  dialogFrame:SetToplevel(true)
  dialogFrame:SetSize(420, 320)
  dialogFrame:SetPoint('CENTER')
  dialogFrame:SetMovable(true)
  dialogFrame:RegisterForDrag('LeftButton')
  dialogFrame:SetScript('OnDragStart', function(self) self:StartMoving() end)
  dialogFrame:SetScript('OnDragStop', function(self) self:StopMovingOrSizing() end)

  local bg = dialogFrame:CreateTexture(nil, 'BACKGROUND')
  bg:SetAllPoints()
  bg:SetColorTexture(0.1, 0.1, 0.12, 0.98)
  dialogFrame:SetBackdrop({
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = false,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  dialogFrame:SetBackdropBorderColor(0.5, 0.5, 0.55, 1)

  local title = dialogFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', dialogFrame, 'TOP', 0, -14)
  title:SetText('Import Stats from Ultra')
  title:SetJustifyH('CENTER')
  dialogFrame.title = title

  local scroll = CreateFrame('ScrollFrame', nil, dialogFrame, 'UIPanelScrollFrameTemplate')
  scroll:SetPoint('TOP', title, 'BOTTOM', 0, -8)
  scroll:SetPoint('LEFT', dialogFrame, 'LEFT', 12, 0)
  scroll:SetPoint('RIGHT', dialogFrame, 'RIGHT', -28, 0)
  scroll:SetHeight(180)
  local child = CreateFrame('Frame')
  scroll:SetScrollChild(child)
  child:SetWidth(360)
  child:SetHeight(1)
  dialogFrame.scrollChild = child
  dialogFrame.scroll = scroll

  local confirmBtn = CreateFrame('Button', nil, dialogFrame, 'UIPanelButtonTemplate')
  confirmBtn:SetSize(100, 24)
  confirmBtn:SetText('Import')
  confirmBtn:SetPoint('BOTTOMRIGHT', dialogFrame, 'BOTTOM', -8, 12)
  dialogFrame.confirmBtn = confirmBtn

  local cancelBtn = CreateFrame('Button', nil, dialogFrame, 'UIPanelButtonTemplate')
  cancelBtn:SetSize(100, 24)
  cancelBtn:SetText('Cancel')
  cancelBtn:SetPoint('BOTTOMLEFT', dialogFrame, 'BOTTOM', 8, 12)
  cancelBtn:SetScript('OnClick', function()
    dialogFrame:Hide()
  end)
  dialogFrame.cancelBtn = cancelBtn

  return dialogFrame
end

function ShowImportFromUltraDialog()
  local d = ensureDialog()
  d.linePool = d.linePool or {}
  for _, line in ipairs(d.linePool) do
    line:Hide()
  end

  local list, err = getImportableImprovements()
  local ROW_H = 18
  local pad = 4
  local w = d.scrollChild:GetWidth() - 8

  local function oneLine(text, colorR, colorG, colorB, index)
    local line = d.linePool[index]
    if not line then
      line = d.scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      line:SetWidth(w)
      line:SetJustifyH('LEFT')
      table.insert(d.linePool, line)
    end
    line:SetPoint('TOPLEFT', d.scrollChild, 'TOPLEFT', 0, -((index - 1) * ROW_H))
    line:SetText(text)
    line:SetTextColor(colorR or 0.9, colorG or 0.85, colorB or 0.7, 1)
    line:Show()
  end

  if err then
    d.title:SetText('Import Stats from Ultra')
    oneLine(err, 0.9, 0.85, 0.7, 1)
    d.scrollChild:SetHeight(50)
    d.confirmBtn:Hide()
    d:SetHeight(200)
    d:Show()
    return
  end

  if not list or #list == 0 then
    d.title:SetText('Import Stats from Ultra')
    oneLine('No higher stats to import. Your current stats are already equal or better than Ultra.', 0.9, 0.85, 0.7, 1)
    d.scrollChild:SetHeight(50)
    d.confirmBtn:Hide()
    d:SetHeight(200)
    d:Show()
    return
  end

  d.title:SetText('Import Stats from Ultra (' .. #list .. ' better)')
  for i, row in ipairs(list) do
    local statKey, ourVal, uhcVal, displayName = row[1], row[2], row[3], row[4]
    local uvStr = (LOWER_IS_BETTER[statKey] and uhcVal ~= math.floor(uhcVal)) and string.format('%.1f', uhcVal) or tostring(math.floor(uhcVal + 0.5))
    local ovStr = (LOWER_IS_BETTER[statKey] and ourVal ~= math.floor(ourVal)) and string.format('%.1f', ourVal) or tostring(math.floor(ourVal + 0.5))
    oneLine(displayName .. ':  ' .. ovStr .. '  →  ' .. uvStr, 0.3, 1, 0.4, i)
  end
  d.scrollChild:SetHeight(#list * ROW_H + pad)
  d.confirmBtn:Show()
  d:SetHeight(320)

  d.confirmBtn:SetScript('OnClick', function()
    if not list or #list == 0 then d:Hide() return end
    local guid = UnitGUID('player')
    if not _G.UltraStatisticsDB then _G.UltraStatisticsDB = {} end
    if not _G.UltraStatisticsDB.characterStats then _G.UltraStatisticsDB.characterStats = {} end
    if not _G.UltraStatisticsDB.characterStats[guid] then
      _G.UltraStatisticsDB.characterStats[guid] = {}
      if _G.CharacterStats and _G.CharacterStats.defaults then
        for k, v in pairs(_G.CharacterStats.defaults) do
          _G.UltraStatisticsDB.characterStats[guid][k] = v
        end
      end
    end
    local dest = _G.UltraStatisticsDB.characterStats[guid]
    for _, row in ipairs(list) do
      dest[row[1]] = row[3]
    end
    if _G.SaveCharacterSettings then
      _G.SaveCharacterSettings(_G.GLOBAL_SETTINGS)
    end
    if _G.SaveDBData then
      _G.SaveDBData('characterStats', _G.UltraStatisticsDB.characterStats)
    end
    if _G.UpdateLowestHealthDisplay then
      _G.UpdateLowestHealthDisplay()
    end
    if _G.UpdateStatistics then
      _G.UpdateStatistics()
    end
    d:Hide()
  end)

  d:Show()
end

_G.ShowImportFromUltraDialog = ShowImportFromUltraDialog
