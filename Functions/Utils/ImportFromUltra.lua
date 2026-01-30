-- Import Stats from Ultra (UltraHardcore)
-- UltraHardcoreDB is available as a global when the UltraHardcore addon is loaded
-- (its TOC declares ## SavedVariables: UltraHardcoreDB).

local LOWER_IS_BETTER = {}

local STAT_DISPLAY_NAMES = {
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
    return nil, 'Ultra addon data not found. Enable the Ultra addon then try again.'
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

local DIALOG_PAD = 28
local DIALOG_PAD_TOP = 24
local DIALOG_PAD_BOTTOM = 20
local TITLE_GAP = 18
local SCROLL_HEIGHT = 180
local DIALOG_HEIGHT_MESSAGE_ONLY = 180 -- when no list (error or "no stats to import")
local SCROLL_HEIGHT_MESSAGE_ONLY = 76 -- scroll height when showing only the message
local dialogFrame
local function ensureDialog()
  if dialogFrame then
    return dialogFrame
  end

  dialogFrame = CreateFrame('Frame', 'UltraStatisticsImportDialog', UIParent, 'BackdropTemplate')
  dialogFrame:SetFrameStrata('FULLSCREEN_DIALOG')
  dialogFrame:SetToplevel(true)
  dialogFrame:SetSize(440, 340)
  dialogFrame:SetPoint('CENTER')
  dialogFrame:SetMovable(true)
  dialogFrame:RegisterForDrag('LeftButton')
  dialogFrame:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  dialogFrame:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
  end)

  local bg = dialogFrame:CreateTexture(nil, 'BACKGROUND')
  bg:SetAllPoints()
  bg:SetColorTexture(0.08, 0.08, 0.1, 0.98)
  dialogFrame:SetBackdrop({
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = false,
    edgeSize = 20,
    insets = {
      left = 8,
      right = 8,
      top = 8,
      bottom = 8,
    },
  })
  dialogFrame:SetBackdropBorderColor(0.45, 0.45, 0.5, 1)

  local title = dialogFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', dialogFrame, 'TOP', 0, -DIALOG_PAD_TOP)
  title:SetPoint('LEFT', dialogFrame, 'LEFT', DIALOG_PAD, 0)
  title:SetPoint('RIGHT', dialogFrame, 'RIGHT', -DIALOG_PAD, 0)
  title:SetText('Import Stats from Ultra')
  title:SetJustifyH('CENTER')
  title:SetTextColor(0.95, 0.9, 0.8, 1)
  dialogFrame.title = title

  local scroll = CreateFrame('ScrollFrame', nil, dialogFrame, 'UIPanelScrollFrameTemplate')
  scroll:SetPoint('TOP', title, 'BOTTOM', 0, -TITLE_GAP)
  scroll:SetPoint('LEFT', dialogFrame, 'LEFT', DIALOG_PAD, 0)
  scroll:SetPoint('RIGHT', dialogFrame, 'RIGHT', -(DIALOG_PAD + 16), 0)
  scroll:SetHeight(SCROLL_HEIGHT)
  local child = CreateFrame('Frame')
  scroll:SetScrollChild(child)
  child:SetWidth(440 - (DIALOG_PAD * 2) - 16)
  child:SetHeight(1)
  dialogFrame.scrollChild = child
  dialogFrame.scroll = scroll
  local sb
  if scroll.ScrollBar then
    sb = scroll.ScrollBar
  else
    for i = 1, scroll:GetNumChildren() do
      local c = select(i, scroll:GetChildren())
      if c and c.GetObjectType and c:GetObjectType() == 'Slider' then
        sb = c
        break
      end
    end
  end
  dialogFrame.scrollBar = sb

  local messageText = child:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  messageText:SetPoint('TOP', child, 'TOP', 0, 0)
  messageText:SetPoint('LEFT', child, 'LEFT', 0, 0)
  messageText:SetPoint('RIGHT', child, 'RIGHT', 0, 0)
  messageText:SetJustifyH('CENTER')
  messageText:SetWordWrap(true)
  messageText:SetNonSpaceWrap(true)
  messageText:Hide()
  dialogFrame.messageText = messageText

  local confirmBtn = CreateFrame('Button', nil, dialogFrame, 'UIPanelButtonTemplate')
  confirmBtn:SetSize(100, 26)
  confirmBtn:SetText('Import')
  confirmBtn:SetPoint('BOTTOM', dialogFrame, 'BOTTOM', 54, DIALOG_PAD_BOTTOM)
  dialogFrame.confirmBtn = confirmBtn

  local cancelBtn = CreateFrame('Button', nil, dialogFrame, 'UIPanelButtonTemplate')
  cancelBtn:SetSize(100, 26)
  cancelBtn:SetText('Cancel')
  cancelBtn:SetPoint('BOTTOM', dialogFrame, 'BOTTOM', -54, DIALOG_PAD_BOTTOM)
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
  if d.messageText then
    d.messageText:Hide()
  end

  local list, err = getImportableImprovements()
  local ROW_H = 20
  local pad = 8
  local listTopPad = 4
  local w = d.scrollChild:GetWidth()

  local function oneLine(text, colorR, colorG, colorB, index)
    local line = d.linePool[index]
    if not line then
      line = d.scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      line:SetWidth(w)
      line:SetJustifyH('LEFT')
      table.insert(d.linePool, line)
    end
    line:SetPoint('TOPLEFT', d.scrollChild, 'TOPLEFT', 0, -(listTopPad + (index - 1) * ROW_H))
    line:SetText(text)
    line:SetTextColor(colorR or 0.9, colorG or 0.85, colorB or 0.7, 1)
    line:Show()
  end

  local function showCenteredMessage(text, r, g, b)
    d.messageText:SetText(text)
    d.messageText:SetTextColor(r or 0.88, g or 0.84, b or 0.72, 1)
    d.messageText:Show()
    local msgH = math.max(44, d.messageText:GetStringHeight() + 12)
    d.scrollChild:SetHeight(msgH)
  end

  local function setMessageOnlyLayout()
    if d.scrollBar then
      d.scrollBar:Hide()
    end
    d.scroll:SetHeight(SCROLL_HEIGHT_MESSAGE_ONLY)
    d.scroll:ClearAllPoints()
    d.scroll:SetPoint('TOP', d.title, 'BOTTOM', 0, -TITLE_GAP)
    d.scroll:SetPoint('LEFT', d, 'LEFT', DIALOG_PAD, 0)
    d.scroll:SetPoint('RIGHT', d, 'RIGHT', -DIALOG_PAD, 0)
    d.scrollChild:SetWidth(440 - (DIALOG_PAD * 2))
    d.cancelBtn:ClearAllPoints()
    d.cancelBtn:SetPoint('BOTTOM', d, 'BOTTOM', 0, DIALOG_PAD_BOTTOM)
  end

  local function setListLayout()
    if d.scrollBar then
      d.scrollBar:Show()
    end
    d.scroll:SetHeight(SCROLL_HEIGHT)
    d.scroll:ClearAllPoints()
    d.scroll:SetPoint('TOP', d.title, 'BOTTOM', 0, -TITLE_GAP)
    d.scroll:SetPoint('LEFT', d, 'LEFT', DIALOG_PAD, 0)
    d.scroll:SetPoint('RIGHT', d, 'RIGHT', -(DIALOG_PAD + 16), 0)
    d.scrollChild:SetWidth(440 - (DIALOG_PAD * 2) - 16)
    d.cancelBtn:ClearAllPoints()
    d.cancelBtn:SetPoint('BOTTOM', d, 'BOTTOM', -54, DIALOG_PAD_BOTTOM)
  end

  if err then
    d.title:SetText('Import Stats from Ultra')
    showCenteredMessage(err, 0.9, 0.85, 0.7)
    setMessageOnlyLayout()
    d.confirmBtn:Hide()
    d:SetHeight(DIALOG_HEIGHT_MESSAGE_ONLY)
    d:Show()
    return
  end

  if not list or #list == 0 then
    d.title:SetText('Import Stats from Ultra')
    showCenteredMessage(
      'No higher stats to import. Your current stats are already equal or better than Ultra.',
      0.88,
      0.84,
      0.72
    )
    setMessageOnlyLayout()
    d.confirmBtn:Hide()
    d:SetHeight(DIALOG_HEIGHT_MESSAGE_ONLY)
    d:Show()
    return
  end

  setListLayout()

  d.title:SetText('Import Stats from Ultra (' .. #list .. ' better)')
  for i, row in ipairs(list) do
    local statKey, ourVal, uhcVal, displayName = row[1], row[2], row[3], row[4]
    local uvStr =
      (LOWER_IS_BETTER[statKey] and uhcVal ~= math.floor(uhcVal)) and string.format(
        '%.1f',
        uhcVal
      ) or tostring(math.floor(uhcVal + 0.5))
    local ovStr =
      (LOWER_IS_BETTER[statKey] and ourVal ~= math.floor(ourVal)) and string.format(
        '%.1f',
        ourVal
      ) or tostring(math.floor(ourVal + 0.5))
    oneLine(displayName .. ':  ' .. ovStr .. '  to  ' .. uvStr, 0.3, 1, 0.4, i)
  end
  d.scrollChild:SetHeight(listTopPad + #list * ROW_H + pad)
  d.confirmBtn:Show()
  d:SetHeight(340)

  d.confirmBtn:SetScript('OnClick', function()
    if not list or #list == 0 then
      d:Hide()
      return
    end
    local guid = UnitGUID('player')
    if not _G.UltraStatisticsDB then
      _G.UltraStatisticsDB = {}
    end
    if not _G.UltraStatisticsDB.characterStats then
      _G.UltraStatisticsDB.characterStats = {}
    end
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
    -- Invalidate cache so all code uses the updated DB; prevents increments from being applied to pre-import values.
    if _G.CharacterStats and _G.CharacterStats.InvalidateCache then
      _G.CharacterStats:InvalidateCache()
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
