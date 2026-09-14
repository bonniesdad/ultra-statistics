-- Statistics Tab Content - Full size scrollable frame

-- Helper function to check if player has Engineering profession
local function HasEngineering()
  local prof1, prof2 = GetProfessions()
  if not prof1 and not prof2 then
    return false
  end

  local professions = { prof1, prof2 }
  for _, profIndex in ipairs(professions) do
    if profIndex then
      local name, _, _, _, _, _, skillLine = GetProfessionInfo(profIndex)
      if skillLine == 202 then -- Engineering skill line ID
        return true
      end 
    end
  end
  return false
end

-- Centralized tooltip map for all statistics
local STATISTIC_TOOLTIPS = {
  -- Character Info section
  level = 'Your current character level',
  guild = 'Your current guild name',
  totalHP = 'The highest maximum health you have ever had',
  totalResource = 'The highest maximum primary resource you have ever had',
  -- Combat section
  enemiesSlainTotal = 'Total number of enemies you have killed',
  elitesSlain = 'Number of elite enemies you have killed',
  rareElitesSlain = 'Number of rare elite enemies you have killed',
  worldBossesSlain = 'Number of world bosses you have killed',
  dungeonBossesSlain = 'Number of dungeon bosses you have killed',
  dungeonsCompleted = 'Number of dungeons you have fully completed',
  highestCritValue = 'The highest critical hit damage you have dealt',
  highestHealCritValue = 'The highest critical heal you have done',
  petDeaths = 'Total number of times your pet has died permanently',
  -- Survival section
  closeEscapes = 'Number of times your health has dropped below ' .. closeEscapeHealthPercent .. '%',
  healthPotionsUsed = 'Number of health potions you have consumed',
  manaPotionsUsed = 'Number of mana potions you have consumed',
  bandagesApplied = 'Number of bandages you have used to heal',
  targetDummiesUsed = 'Number of target dummies you have used',
  grenadesUsed = 'Number of grenades you have thrown',
  playerDeaths = 'Total number of times your character has died',
  serverDeaths = 'Total deaths across all characters on this server',
  playerDeathsOpenWorld = 'Number of times your character has died in the open world',
  playerDeathsBattleground = 'Number of times your character has died in a battleground',
  playerDeathsArena = 'Number of times your character has died in an arena match',
  lowestHealth = 'The lowest health percentage you have ever reached',
  lowestHealthThisLevel = 'The lowest health percentage you have reached at your current level',
  lowestHealthThisSession = 'The lowest health percentage you have reached this login session',
  blocks = 'Number of times you blocked an incoming attack',
  parries = 'Number of times you parried an incoming attack',
  dodges = 'Number of times you dodged an incoming attack',
  resists = 'Number of times you fully resisted a spell attack',
  -- Social section
  partyDeathsWitnessed = 'Number of party member deaths you have witnessed',
  playerKills = 'Number of enemy players you have killed',
  duelsTotal = 'Total number of duels you have done',
  duelsWon = 'Number of duels you have won',
  duelsLost = 'Number of duels you have lost',
  duelsWinPercent = 'Percentage of duels you have won',
  -- Misc section
  playerJumps = 'Number of jumps you have performed',
  -- Economy section
  goldGained = 'Total money gained',
  goldSpent = 'Total money spent',
}

-- Helper function to attach tooltip to a statistic label
local function AddStatisticTooltip(label, tooltipKey)
  if not label or not tooltipKey then return end

  local tooltipText = STATISTIC_TOOLTIPS[tooltipKey]
  if not tooltipText then return end

  label:SetScript('OnEnter', function()
    GameTooltip:SetOwner(label, 'ANCHOR_RIGHT')
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    GameTooltip:Show()
  end)

  label:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
end

-- Shared configuration for the new stat bar visuals
local STAT_BAR_HEIGHT = 25
local STAT_BAR_INSET = 2 -- widen bars by reducing side inset by 20px per side
local STAT_FILL_INSET = 3
local ROW_Y_ADJUST = -(LAYOUT.ROW_HEIGHT - STAT_BAR_HEIGHT) / 2
local BAR_VERTICAL_SHIFT = 28 -- pull bars up slightly now that min labels are hidden
local BAR_ROW_HEIGHT_REDUCTION = 30 -- shrink bar rows vertically
local DEFAULT_BAR_ROW_HEIGHT =
  math.max(STAT_BAR_HEIGHT + 4, (LAYOUT.ROW_HEIGHT * 2) - BAR_ROW_HEIGHT_REDUCTION)
local SECTION_CONTENT_BOTTOM_PADDING = 12 -- gap between last row and frame edge
local SECTION_BOTTOM_PADDING = 30 -- add breathing room below each section

local STAT_BAR_CONFIG = {
  default = {
    color = { 0.25, 0.65, 0.9, 0.95 },
    bgColor = { 0.05, 0.05, 0.07, 0.75 },
    valueOnly = true,
  },
  percent = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.35, 0.3, 0.95 },
    bgColor = { 0.07, 0.07, 0.09, 0.75 },
    valueOnly = true,
  },
  duelsWinPercent = {
    type = 'percent',
    max = 100,
    color = { 0.9, 0.7, 0.25, 0.95 },
    valueOnly = true,
  },
  level = {
    max = 60, -- classic cap
    valueOnly = true,
  },
  guild = {
    type = 'text',
    valueOnly = true,
  },
  totalHP = {
    valueOnly = true,
  },
  maxResource = {
    valueOnly = true,
  },
  closeEscapes = {
    valueOnly = true,
  },
  petDeaths = {
    valueOnly = true,
  },
  enemiesSlain = {
    valueOnly = true,
  },
  elitesSlain = {
    valueOnly = true,
  },
  rareElitesSlain = {
    valueOnly = true,
  },
  worldBossesSlain = {
    valueOnly = true,
  },
  dungeonBossesKilled = {
    valueOnly = true,
  },
  dungeonsCompleted = {
    valueOnly = true,
  },
  playerKills = {
    valueOnly = true,
  },
  highestCritValue = {
    valueOnly = true,
  },
  highestHealCritValue = {
    valueOnly = true,
  },
  healthPotionsUsed = {
    valueOnly = true,
  },
  manaPotionsUsed = {
    valueOnly = true,
  },
  bandagesUsed = {
    valueOnly = true,
  },
  targetDummiesUsed = {
    valueOnly = true,
  },
  grenadesUsed = {
    valueOnly = true,
  },
  partyMemberDeaths = {
    valueOnly = true,
  },
  playerDeaths = {
    valueOnly = true,
  },
  serverDeaths = {
    valueOnly = true,
  },
  playerDeathsOpenWorld = {
    valueOnly = true,
  },
  playerDeathsBattleground = {
    valueOnly = true,
  },
  playerDeathsArena = {
    valueOnly = true,
  },
  lowestHealth = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.35, 0.3, 0.95 },
    bgColor = { 0.07, 0.07, 0.09, 0.75 },
    valueOnly = true,
  },
  lowestHealthThisLevel = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.35, 0.3, 0.95 },
    bgColor = { 0.07, 0.07, 0.09, 0.75 },
    valueOnly = true,
  },
  lowestHealthThisSession = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.35, 0.3, 0.95 },
    bgColor = { 0.07, 0.07, 0.09, 0.75 },
    valueOnly = true,
  },
  blocks = {
    valueOnly = true,
  },
  parries = {
    valueOnly = true,
  },
  dodges = {
    valueOnly = true,
  },
  resists = {
    valueOnly = true,
  },
  duelsTotal = {
    valueOnly = true,
  },
  duelsWon = {
    valueOnly = true,
  },
  duelsLost = {
    valueOnly = true,
  },
  playerJumps = {
    valueOnly = true,
  },
  goldGained = {
    type = 'money',
    valueOnly = true,
  },
  goldSpent = {
    type = 'money',
    valueOnly = true,
  },
}

-- Expose to other modules (e.g. MainScreenStatistics) without duplicating config.
-- NOTE: This file is loaded on addon load (per `.toc`), so this global is available during gameplay.
_G.ULTRA_STAT_BAR_CONFIG = STAT_BAR_CONFIG

local statBars = {}
local statLabels = {}
local UpdateStatBar

local function GetPlayerPrimaryResourceLabelAndType()
  local powerType, powerToken = UnitPowerType('player')
  local labelsByType = {
    [0] = _G.MANA or 'Mana',
    [1] = _G.RAGE or 'Rage',
    [2] = _G.FOCUS or 'Focus',
    [3] = _G.ENERGY or 'Energy',
    [4] = _G.COMBO_POINTS or 'Combo Points',
    [5] = _G.RUNES or 'Runes',
    [6] = _G.RUNIC_POWER or 'Runic Power',
  }

  local label = labelsByType[powerType]
  if type(label) == 'string' and label ~= '' then
    return label, powerType
  end

  if type(powerToken) == 'string' and powerToken ~= '' then
    local tokenLabel = _G[powerToken]
    if type(tokenLabel) == 'string' and tokenLabel ~= '' then
      return tokenLabel, powerType
    end
    local pretty = string.lower(powerToken):gsub('_', ' '):gsub('(%a)([%w_]*)', function(a, b)
      return string.upper(a) .. b
    end)
    return pretty, powerType
  end

  return 'Resource', powerType
end

local function CreateStatBar(parent)
  local barFrame = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  barFrame:SetHeight(STAT_BAR_HEIGHT)
  barFrame:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {
      left = 2,
      right = 2,
      top = 2,
      bottom = 2,
    },
  })
  barFrame:SetBackdropColor(0.12, 0.16, 0.24, 0.85)
  barFrame:SetBackdropBorderColor(0.18, 0.35, 0.55, 0.9)

  local bg = barFrame:CreateTexture(nil, 'BACKGROUND')
  bg:SetPoint('TOPLEFT', barFrame, 'TOPLEFT', 2, -2)
  bg:SetPoint('BOTTOMRIGHT', barFrame, 'BOTTOMRIGHT', -2, 2)
  bg:SetColorTexture(0.08, 0.12, 0.2, 0.85)

  local fill = barFrame:CreateTexture(nil, 'ARTWORK')
  fill:SetPoint('TOPLEFT', bg, 'TOPLEFT', STAT_FILL_INSET, -STAT_FILL_INSET)
  fill:SetPoint('BOTTOMLEFT', bg, 'BOTTOMLEFT', STAT_FILL_INSET, STAT_FILL_INSET)
  fill:SetWidth(0)
  fill:SetColorTexture(0.25, 0.65, 0.9, 0.95)

  local text = barFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  text:SetPoint('CENTER', barFrame, 'CENTER', 0, 0)

  return {
    frame = barFrame,
    fill = fill,
    text = text,
    bg = bg,
  }
end

local function PositionStatBar(bar, parent, yOffset, layoutOptions)
  if not bar or not bar.frame then return end
  bar.frame:ClearAllPoints()
  local cfg = bar.statKey and STAT_BAR_CONFIG[bar.statKey]
  local isValueOnly = cfg and cfg.valueOnly
  local yPosition
  if isValueOnly then
    -- Align value-only rows with the label row
    yPosition = yOffset + ROW_Y_ADJUST
  else
    yPosition =
      yOffset - LAYOUT.ROW_HEIGHT - (LAYOUT.ROW_HEIGHT - STAT_BAR_HEIGHT) / 2 + BAR_VERTICAL_SHIFT
  end
  local left = (layoutOptions and layoutOptions.left) or (LAYOUT.ROW_INDENT + STAT_BAR_INSET)
  if layoutOptions and layoutOptions.width then
    local width = layoutOptions.width
    bar.frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', left, yPosition)
    bar.frame:SetPoint('TOPRIGHT', parent, 'TOPLEFT', left + width, yPosition)
  else
    bar.frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', left, yPosition)
    bar.frame:SetPoint(
      'TOPRIGHT',
      parent,
      'TOPRIGHT',
      -LAYOUT.ROW_INDENT - STAT_BAR_INSET,
      yPosition
    )
  end
end

local function CreateBarRow(parent, statKey, yOffset, isLast, layoutOptions)
  local bar = CreateStatBar(parent)
  bar.statKey = statKey
  bar.minText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  bar.maxText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')

  bar.minText:SetPoint('BOTTOMLEFT', bar.frame, 'TOPLEFT', 0, 4)
  bar.maxText:ClearAllPoints()
  bar.maxText:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 0)
  bar.maxText:SetJustifyH('RIGHT')
  bar.maxText:SetDrawLayer('OVERLAY', 10)
  bar.minText:Hide()
  bar.maxText:Hide()

  if not isLast then
    local divider = parent:CreateTexture(nil, 'ARTWORK')
    divider:SetColorTexture(0.25, 0.25, 0.3, 0.65)
    divider:SetHeight(1)
    divider:SetPoint('TOP', bar.frame, 'BOTTOM', 0, -14)
    divider:SetPoint('LEFT', parent, 'LEFT', LAYOUT.ROW_INDENT + 5, 0)
    divider:SetPoint('RIGHT', parent, 'RIGHT', -LAYOUT.ROW_INDENT - 5, 0)
    bar.divider = divider
  end

  statBars[statKey] = bar
  PositionStatBar(bar, parent, yOffset, layoutOptions)
  return bar
end

local TWO_COLUMN_GAP = 24
local LABEL_BAR_OFFSET = (LAYOUT.ROW_INDENT + 12) - (LAYOUT.ROW_INDENT + STAT_BAR_INSET)

local function AttachSettingCheckbox(radio, settingName)
  if not radio or not settingName then return end
  local checked = false
  if ULTRA_STATISTICS_GLOBAL_SETTINGS and ULTRA_STATISTICS_GLOBAL_SETTINGS[settingName] ~= nil then
    checked = ULTRA_STATISTICS_GLOBAL_SETTINGS[settingName] and true or false
  end
  if tempSettings and tempSettings[settingName] ~= nil then
    checked = tempSettings[settingName] and true or false
  end
  radio:SetChecked(checked)
  radioButtons[settingName] = radio
  radio:SetScript('OnClick', function(self)
    local v = self:GetChecked() and true or false
    if tempSettings then
      tempSettings[settingName] = v
    end
    if ULTRA_STATISTICS_GLOBAL_SETTINGS then
      ULTRA_STATISTICS_GLOBAL_SETTINGS[settingName] = v
    end
    if UltraStatsFrame and UltraStatsFrame.UpdateRowVisibility then
      UltraStatsFrame.UpdateRowVisibility()
    end
  end)
end

local function SetStatRowShown(row, shown)
  if not row then return end
  if row.label then
    row.label:SetShown(shown)
  end
  if row.radio then
    row.radio:SetShown(shown)
  end
  if row.bar then
    if row.bar.frame then
      row.bar.frame:SetShown(shown)
    end
    if row.bar.minText then
      row.bar.minText:SetShown(shown)
    end
    if row.bar.maxText then
      row.bar.maxText:SetShown(shown)
    end
    if row.bar.divider then
      row.bar.divider:SetShown(shown)
    end
  end
end

local function RelayoutStatRows(parent, rows, options)
  if not parent then
    return 0
  end
  rows = rows or parent._statRows or {}
  local opts = options or parent._statGridOptions or {}
  local defaultWidth = opts.defaultWidth or 0.5
  local columnGap = opts.columnGap or TWO_COLUMN_GAP
  local rowHeight = opts.rowHeight or DEFAULT_BAR_ROW_HEIGHT
  local baseYOffset = opts.baseYOffset or -LAYOUT.CONTENT_PADDING
  local parentWidth = parent:GetWidth()
  if not parentWidth or parentWidth == 0 then
    parentWidth = opts.fallbackWidth or 465
  end
  local barLeftBase = LAYOUT.ROW_INDENT + STAT_BAR_INSET
  local fullBarWidth = math.max(0, parentWidth - barLeftBase * 2)
  local halfBarWidth = (fullBarWidth - columnGap) / 2
  if halfBarWidth < 0 then
    halfBarWidth = fullBarWidth / 2
    columnGap = 0
  end

  local nextColumn = 0
  local accumulatedHeight = 0
  local pendingRowHeight = 0
  local pendingRowYOffset = baseYOffset
  local valueOnlyRowHeight = opts.valueOnlyRowHeight or (STAT_BAR_HEIGHT + 4)
  local visibleCount = 0

  for _, row in ipairs(rows) do
    if row.visible ~= false then
      visibleCount = visibleCount + 1
      local width = row.width or defaultWidth
      local rowHeightForStat = row.isValueOnly and valueOnlyRowHeight or rowHeight
      local isFullWidth = width >= 1
      local barWidth = isFullWidth and fullBarWidth or halfBarWidth
      local columnIndex
      local yOffset

      if isFullWidth then
        if nextColumn == 1 then
          accumulatedHeight = accumulatedHeight + pendingRowHeight
          pendingRowHeight = 0
          pendingRowYOffset = baseYOffset - accumulatedHeight
          nextColumn = 0
        end
        columnIndex = 0
        yOffset = baseYOffset - accumulatedHeight
        accumulatedHeight = accumulatedHeight + rowHeightForStat
      else
        if nextColumn == 0 then
          columnIndex = 0
          pendingRowHeight = rowHeightForStat
          pendingRowYOffset = baseYOffset - accumulatedHeight
          nextColumn = 1
          yOffset = pendingRowYOffset
        else
          columnIndex = 1
          yOffset = pendingRowYOffset
          if rowHeightForStat > pendingRowHeight then
            pendingRowHeight = rowHeightForStat
          end
          nextColumn = 0
          accumulatedHeight = accumulatedHeight + pendingRowHeight
          pendingRowHeight = 0
          pendingRowYOffset = baseYOffset - accumulatedHeight
        end
      end

      local columnLeft = barLeftBase
      if not isFullWidth and columnIndex == 1 then
        columnLeft = columnLeft + halfBarWidth + columnGap
      end

      local labelLeft = columnLeft + LABEL_BAR_OFFSET + 8
      if row.label then
        row.label:ClearAllPoints()
        row.label:SetPoint('TOPLEFT', parent, 'TOPLEFT', labelLeft, yOffset + ROW_Y_ADJUST)
      end
      if row.radio and row.label then
        row.radio:ClearAllPoints()
        row.radio:SetPoint('RIGHT', row.label, 'LEFT', -4, 0)
      end
      PositionStatBar(row.bar, parent, yOffset, {
        left = columnLeft,
        width = barWidth,
      })
      SetStatRowShown(row, true)
    else
      SetStatRowShown(row, false)
    end
  end

  if nextColumn == 1 then
    accumulatedHeight = accumulatedHeight + pendingRowHeight
  end

  local totalHeight = math.max(rowHeight, accumulatedHeight + LAYOUT.CONTENT_PADDING * 2 - 12)
  if visibleCount == 0 then
    totalHeight = LAYOUT.CONTENT_PADDING * 2
  end
  parent:SetHeight(totalHeight + SECTION_CONTENT_BOTTOM_PADDING)
  return visibleCount
end

local function CreateStatsGrid(parent, statsList, options)
  if not parent or not statsList or #statsList == 0 then
    return 0
  end

  local opts = options or {}
  parent._statGridOptions = opts
  parent._statRows = {}

  local defaultWidth = opts.defaultWidth or 0.5
  local valueOnlyRowHeight = opts.valueOnlyRowHeight or (STAT_BAR_HEIGHT + 4)
  local rowHeight = opts.rowHeight or DEFAULT_BAR_ROW_HEIGHT

  -- Create all rows first, then lay them out through the shared helper.
  for _, stat in ipairs(statsList) do
    local statKey = stat.key
    if statKey then
      local width = stat.width or defaultWidth
      local cfg = STAT_BAR_CONFIG[statKey]
      if cfg and cfg.valueOnly and width < 1 then
        width = 1
      end
      local isValueOnly = cfg and cfg.valueOnly

      local label = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      label:SetText(stat.label or statKey)
      statLabels[statKey] = label
      if stat.tooltipKey then
        AddStatisticTooltip(label, stat.tooltipKey)
      end

      local bar = CreateBarRow(parent, statKey, 0, true, {
        left = LAYOUT.ROW_INDENT + STAT_BAR_INSET,
        width = 100,
      })

      local value
      if stat.valueFunc then
        value = stat.valueFunc()
      else
        value = UltraStatisticsCharacterStats:GetStat(statKey)
      end
      if value == nil and stat.defaultValue ~= nil then
        value = stat.defaultValue
      end
      UpdateStatBar(statKey, value)

      local radio
      if opts.createCheckboxes ~= false then
        local settingName = stat.settingName
        if settingName == nil then
          settingName =
            (opts.settingPrefix or 'showMainStatisticsPanel') .. string.gsub(
              statKey,
              '^%l',
              string.upper
            )
        end
        if settingName and settingName ~= '' then
          radio = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
          radio:SetScale(0.7)
          AttachSettingCheckbox(radio, settingName)
        end
      end

      local tooltipText = ''
      if stat.tooltipKey and STATISTIC_TOOLTIPS[stat.tooltipKey] then
        tooltipText = STATISTIC_TOOLTIPS[stat.tooltipKey]
      end
      local searchBlob = string.lower(table.concat({
        tostring(stat.label or ''),
        tostring(statKey or ''),
        tostring(tooltipText or ''),
      }, ' '))

      table.insert(parent._statRows, {
        key = statKey,
        label = label,
        bar = bar,
        radio = radio,
        width = width,
        isValueOnly = isValueOnly and true or false,
        searchBlob = searchBlob,
        visible = true,
      })
    end
  end

  return RelayoutStatRows(parent, parent._statRows, opts)
end

local function FormatMoneyText(copper)
  copper = tonumber(copper) or 0
  if copper < 0 then
    copper = -copper
  end
  if copper == 0 then
    return '-'
  end
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = math.floor(copper % 100)

  local parts = {}
  local iconSize = 12
  if g > 0 then
    local goldIcon =
      string.format('|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', g, goldIcon))
  end
  if s > 0 then
    local silverIcon =
      string.format('|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', s, silverIcon))
  end
  -- Only show copper if it's non-zero.
  if c > 0 then
    local copperIcon =
      string.format('|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', c, copperIcon))
  end
  return (#parts > 0) and table.concat(parts, ' ') or '-'
end

function UpdateStatBar(statKey, value)
  local bar = statBars[statKey]
  if not bar then return end

  local cfg = STAT_BAR_CONFIG[statKey] or STAT_BAR_CONFIG.default

  if bar.bg then
    bar.bg:Hide()
  end
  if bar.fill then
    bar.fill:Hide()
  end
  if bar.minText then
    bar.minText:Hide()
  end
  if bar.maxText then
    bar.maxText:Hide()
  end

  local rawValue = (cfg.type == 'text') and value or (value or 0)
  local isZero = cfg.type ~= 'text' and rawValue == 0
  local displayText

  if cfg.type == 'text' then
    if type(rawValue) == 'string' and rawValue ~= '' then
      displayText = rawValue
    elseif rawValue ~= nil and rawValue ~= '' then
      displayText = tostring(rawValue)
    else
      displayText = '-'
    end
  elseif cfg.type == 'percent' then
    local pctMax = cfg.max or 100
    local percent = math.max(0, math.min(value or 0, pctMax))
    displayText = isZero and '-' or string.format('%.1f%%', percent)
  elseif cfg.type == 'money' then
    displayText = isZero and '-' or FormatMoneyText(rawValue)
  else
    local suffix = cfg.suffix or ''
    displayText = isZero and '-' or (UltraStatistics_FormatNumberWithCommas(rawValue) .. suffix)
  end

  bar.frame:SetBackdrop(nil)
  bar.text:ClearAllPoints()
  bar.text:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 6)
  bar.text:SetJustifyH('RIGHT')
  bar.text:SetText(displayText or '')
  bar.text:SetTextColor(1, 1, 1, 1)
  bar.frame:SetHeight(STAT_BAR_HEIGHT)
end

-- Initialize Statistics Tab when called
function UltraStatistics_InitializeStatisticsTab(tabContents)
  -- Check if tabContents[1] exists
  if not tabContents or not tabContents[1] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[1].initialized then return end

  -- Mark as initialized
  tabContents[1].initialized = true

  -- Search row: [Search bar stretches] [Clear] [Expand] [Collapse]
  -- Slightly larger left pad so the row sits visually centered (InputBox chrome reads left-heavy).
  local SEARCH_ROW_PAD_LEFT = 10
  local SEARCH_ROW_PAD_RIGHT = 4

  local collapseAllButton = CreateFrame('Button', nil, tabContents[1], 'UIPanelButtonTemplate')
  collapseAllButton:SetSize(80, 22)
  collapseAllButton:SetText('Collapse')
  collapseAllButton:SetPoint('TOPRIGHT', tabContents[1], 'TOPRIGHT', -SEARCH_ROW_PAD_RIGHT, -60)

  local expandAllButton = CreateFrame('Button', nil, tabContents[1], 'UIPanelButtonTemplate')
  expandAllButton:SetSize(80, 22)
  expandAllButton:SetText('Expand')
  expandAllButton:SetPoint('TOPRIGHT', collapseAllButton, 'TOPLEFT', -6, 0)

  local clearSearchButton = CreateFrame('Button', nil, tabContents[1], 'UIPanelButtonTemplate')
  clearSearchButton:SetSize(56, 22)
  clearSearchButton:SetText('Clear')
  clearSearchButton:SetPoint('TOPRIGHT', expandAllButton, 'TOPLEFT', -6, 0)

  local searchBox = CreateFrame('EditBox', nil, tabContents[1], 'InputBoxTemplate')
  searchBox:SetHeight(25)
  searchBox:SetAutoFocus(false)
  searchBox:SetPoint('TOPLEFT', tabContents[1], 'TOPLEFT', SEARCH_ROW_PAD_LEFT, -58)
  searchBox:SetPoint('TOPRIGHT', clearSearchButton, 'TOPLEFT', -6, 2)

  local searchPlaceholder = searchBox:CreateFontString(nil, 'OVERLAY', 'GameFontDisableSmall')
  searchPlaceholder:SetPoint('LEFT', searchBox, 'LEFT', 6, 0)
  searchPlaceholder:SetText('Search stats...')

  local statsFrame = CreateFrame('Frame', nil, tabContents[1], 'BackdropTemplate')
  statsFrame:SetPoint('TOP', searchBox, 'BOTTOM', 0, -10)
  statsFrame:SetPoint('LEFT', tabContents[1], 'LEFT', 0, 0)
  statsFrame:SetPoint('RIGHT', tabContents[1], 'RIGHT', 0, 0)
  statsFrame:SetPoint('BOTTOM', tabContents[1], 'BOTTOM', 0, 10)
  statsFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 5,
      right = 5,
      top = 5,
      bottom = 5,
    },
  })
  statsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95) -- Darker, more solid background
  statsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8) -- Softer border
  -- Create scroll frame for statistics content
  local statsScrollFrame = CreateFrame('ScrollFrame', nil, statsFrame, 'UIPanelScrollFrameTemplate')
  statsScrollFrame:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -10)
  statsScrollFrame:SetPoint('BOTTOMRIGHT', statsFrame, 'BOTTOMRIGHT', -30, 10) -- Leave room for scrollbar on right
  -- Create scroll child frame
  local statsScrollChild = CreateFrame('Frame', nil, statsScrollFrame)
  local SECTION_WIDTH = 485
  local CONTENT_WIDTH = 465
  statsScrollChild:SetSize(SECTION_WIDTH, 300)
  statsScrollFrame:SetScrollChild(statsScrollChild)
  local resourceEventFrame

  -- Track all sections for dynamic positioning
  local sections = {}
  local updateSectionPositions

  local function syncStatsContentWidths()
    local w = statsScrollFrame:GetWidth()
    if w and w > 0 then
      SECTION_WIDTH = w
      CONTENT_WIDTH = math.max(100, w - 20)
    end
    statsScrollChild:SetWidth(SECTION_WIDTH)
    for _, section in ipairs(sections) do
      if section.header then
        section.header:SetWidth(SECTION_WIDTH)
      end
      if section.content then
        section.content:SetWidth(CONTENT_WIDTH)
        if section.content._statRows then
          RelayoutStatRows(section.content, section.content._statRows, section.content._statGridOptions)
        end
      end
    end
  end
  local function addSection(header, content, name, title)
    local section = {
      header = header,
      content = content,
      name = name,
      title = title or name,
      collapsed = ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections and ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections[name] or false,
      hiddenBySearch = false,
    }
    table.insert(sections, section)
    return section
  end

  -- Function to update section positions based on collapsed state
  updateSectionPositions = function()
    local lastAnchor = nil
    for _, section in ipairs(sections) do
      if section.hiddenBySearch then
        section.header:Hide()
        section.content:Hide()
      else
        section.header:Show()
        section.header:ClearAllPoints()
        if not lastAnchor then
          section.header:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -5)
        else
          local previousSection = lastAnchor
          local anchorFrame =
            previousSection.collapsed and previousSection.header or previousSection.content
          section.header:SetPoint(
            'TOPLEFT',
            anchorFrame,
            'BOTTOMLEFT',
            previousSection.collapsed and 0 or -LAYOUT.CONTENT_INDENT,
            -LAYOUT.SECTION_SPACING
          )
        end

        if section.collapsed then
          section.content:Hide()
        else
          section.content:Show()
          section.content:ClearAllPoints()
          section.content:SetPoint(
            'TOPLEFT',
            section.header,
            'BOTTOMLEFT',
            LAYOUT.CONTENT_INDENT,
            -LAYOUT.CONTENT_PADDING
          )
        end
        lastAnchor = section
      end
    end

    local bottom = 20
    if lastAnchor then
      local bottomFrame = lastAnchor.collapsed and lastAnchor.header or lastAnchor.content
      bottom = math.abs(select(5, bottomFrame:GetPoint(1)) or 0) + (bottomFrame:GetHeight() or 0) + 40
    end
    -- Prefer measuring from scroll child top to last frame bottom when available
    if lastAnchor then
      local bottomFrame = lastAnchor.collapsed and lastAnchor.header or lastAnchor.content
      local top = statsScrollChild:GetTop()
      local frameBottom = bottomFrame:GetBottom()
      if top and frameBottom then
        bottom = (top - frameBottom) + 40
      end
    end
    statsScrollChild:SetHeight(math.max(300, bottom))
  end

  -- Helper function to create a collapsible header
  local function makeHeaderClickable(header, content, sectionName, section)
    -- Add collapse icon
    local collapseIcon = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    collapseIcon:SetPoint('LEFT', header, 'LEFT', 10, 0)
    collapseIcon:SetTextColor(0.9, 0.85, 0.75, 1)
    collapseIcon:SetShadowOffset(1, -1)
    collapseIcon:SetShadowColor(0, 0, 0, 0.8)

    -- Function to update icon
    local function updateIcon(collapsed)
      collapseIcon:SetText(collapsed and '+' or '-')
    end

    if section then
      section.SetCollapsed = function(collapsed, opts)
        opts = opts or {}
        section.collapsed = collapsed and true or false
        updateIcon(section.collapsed)
        if not opts.skipSave then
          if not ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections then
            ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections = {}
          end
          ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections[sectionName] = section.collapsed
        end
        if not opts.skipLayout then
          updateSectionPositions()
        end
        if not section.collapsed and UpdateLowestHealthDisplay then
          UpdateLowestHealthDisplay()
        end
      end
    end

    -- Enable mouse interaction
    header:EnableMouse(true)
    header:SetScript('OnMouseDown', function(self, button)
      if button == 'LeftButton' and section and section.SetCollapsed then
        section.SetCollapsed(not section.collapsed)
      end
    end)

    -- Add hover effect
    header:SetScript('OnEnter', function(self)
      self:SetBackdropColor(0.2, 0.2, 0.28, 0.95)
      self:SetBackdropBorderColor(0.6, 0.6, 0.75, 1)
    end)
    header:SetScript('OnLeave', function(self)
      self:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
      self:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
    end)

    -- Set initial icon state
    if section then
      updateIcon(section.collapsed)
    end
  end

  -- Create modern WoW-style Character Info section (collapsible)
  local characterInfoHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  characterInfoHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)

  -- Modern WoW row styling with rounded corners and greyish background
  characterInfoHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  characterInfoHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85) -- Darker blue-tinted background
  characterInfoHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9) -- Softer blue-tinted border
  -- Create header text (offset to make room for collapse icon)
  local characterInfoLabel =
    characterInfoHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  characterInfoLabel:SetPoint('LEFT', characterInfoHeader, 'LEFT', 24, 0)
  characterInfoLabel:SetText('Character Info')
  characterInfoLabel:SetTextColor(0.9, 0.85, 0.75, 1) -- Warmer, more readable color
  characterInfoLabel:SetShadowOffset(1, -1)
  characterInfoLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Character Info breakdown
  local characterInfoContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  characterInfoContent:SetSize(CONTENT_WIDTH, LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Level only
  -- Position will be set by updateSectionPositions
  characterInfoContent:Show() -- Show by default
  -- Register section and make header clickable
  local characterInfoSection =
    addSection(characterInfoHeader, characterInfoContent, 'characterInfo', 'Character Info')
  makeHeaderClickable(
    characterInfoHeader,
    characterInfoContent,
    'characterInfo',
    characterInfoSection
  )
  -- Modern content frame styling
  characterInfoContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  characterInfoContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6) -- Very subtle dark background
  characterInfoContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5) -- Subtle border
  local characterStatsConfig = { {
    key = 'level',
    label = 'Level:',
    tooltipKey = 'level',
    width = 1,
    settingName = 'showMainStatisticsPanelLevel',
    valueFunc = function()
      return UnitLevel('player') or 1
    end,
    defaultValue = 1,
  }, {
    key = 'guild',
    label = 'Guild:',
    tooltipKey = 'guild',
    width = 1,
    settingName = 'showMainStatisticsPanelGuild',
    valueFunc = function()
      local guildName = select(1, GetGuildInfo('player'))
      if guildName and guildName ~= '' then
        return '<' .. guildName .. '>'
      end
      return 'Guildless'
    end,
    defaultValue = '',
  }, {
    key = 'totalHP',
    label = 'Highest Health:',
    tooltipKey = 'totalHP',
    width = 1,
    settingName = 'showMainStatisticsPanelTotalHP',
    valueFunc = function()
      return UnitHealthMax('player') or 0
    end,
    defaultValue = 0,
  }, {
    key = 'maxResource',
    label = 'Highest Resource:',
    tooltipKey = 'totalResource',
    width = 1,
    settingName = 'showMainStatisticsPanelMaxResource',
    valueFunc = function()
      local _, powerType = GetPlayerPrimaryResourceLabelAndType()
      return UnitPowerMax('player', powerType or 0) or 0
    end,
    defaultValue = 0,
  } }
  CreateStatsGrid(characterInfoContent, characterStatsConfig, {
    defaultWidth = 1,
    rowHeight = 36,
  })

  -- Create Health Tracking section (Deaths)
  local healthTrackingHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  healthTrackingHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)

  healthTrackingHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  healthTrackingHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  healthTrackingHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local healthTrackingLabel =
    healthTrackingHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  healthTrackingLabel:SetPoint('LEFT', healthTrackingHeader, 'LEFT', 24, 0)
  healthTrackingLabel:SetText('Deaths')
  healthTrackingLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  healthTrackingLabel:SetShadowOffset(1, -1)
  healthTrackingLabel:SetShadowColor(0, 0, 0, 0.8)

  local healthTrackingContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  healthTrackingContent:SetSize(CONTENT_WIDTH, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, recalculated after grid layout
  healthTrackingContent:Show()
  local healthTrackingSection =
    addSection(healthTrackingHeader, healthTrackingContent, 'healthTracking', 'Deaths')
  makeHeaderClickable(
    healthTrackingHeader,
    healthTrackingContent,
    'healthTracking',
    healthTrackingSection
  )
  healthTrackingContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  healthTrackingContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  healthTrackingContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local healthStats = { {
    key = 'playerDeaths',
    label = 'Deaths (Total):',
    tooltipKey = 'playerDeaths',
    settingName = 'showMainStatisticsPanelPlayerDeaths',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'serverDeaths',
    label = 'Server Deaths:',
    tooltipKey = 'serverDeaths',
    settingName = 'showMainStatisticsPanelServerDeaths',
    valueFunc = function()
      return UltraStatisticsCharacterStats:GetServerDeaths()
    end,
    defaultValue = 0,
    width = 1,
  }, {
    key = 'playerDeathsOpenWorld',
    label = 'Deaths (Open World):',
    tooltipKey = 'playerDeathsOpenWorld',
    settingName = 'showMainStatisticsPanelPlayerDeathsOpenWorld',
    defaultValue = 0,
    width = 0.5,
  }, {
    key = 'playerDeathsBattleground',
    label = 'Deaths (Battleground):',
    tooltipKey = 'playerDeathsBattleground',
    settingName = 'showMainStatisticsPanelPlayerDeathsBattleground',
    defaultValue = 0,
    width = 0.5,
  }, {
    key = 'playerDeathsArena',
    label = 'Deaths (Arena):',
    tooltipKey = 'playerDeathsArena',
    settingName = 'showMainStatisticsPanelPlayerDeathsArena',
    defaultValue = 0,
    width = 0.5,
  } }
  CreateStatsGrid(healthTrackingContent, healthStats, { defaultWidth = 0.5 })

  -- Create Lowest Health section
  local lowestHealthHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  lowestHealthHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)
  lowestHealthHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  lowestHealthHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  lowestHealthHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local lowestHealthLabel =
    lowestHealthHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  lowestHealthLabel:SetPoint('LEFT', lowestHealthHeader, 'LEFT', 24, 0)
  lowestHealthLabel:SetText('Lowest Health')
  lowestHealthLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  lowestHealthLabel:SetShadowOffset(1, -1)
  lowestHealthLabel:SetShadowColor(0, 0, 0, 0.8)

  local lowestHealthContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  lowestHealthContent:SetSize(CONTENT_WIDTH, 3 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12)
  lowestHealthContent:Show()
  local lowestHealthSection = addSection(lowestHealthHeader, lowestHealthContent, 'lowestHealth', 'Lowest Health')
  makeHeaderClickable(lowestHealthHeader, lowestHealthContent, 'lowestHealth', lowestHealthSection)
  lowestHealthContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  lowestHealthContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  lowestHealthContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local lowestHealthStats = { {
    key = 'lowestHealth',
    label = 'Lowest Ever:',
    tooltipKey = 'lowestHealth',
    settingName = 'showMainStatisticsPanelLowestHealth',
    defaultValue = 100,
    width = 1,
  }, {
    key = 'lowestHealthThisLevel',
    label = 'Lowest This Level:',
    tooltipKey = 'lowestHealthThisLevel',
    settingName = 'showMainStatisticsPanelLowestHealthThisLevel',
    defaultValue = 100,
    width = 1,
  }, {
    key = 'lowestHealthThisSession',
    label = 'Lowest This Session:',
    tooltipKey = 'lowestHealthThisSession',
    settingName = 'showMainStatisticsPanelLowestHealthThisSession',
    defaultValue = 100,
    width = 1,
  } }
  CreateStatsGrid(lowestHealthContent, lowestHealthStats, { defaultWidth = 1 })

  -- Create modern WoW-style Combat section (collapsible)
  local combatHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  combatHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions

  -- Modern WoW row styling with rounded corners and greyish background
  combatHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  combatHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  combatHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local combatLabel = combatHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  combatLabel:SetPoint('LEFT', combatHeader, 'LEFT', 24, 0)
  combatLabel:SetText('Combat')
  combatLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  combatLabel:SetShadowOffset(1, -1)
  combatLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Combat breakdown
  local combatContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  combatContent:SetSize(CONTENT_WIDTH, 6 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, recalculated after grid layout
  -- Position will be set by updateSectionPositions
  combatContent:Show() -- Show by default
  -- Register section and make header clickable
  local combatSection = addSection(combatHeader, combatContent, 'combat', 'Combat')
  makeHeaderClickable(combatHeader, combatContent, 'combat', combatSection)
  combatLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  combatLabel:SetShadowOffset(1, -1)
  combatLabel:SetShadowColor(0, 0, 0, 0.8)
  -- Modern content frame styling
  combatContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  combatContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  combatContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local combatStats = { {
    key = 'enemiesSlain',
    label = 'Enemies Slain:',
    tooltipKey = 'enemiesSlainTotal',
    settingName = 'showMainStatisticsPanelEnemiesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'elitesSlain',
    label = 'Elites Slain:',
    tooltipKey = 'elitesSlain',
    settingName = 'showMainStatisticsPanelElitesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'rareElitesSlain',
    label = 'Rare Elites Slain:',
    tooltipKey = 'rareElitesSlain',
    settingName = 'showMainStatisticsPanelRareElitesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'worldBossesSlain',
    label = 'World Bosses Slain:',
    tooltipKey = 'worldBossesSlain',
    settingName = 'showMainStatisticsPanelWorldBossesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'dungeonBossesKilled',
    label = 'Dungeon Bosses Slain:',
    tooltipKey = 'dungeonBossesSlain',
    settingName = 'showMainStatisticsPanelDungeonBosses',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'dungeonsCompleted',
    label = 'Dungeons Completed:',
    tooltipKey = 'dungeonsCompleted',
    settingName = 'showMainStatisticsPanelDungeonsCompleted',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'highestCritValue',
    label = 'Highest Crit Value:',
    tooltipKey = 'highestCritValue',
    settingName = 'showMainStatisticsPanelHighestCritValue',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'highestHealCritValue',
    label = 'Highest Heal Crit Value:',
    tooltipKey = 'highestHealCritValue',
    settingName = 'showMainStatisticsPanelHighestHealCritValue',
    defaultValue = 0,
    width = 1,
  } }

  -- Only add pet deaths for pet classes (hunter and warlock)
  local _, playerClass = UnitClass('player')
  if playerClass == 'HUNTER' or playerClass == 'WARLOCK' then
    table.insert(combatStats, {
      key = 'petDeaths',
      label = 'Pet Deaths:',
      tooltipKey = 'petDeaths',
      settingName = 'showMainStatisticsPanelPetDeaths',
      defaultValue = 0,
      width = 1,
    })
  end

  CreateStatsGrid(combatContent, combatStats, { defaultWidth = 0.5 })

  -- Create modern WoW-style Survival section (collapsible)
  local survivalHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions
  -- Modern WoW row styling with rounded corners and greyish background
  survivalHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  survivalHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  survivalHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local survivalLabel = survivalHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  survivalLabel:SetPoint('LEFT', survivalHeader, 'LEFT', 24, 0)
  survivalLabel:SetText('Survival')
  survivalLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  survivalLabel:SetShadowOffset(1, -1)
  survivalLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Survival breakdown
  local survivalContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalContent:SetSize(CONTENT_WIDTH, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, will be corrected below
  -- Position will be set by updateSectionPositions
  survivalContent:Show() -- Always show
  -- Register section and make header clickable
  local survivalSection = addSection(survivalHeader, survivalContent, 'survival', 'Survival')
  makeHeaderClickable(survivalHeader, survivalContent, 'survival', survivalSection)
  -- Modern content frame styling
  survivalContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  survivalContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  survivalContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create survival statistics entries (items/consumables used)
  local survivalStats = { {
    key = 'closeEscapes',
    label = 'Close Escapes:',
    tooltipKey = 'closeEscapes',
    settingName = 'showMainStatisticsPanelCloseEscapes',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'healthPotionsUsed',
    label = 'Health Potions Used:',
    tooltipKey = 'healthPotionsUsed',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'manaPotionsUsed',
    label = 'Mana Potions Used:',
    tooltipKey = 'manaPotionsUsed',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'bandagesUsed',
    label = 'Bandages Applied:',
    tooltipKey = 'bandagesApplied',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'blocks',
    label = 'Blocks:',
    tooltipKey = 'blocks',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'parries',
    label = 'Parries:',
    tooltipKey = 'parries',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'dodges',
    label = 'Dodges:',
    tooltipKey = 'dodges',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'resists',
    label = 'Resists:',
    tooltipKey = 'resists',
    defaultValue = 0,
    width = 1,
  } }

  -- Only add Engineering-related stats if player has Engineering profession
  if HasEngineering() then
    table.insert(survivalStats, {
      key = 'targetDummiesUsed',
      label = 'Target Dummies Used:',
      tooltipKey = 'targetDummiesUsed',
      defaultValue = 0,
      width = 1,
    })
    table.insert(survivalStats, {
      key = 'grenadesUsed',
      label = 'Grenades Used:',
      tooltipKey = 'grenadesUsed',
      defaultValue = 0,
      width = 1,
    })
  end
  CreateStatsGrid(survivalContent, survivalStats, { defaultWidth = 0.5 })

  -- Social section (collapsible)
  local socialHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  socialHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)
  socialHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  socialHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  socialHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local socialLabel = socialHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  socialLabel:SetPoint('LEFT', socialHeader, 'LEFT', 24, 0)
  socialLabel:SetText('Social')
  socialLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  socialLabel:SetShadowOffset(1, -1)
  socialLabel:SetShadowColor(0, 0, 0, 0.8)

  local socialContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  socialContent:SetSize(CONTENT_WIDTH, LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12)
  socialContent:Show()
  local socialSection = addSection(socialHeader, socialContent, 'social', 'Social')
  makeHeaderClickable(socialHeader, socialContent, 'social', socialSection)
  socialContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  socialContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  socialContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local socialStats = { {
    key = 'partyMemberDeaths',
    label = 'Party Deaths Witnessed:',
    tooltipKey = 'partyDeathsWitnessed',
    settingName = 'showMainStatisticsPanelPartyMemberDeaths',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(socialContent, socialStats, { defaultWidth = 0.5 })

  -- Create PvP section (duel stats)
  local pvpHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  pvpHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)
  pvpHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  pvpHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  pvpHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local pvpLabel = pvpHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  pvpLabel:SetPoint('LEFT', pvpHeader, 'LEFT', 24, 0)
  pvpLabel:SetText('PvP')
  pvpLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  pvpLabel:SetShadowOffset(1, -1)
  pvpLabel:SetShadowColor(0, 0, 0, 0.8)

  local pvpContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  pvpContent:SetSize(CONTENT_WIDTH, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12)
  pvpContent:Show()
  local pvpSection = addSection(pvpHeader, pvpContent, 'pvp', 'PvP')
  makeHeaderClickable(pvpHeader, pvpContent, 'pvp', pvpSection)
  pvpContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  pvpContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  pvpContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local pvpStats = { {
    key = 'playerKills',
    label = 'Player Kills:',
    tooltipKey = 'playerKills',
    settingName = 'showMainStatisticsPanelPlayerKills',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsTotal',
    label = 'Duels Total:',
    tooltipKey = 'duelsTotal',
    settingName = 'showMainStatisticsPanelDuelsTotal',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsWon',
    label = 'Duels Won:',
    tooltipKey = 'duelsWon',
    settingName = 'showMainStatisticsPanelDuelsWon',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsLost',
    label = 'Duels Lost:',
    tooltipKey = 'duelsLost',
    settingName = 'showMainStatisticsPanelDuelsLost',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsWinPercent',
    label = 'Duel Win Percent:',
    tooltipKey = 'duelsWinPercent',
    settingName = 'showMainStatisticsPanelDuelsWinPercent',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(pvpContent, pvpStats, { defaultWidth = 0.5 })

  -- Create modern WoW-style Misc section (collapsible)
  local miscHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  miscHeader:SetSize(SECTION_WIDTH, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions
  -- Modern WoW row styling with rounded corners and greyish background
  miscHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  miscHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  miscHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local miscLabel = miscHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  miscLabel:SetPoint('LEFT', miscHeader, 'LEFT', 24, 0)
  miscLabel:SetText('Misc')
  miscLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  miscLabel:SetShadowOffset(1, -1)
  miscLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Misc breakdown
  local miscContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  miscContent:SetSize(CONTENT_WIDTH, 2 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- 4 stats in 2-column grid
  -- Position will be set by updateSectionPositions
  miscContent:Show()

  -- Register section and make header clickable
  local miscSection = addSection(miscHeader, miscContent, 'misc', 'Misc')
  makeHeaderClickable(miscHeader, miscContent, 'misc', miscSection)
  -- Modern content frame styling
  miscContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  miscContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  miscContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create misc statistics display inside the content frame
  local miscStats = { {
    key = 'playerJumps',
    label = 'Jumps Performed:',
    tooltipKey = 'playerJumps',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'goldGained',
    label = 'Gold Gained:',
    tooltipKey = 'goldGained',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'goldSpent',
    label = 'Gold Spent:',
    tooltipKey = 'goldSpent',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(miscContent, miscStats, { defaultWidth = 0.5 })

  -- Network section removed in UltraStatistics

  -- Settings XP Gain Verification section removed in UltraStatistics

  -- Set initial positioning after all statistics are created
  syncStatsContentWidths()
  updateSectionPositions()
  statsScrollFrame:SetScript('OnSizeChanged', function()
    syncStatsContentWidths()
    updateSectionPositions()
  end)

  local function IsStatsSearchMatch(searchBlob, query)
    if not query or query == '' then
      return true
    end
    if not searchBlob then
      return false
    end
    return string.find(searchBlob, query, 1, true) ~= nil
  end

  local function applySearchFilter(query)
    local q = string.lower(query or '')
    for _, section in ipairs(sections) do
      local rows = section.content and section.content._statRows or {}
      local sectionBlob = string.lower(section.title or section.name or '')
      local visibleCount = 0

      if q == '' then
        for _, row in ipairs(rows) do
          row.visible = true
        end
        if #rows > 0 then
          RelayoutStatRows(section.content, rows, section.content._statGridOptions)
        end
        section.hiddenBySearch = false
        local saved = ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections and ULTRA_STATISTICS_GLOBAL_SETTINGS.collapsedStatsSections[section.name]
        if section.SetCollapsed then
          section.SetCollapsed(saved and true or false, { skipSave = true, skipLayout = true })
        else
          section.collapsed = saved and true or false
        end
      else
        local sectionTitleMatch = IsStatsSearchMatch(sectionBlob, q)
        for _, row in ipairs(rows) do
          local match = sectionTitleMatch or IsStatsSearchMatch(row.searchBlob, q)
          row.visible = match
          if match then
            visibleCount = visibleCount + 1
          end
        end
        if #rows > 0 then
          RelayoutStatRows(section.content, rows, section.content._statGridOptions)
        elseif sectionTitleMatch then
          visibleCount = 1
        end
        section.hiddenBySearch = visibleCount == 0
        if not section.hiddenBySearch and section.SetCollapsed then
          section.SetCollapsed(false, { skipSave = true, skipLayout = true })
        end
      end
    end
    updateSectionPositions()
  end

  clearSearchButton:SetScript('OnClick', function()
    searchBox:SetText('')
    searchBox:ClearFocus()
    searchPlaceholder:Show()
    applySearchFilter('')
  end)

  collapseAllButton:SetScript('OnClick', function()
    for _, section in ipairs(sections) do
      if not section.hiddenBySearch and section.SetCollapsed then
        section.SetCollapsed(true, { skipLayout = true })
      end
    end
    updateSectionPositions()
  end)

  expandAllButton:SetScript('OnClick', function()
    for _, section in ipairs(sections) do
      if not section.hiddenBySearch and section.SetCollapsed then
        section.SetCollapsed(false, { skipLayout = true })
      end
    end
    updateSectionPositions()
  end)

  searchBox:SetScript('OnTextChanged', function(self)
    local txt = self:GetText() or ''
    if txt == '' then
      searchPlaceholder:Show()
    else
      searchPlaceholder:Hide()
    end
    applySearchFilter(txt)
  end)
  searchBox:SetScript('OnEditFocusGained', function()
    if (searchBox:GetText() or '') == '' then
      searchPlaceholder:Hide()
    end
  end)
  searchBox:SetScript('OnEditFocusLost', function()
    if (searchBox:GetText() or '') == '' then
      searchPlaceholder:Show()
    end
  end)
  searchBox:SetScript('OnEscapePressed', function(self)
    self:SetText('')
    self:ClearFocus()
    searchPlaceholder:Show()
    applySearchFilter('')
  end)

  -- Update the lowest health display
  local function UpdateLowestHealthDisplay()
    if not UltraStatisticsDB then return end

    UpdateStatBar('level', UnitLevel('player') or 1)
    do
      local guildName = select(1, GetGuildInfo('player'))
      local gText = (guildName and guildName ~= '') and ('<' .. guildName .. '>') or 'Guildless'
      UpdateStatBar('guild', gText)
    end
    -- Max Health / Max Resource: show max *ever*, only update stored when current is higher
    local currentMaxHealth = UnitHealthMax('player') or 0
    local maxHealthEver = UltraStatisticsCharacterStats:GetStat('maxHealthEver') or 0
    if currentMaxHealth > maxHealthEver then
      UltraStatisticsCharacterStats:UpdateStat('maxHealthEver', currentMaxHealth)
      maxHealthEver = currentMaxHealth
    end
    UpdateStatBar('totalHP', maxHealthEver)
    local resourceLabel, powerType = GetPlayerPrimaryResourceLabelAndType()
    if statLabels.maxResource then
      statLabels.maxResource:SetText('Highest ' .. (resourceLabel or 'Resource') .. ':')
    end
    local currentMaxResource = UnitPowerMax('player', powerType or 0) or 0
    local maxResourceEver = UltraStatisticsCharacterStats:GetStat('maxResourceEver') or 0
    if currentMaxResource > maxResourceEver then
      UltraStatisticsCharacterStats:UpdateStat('maxResourceEver', currentMaxResource)
      maxResourceEver = currentMaxResource
    end
    UpdateStatBar('maxResource', maxResourceEver)

    -- Only update pet deaths for pet classes (hunter and warlock)
    local _, playerClass = UnitClass('player')
    if playerClass == 'HUNTER' or playerClass == 'WARLOCK' then
      UpdateStatBar('petDeaths', UltraStatisticsCharacterStats:GetStat('petDeaths') or 0)
    end
    UpdateStatBar('closeEscapes', UltraStatisticsCharacterStats:GetStat('closeEscapes') or 0)
    UpdateStatBar('playerDeaths', UltraStatisticsCharacterStats:GetStat('playerDeaths') or 0)
    UpdateStatBar('serverDeaths', UltraStatisticsCharacterStats:GetServerDeaths())
    UpdateStatBar('playerDeathsOpenWorld', UltraStatisticsCharacterStats:GetStat('playerDeathsOpenWorld') or 0)
    UpdateStatBar(
      'playerDeathsBattleground',
      UltraStatisticsCharacterStats:GetStat('playerDeathsBattleground') or 0
    )
    UpdateStatBar('playerDeathsArena', UltraStatisticsCharacterStats:GetStat('playerDeathsArena') or 0)
    UpdateStatBar('lowestHealth', UltraStatisticsCharacterStats:GetStat('lowestHealth') or 100)
    UpdateStatBar('lowestHealthThisLevel', UltraStatisticsCharacterStats:GetStat('lowestHealthThisLevel') or 100)
    UpdateStatBar(
      'lowestHealthThisSession',
      UltraStatisticsCharacterStats:GetStat('lowestHealthThisSession') or 100
    )
    UpdateStatBar('blocks', UltraStatisticsCharacterStats:GetStat('blocks') or 0)
    UpdateStatBar('parries', UltraStatisticsCharacterStats:GetStat('parries') or 0)
    UpdateStatBar('dodges', UltraStatisticsCharacterStats:GetStat('dodges') or 0)
    UpdateStatBar('resists', UltraStatisticsCharacterStats:GetStat('resists') or 0)

    UpdateStatBar('elitesSlain', UltraStatisticsCharacterStats:GetStat('elitesSlain') or 0)
    UpdateStatBar('rareElitesSlain', UltraStatisticsCharacterStats:GetStat('rareElitesSlain') or 0)
    UpdateStatBar('worldBossesSlain', UltraStatisticsCharacterStats:GetStat('worldBossesSlain') or 0)
    UpdateStatBar('dungeonBossesKilled', UltraStatisticsCharacterStats:GetStat('dungeonBossesKilled') or 0)
    UpdateStatBar('dungeonsCompleted', UltraStatisticsCharacterStats:GetStat('dungeonsCompleted') or 0)
    UpdateStatBar('enemiesSlain', UltraStatisticsCharacterStats:GetStat('enemiesSlain') or 0)

    UpdateStatBar('highestCritValue', UltraStatisticsCharacterStats:GetStat('highestCritValue') or 0)
    UpdateStatBar('highestHealCritValue', UltraStatisticsCharacterStats:GetStat('highestHealCritValue') or 0)

    for _, stat in ipairs(survivalStats) do
      UpdateStatBar(stat.key, UltraStatisticsCharacterStats:GetStat(stat.key) or 0)
    end

    for _, stat in ipairs(socialStats) do
      UpdateStatBar(stat.key, UltraStatisticsCharacterStats:GetStat(stat.key) or 0)
    end

    for _, stat in ipairs(pvpStats) do
      UpdateStatBar(stat.key, UltraStatisticsCharacterStats:GetStat(stat.key) or 0)
    end

    for _, stat in ipairs(miscStats) do
      UpdateStatBar(stat.key, UltraStatisticsCharacterStats:GetStat(stat.key) or 0)
    end
  end

  -- Keep Total HP/Mana values current when stats change outside the panel
  resourceEventFrame = CreateFrame('Frame')
  resourceEventFrame:RegisterEvent('PLAYER_LEVEL_UP')
  resourceEventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
  resourceEventFrame:RegisterEvent('UNIT_MAXHEALTH')
  resourceEventFrame:RegisterEvent('UNIT_MAXPOWER')
  resourceEventFrame:SetScript('OnEvent', function(_, event, unit)
    if (event == 'UNIT_MAXHEALTH' or event == 'UNIT_MAXPOWER') and unit ~= 'player' then return end
    if UpdateLowestHealthDisplay then
      UpdateLowestHealthDisplay()
    end
  end)

  -- Import from Ultra button (far right)
  local importButton = CreateFrame('Button', nil, tabContents[1], 'UIPanelButtonTemplate')
  importButton:SetSize(140, 30)
  importButton:SetPoint('BOTTOMRIGHT', tabContents[1], 'BOTTOMRIGHT', -10, -30)
  importButton:SetText('Import from Ultra')
  importButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(importButton, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Import higher stats from the Ultra addon if you have it installed.')
    GameTooltip:Show()
  end)
  importButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  importButton:SetScript('OnClick', function()
    if _G.ShowImportFromUltraDialog then
      _G.ShowImportFromUltraDialog()
    else
      print('ULTRA STATISTICS - Import not available. Reload UI.')
    end
  end)

  -- Export functions for use by Settings.lua
  _G.UpdateLowestHealthDisplay = UpdateLowestHealthDisplay
end
