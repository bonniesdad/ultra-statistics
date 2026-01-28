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
  totalHP = 'Your maximum health with current gear and buffs',
  totalResource = 'Your maximum primary resource (mana/rage/energy/etc.) with current gear and buffs',
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
  partyDeathsWitnessed = 'Number of party member deaths you have witnessed',
  healthPotionsUsed = 'Number of health potions you have consumed',
  manaPotionsUsed = 'Number of mana potions you have consumed',
  bandagesApplied = 'Number of bandages you have used to heal',
  targetDummiesUsed = 'Number of target dummies you have used',
  grenadesUsed = 'Number of grenades you have thrown',
  playerDeaths = 'Total number of times your character has died',
  playerDeathsOpenWorld = 'Number of times your character has died in the open world (not in an instance)',
  playerDeathsBattleground = 'Number of times your character has died in a battleground',
  playerDeathsDungeon = 'Number of times your character has died in a dungeon (5-man instance)',
  playerDeathsRaid = 'Number of times your character has died in a raid instance',
  playerDeathsArena = 'Number of times your character has died in an arena match',
  blocks = 'Number of times you blocked an incoming attack',
  parries = 'Number of times you parried an incoming attack',
  dodges = 'Number of times you dodged an incoming attack',
  resists = 'Number of times you fully resisted a spell attack',
  duelsTotal = 'Total number of duels you have done',
  duelsWon = 'Number of duels you have won',
  duelsLost = 'Number of duels you have lost',
  duelsWinPercent = 'Percentage of duels you have won',
  -- Misc section
  playerJumps = 'Number of jumps you have performed.  Work that jump key!',
  player360s = 'Number of times you did a full 360 spin during a jump',
  -- Economy section
  goldGained = 'Total money gained (copper). Tracked via PLAYER_MONEY deltas.',
  goldSpent = 'Total money spent (copper). Tracked via PLAYER_MONEY deltas.',
  -- Network section
  -- (removed in UltraStatistics)
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
local TIER_LEFT_PADDING = 16 -- extra gap from bar start
local BAR_ROW_HEIGHT_REDUCTION = 30 -- shrink bar rows vertically
local DEFAULT_BAR_ROW_HEIGHT =
  math.max(STAT_BAR_HEIGHT + 4, (LAYOUT.ROW_HEIGHT * 2) - BAR_ROW_HEIGHT_REDUCTION)
local SECTION_CONTENT_BOTTOM_PADDING = 12 -- gap between last row and frame edge
local SECTION_BOTTOM_PADDING = 30 -- add breathing room below each section
local STAT_TIER_ICON_SIZE = 14
local STAT_TIER_ICON_GAP = 12
-- Death stats do not show an icon next to the toast button
local STATS_WITHOUT_TOAST_ICON = {
  level = true, -- no dedicated icon
  playerDeaths = true,
  playerDeathsOpenWorld = true,
  playerDeathsBattleground = true,
  playerDeathsDungeon = true,
  playerDeathsRaid = true,
  playerDeathsArena = true,
  petDeaths = true,
  partyMemberDeaths = true,
  totalHP = true, -- no dedicated icon
  maxResource = true, -- no dedicated icon
}

-- Some stats share the same icon art; map new keys to existing textures to avoid requiring new PNGs.
local ICON_KEY_OVERRIDES = {
  playerDeathsOpenWorld = 'playerDeaths',
  playerDeathsBattleground = 'playerDeaths',
  playerDeathsDungeon = 'playerDeaths',
  playerDeathsRaid = 'playerDeaths',
  playerDeathsArena = 'playerDeaths',
}

local function ResolveStatIconKey(statKey)
  if not statKey then
    return statKey
  end
  return ICON_KEY_OVERRIDES[statKey] or statKey
end
-- Fill colors progress from calm/neutral to impressive across tiers
local TIER_COLORS = {
  { 0.78, 0.49, 0.20, 0.95 }, -- tier 1: bronze
  { 0.78, 0.78, 0.82, 0.95 }, -- tier 2: silver
  { 0.95, 0.80, 0.22, 0.95 }, -- tier 3: gold
  { 0.62, 0.36, 0.90, 0.95 }, -- tier 4: master (purple)
  { 0.90, 0.25, 0.25, 0.95 }, -- tier 5+: demon (red)
}

-- Tier name mapping
local TIER_NAMES = {
  [1] = 'Bronze',
  [2] = 'Silver',
  [3] = 'Gold',
  [4] = 'Master',
  [5] = 'Demon',
}

-- Expose tier names for other UI modules (e.g. StatisticsTrackingToast)
_G.ULTRA_TIER_NAMES = TIER_NAMES
-- Expose tier colors for other UI modules (e.g. StatisticsTrackingToast)
_G.ULTRA_TIER_COLORS = TIER_COLORS

-- Level bar color steps (blue -> red as you near cap)
local LEVEL_COLOR_STEPS = {
  { 0.25, 0.65, 0.9, 0.95 }, -- blue
  { 0.3, 0.75, 0.75, 0.95 }, -- teal
  { 0.35, 0.8, 0.55, 0.95 }, -- green-teal
  { 0.8, 0.75, 0.35, 0.95 }, -- yellow-gold
  { 0.9, 0.55, 0.25, 0.95 }, -- orange
  { 0.9, 0.25, 0.25, 0.95 }, -- red
}

local STAT_BAR_CONFIG = {
  default = {
    base = 100,
    multiplier = 2,
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
  -- Numeric stats with individualized tier settings (all inherit default base/multiplier unless overridden)
  level = {
    max = 60, -- classic cap
    valueOnly = true,
    noTier = true,
  },
  totalHP = {
    valueOnly = true,
    noTier = true,
  },
  maxResource = {
    valueOnly = true,
    noTier = true,
  },
  closeEscapes = {
    base = 1,
    multiplier = 3,
    valueOnly = true,
  },
  petDeaths = {
    valueOnly = true,
    noTier = true,
  },
  enemiesSlain = {
    base = 1000,
    multiplier = 3,
    valueOnly = true,
  },
  elitesSlain = {
    base = 200,
    multiplier = 3,
    valueOnly = true,
  },
  rareElitesSlain = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  worldBossesSlain = {
    base = 10,
    multiplier = 2,
    valueOnly = true,
  },
  dungeonBossesKilled = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  dungeonsCompleted = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  highestCritValue = {
    base = 500,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  highestHealCritValue = {
    base = 500,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  healthPotionsUsed = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  manaPotionsUsed = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  bandagesUsed = {
    base = 50,
    multiplier = 2,
    valueOnly = true,
  },
  targetDummiesUsed = {
    base = 20,
    multiplier = 2,
    valueOnly = true,
  },
  grenadesUsed = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  partyMemberDeaths = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerDeaths = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerDeathsOpenWorld = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerDeathsBattleground = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerDeathsDungeon = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerDeathsRaid = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerDeathsArena = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  blocks = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  parries = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  dodges = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  resists = {
    base = 1,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  duelsTotal = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  duelsWon = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  duelsLost = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerJumps = {
    base = 10000,
    multiplier = 3,
    valueOnly = true,
  },
  player360s = {
    base = 1000,
    multiplier = 3,
    valueOnly = true,
  },
  goldGained = {
    type = 'money',
    base = 100000, -- 10g
    multiplier = 2,
    valueOnly = true,
  },
  goldSpent = {
    type = 'money',
    base = 100000, -- 10g
    multiplier = 2,
    valueOnly = true,
  },
  -- lagHome / lagWorld removed in UltraStatistics
}

-- Expose to other modules (e.g. StatisticsTrackingToast) without having to duplicate tier config.
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

  -- Dedicated container to force highest z-order for tier text/background
  local tierContainer = CreateFrame('Frame', nil, barFrame)
  tierContainer:SetFrameLevel(barFrame:GetFrameLevel() + 20)

  local tierText = tierContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  tierText:SetPoint('TOPRIGHT', barFrame, 'TOPRIGHT', -30, 9)
  tierText:SetDrawLayer('OVERLAY', 50) -- keep above any pill/bg/fill
  tierText:SetTextColor(1, 1, 1, 1) -- bright white for readability
  local tierIcon = tierContainer:CreateTexture(nil, 'OVERLAY')
  tierIcon:SetSize(STAT_TIER_ICON_SIZE, STAT_TIER_ICON_SIZE)
  tierIcon:SetPoint('LEFT', tierText, 'RIGHT', STAT_TIER_ICON_GAP, 0)
  tierIcon:Hide()

  -- Toast button for non-tier stats (when showStatisticsTracking is enabled)
  local toastButton = tierContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  toastButton:SetPoint('TOPRIGHT', barFrame, 'TOPRIGHT', -30, 9)
  toastButton:SetDrawLayer('OVERLAY', 50)
  toastButton:SetText('Toast')
  toastButton:SetTextColor(0.7, 0.7, 0.7, 1)
  toastButton:Hide()

  -- Pill-style backdrop behind tier text
  local tierBg = CreateFrame('Frame', nil, tierContainer, 'BackdropTemplate')
  tierBg:SetFrameLevel(tierContainer:GetFrameLevel() - 1)
  tierBg:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 2,
      bottom = 2,
    },
  })
  tierBg:SetBackdropColor(0, 0, 0, 0.35)
  tierBg:SetBackdropBorderColor(0, 0, 0, 0.5)
  tierBg:Hide()

  -- Store tier range and name for tooltip directly on tierText
  tierText.tierMin = 0
  tierText.tierMax = 0
  tierText.tierCurrent = 0
  tierText.tierName = ''

  -- Add tooltip and click handler to tier text
  tierText:SetScript('OnEnter', function(self)
    local tooltipLines = {}

    -- Add tier info if available
    local currentValue = (self.tierCurrent ~= nil) and self.tierCurrent or self.tierMin
    if currentValue ~= nil and self.tierMax ~= nil and self.tierName ~= '' then
      table.insert(
        tooltipLines,
        string.format(
          '%s tier (%s/%s)',
          self.tierName,
          formatNumberWithCommas(currentValue),
          formatNumberWithCommas(self.tierMax)
        )
      )
    end

    -- Add toast toggle info if statKey is available
    if self.statKey then
      local showStatisticsTracking = GLOBAL_SETTINGS and GLOBAL_SETTINGS.showStatisticsTracking
      if showStatisticsTracking then
        local toastEnabled =
          GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] ~= false
        table.insert(tooltipLines, '')
        table.insert(
          tooltipLines,
          toastEnabled and 'Click to disable toast notifications' or 'Click to enable toast notifications'
        )
      else
        table.insert(tooltipLines, '')
        table.insert(tooltipLines, 'Statistics notifications are disabled')
      end
    end

    if #tooltipLines > 0 then
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
      for i, line in ipairs(tooltipLines) do
        if i == 1 then
          GameTooltip:SetText(line, nil, nil, nil, nil, true)
        else
          GameTooltip:AddLine(line, nil, nil, nil, true)
        end
      end
      GameTooltip:Show()
    end
  end)

  tierText:SetScript('OnLeave', function(self)
    GameTooltip:Hide()
  end)

  -- Make tier text clickable to toggle toast notifications
  tierText:EnableMouse(true)
  tierText:SetScript('OnMouseDown', function(self, button)
    if button == 'LeftButton' and self.statKey then
      -- Don't allow toggling if showStatisticsTracking is disabled
      if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showStatisticsTracking then return end

      if not GLOBAL_SETTINGS.statisticsToastEnabled then
        GLOBAL_SETTINGS.statisticsToastEnabled = {}
      end
      local current = GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey]
      GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] = not (current ~= false)

      -- Update visual state immediately
      local enabled = GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] ~= false
      local r, g, b = self:GetTextColor()
      if enabled then
        -- Restore original tier color (will be set by UpdateStatBar)
        -- For now, just ensure it's not grey
        if r == 0.5 and g == 0.5 and b == 0.5 then
          self:SetTextColor(1, 1, 1, 1)
        end
      else
        -- Grey out when disabled
        self:SetTextColor(0.5, 0.5, 0.5, 1)
      end

      -- Refresh the stat bar to update colors properly
      if UpdateStatBar and self.statKey then
        local value = CharacterStats:GetStat(self.statKey) or 0
        UpdateStatBar(self.statKey, value)
      end
    end
  end)

  -- Add tooltip and click handler to toast button
  toastButton:SetScript('OnEnter', function(self)
    if self.statKey then
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
      local showStatisticsTracking = GLOBAL_SETTINGS and GLOBAL_SETTINGS.showStatisticsTracking
      if showStatisticsTracking then
        local toastEnabled =
          GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] ~= false
        GameTooltip:SetText(
          toastEnabled and 'Click to disable toast notifications' or 'Click to enable toast notifications',
          nil,
          nil,
          nil,
          nil,
          true
        )
      else
        GameTooltip:SetText('Statistics notifications are disabled', nil, nil, nil, nil, true)
      end
      GameTooltip:Show()
    end
  end)

  toastButton:SetScript('OnLeave', function(self)
    GameTooltip:Hide()
  end)

  -- Make toast button clickable to toggle toast notifications
  toastButton:EnableMouse(true)
  toastButton:SetScript('OnMouseDown', function(self, button)
    if button == 'LeftButton' and self.statKey then
      -- Don't allow toggling if showStatisticsTracking is disabled
      if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showStatisticsTracking then return end

      if not GLOBAL_SETTINGS.statisticsToastEnabled then
        GLOBAL_SETTINGS.statisticsToastEnabled = {}
      end
      local current = GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey]
      GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] = not (current ~= false)

      -- Update visual state immediately
      local enabled = GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] ~= false
      if enabled then
        self:SetTextColor(0.7, 0.7, 0.7, 1)
      else
        self:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when disabled
      end
    end
  end)

  return {
    frame = barFrame,
    fill = fill,
    text = text,
    tier = tierText,
    tierIcon = tierIcon,
    tierBg = tierBg,
    tierContainer = tierContainer,
    bg = bg,
    toastButton = toastButton,
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

  -- Store statKey on tier text for toast toggle functionality
  bar.tier.statKey = statKey

  -- Store statKey on toast button for toast toggle functionality
  if bar.toastButton then
    bar.toastButton.statKey = statKey
  end

  -- Initialize toast settings if needed (default: all enabled)
  if not GLOBAL_SETTINGS.statisticsToastEnabled then
    GLOBAL_SETTINGS.statisticsToastEnabled = {}
  end
  if GLOBAL_SETTINGS.statisticsToastEnabled[statKey] == nil then
    GLOBAL_SETTINGS.statisticsToastEnabled[statKey] = true
  end

  bar.tier:ClearAllPoints()
  bar.tier:SetPoint('TOPRIGHT', bar.frame, 'TOPRIGHT', -30, 9)

  bar.minText:SetPoint('BOTTOMLEFT', bar.frame, 'TOPLEFT', 0, 4)
  -- Show the max value inside the bar on the right
  bar.maxText:ClearAllPoints()
  bar.maxText:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 0)
  bar.maxText:SetJustifyH('RIGHT')
  bar.maxText:SetDrawLayer('OVERLAY', 10) -- ensure it sits above fills/frames
  -- Match styling to the centered current value
  local r, g, b, a = bar.text:GetTextColor()
  local sr, sg, sb, sa = bar.text:GetShadowColor()
  local sx, sy = bar.text:GetShadowOffset()
  local font, fontSize, fontFlags = bar.text:GetFont()
  if font then
    bar.maxText:SetFont(font, fontSize, fontFlags)
  end
  local fontObj = bar.text:GetFontObject()
  if fontObj then
    bar.maxText:SetFontObject(fontObj)
  end
  bar.maxText:SetTextColor(r, g, b, a)
  if sr and sg and sb and sa then
    bar.maxText:SetShadowColor(sr, sg, sb, sa)
  end
  if sx and sy then
    bar.maxText:SetShadowOffset(sx, sy)
  end

  if not isLast then
    local divider = parent:CreateTexture(nil, 'ARTWORK')
    divider:SetColorTexture(0.25, 0.25, 0.3, 0.65)
    divider:SetHeight(1) -- fill more space below (reduce post-divider gap by ~30px)
    divider:SetPoint('TOP', bar.frame, 'BOTTOM', 0, -14) -- add 10px more gap above divider
    divider:SetPoint('LEFT', parent, 'LEFT', LAYOUT.ROW_INDENT + 5, 0)
    divider:SetPoint('RIGHT', parent, 'RIGHT', -LAYOUT.ROW_INDENT - 5, 0)
    bar.divider = divider
  end

  statBars[statKey] = bar
  if bar.tierIcon and statKey then
    local iconKey = ResolveStatIconKey(statKey)
    bar.tierIcon:SetTexture(
      'Interface\\AddOns\\UltraStatistics\\Textures\\stats-icons\\' .. iconKey .. '.png'
    )
  end
  PositionStatBar(bar, parent, yOffset, layoutOptions)
  return bar
end

local TWO_COLUMN_GAP = 24
local LABEL_BAR_OFFSET = (LAYOUT.ROW_INDENT + 12) - (LAYOUT.ROW_INDENT + STAT_BAR_INSET)

local function AttachSettingCheckbox(radio, settingName)
  if not radio or not settingName then return end
  local checked = false
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS[settingName] ~= nil then
    checked = GLOBAL_SETTINGS[settingName] and true or false
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
    if GLOBAL_SETTINGS then
      GLOBAL_SETTINGS[settingName] = v
    end
    if UltraStatsFrame and UltraStatsFrame.UpdateRowVisibility then
      UltraStatsFrame.UpdateRowVisibility()
    end
  end)
end

local function CreateStatsGrid(parent, statsList, options)
  if not parent or not statsList or #statsList == 0 then
    return 0
  end

  local opts = options or {}
  local defaultWidth = opts.defaultWidth or 0.5
  local columnGap = opts.columnGap or TWO_COLUMN_GAP
  local rowHeight = opts.rowHeight or DEFAULT_BAR_ROW_HEIGHT
  local baseYOffset = opts.baseYOffset or -LAYOUT.CONTENT_PADDING
  local parentWidth = parent:GetWidth()
  if not parentWidth or parentWidth == 0 then
    parentWidth = opts.fallbackWidth or 415
  end
  local barLeftBase = LAYOUT.ROW_INDENT + STAT_BAR_INSET
  local fullBarWidth = math.max(0, parentWidth - barLeftBase * 2)
  local halfBarWidth = (fullBarWidth - columnGap) / 2
  if halfBarWidth < 0 then
    halfBarWidth = fullBarWidth / 2
    columnGap = 0
  end

  local rowCount = 0
  local nextColumn = 0
  local accumulatedHeight = 0
  local pendingRowHeight = 0
  local pendingRowYOffset = baseYOffset
  local valueOnlyRowHeight = opts.valueOnlyRowHeight or (STAT_BAR_HEIGHT + 4)

  for _, stat in ipairs(statsList) do
    local statKey = stat.key
    if statKey then
      local width = stat.width or defaultWidth
      local cfg = STAT_BAR_CONFIG[statKey]
      if cfg and cfg.valueOnly and width < 1 then
        width = 1
      end
      local isValueOnly = cfg and cfg.valueOnly
      local rowHeightForStat = isValueOnly and valueOnlyRowHeight or rowHeight
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
        rowCount = rowCount + 1
        columnIndex = 0
        yOffset = baseYOffset - accumulatedHeight
        accumulatedHeight = accumulatedHeight + rowHeightForStat
      else
        if nextColumn == 0 then
          rowCount = rowCount + 1
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
      local label = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      label:SetPoint('TOPLEFT', parent, 'TOPLEFT', labelLeft, yOffset + ROW_Y_ADJUST)
      label:SetText(stat.label or statKey)
      statLabels[statKey] = label
      if stat.tooltipKey then
        AddStatisticTooltip(label, stat.tooltipKey)
      end

      local bar = CreateBarRow(parent, statKey, yOffset, true, {
        left = columnLeft,
        width = barWidth,
      })

      local value
      if stat.valueFunc then
        value = stat.valueFunc()
      else
        value = CharacterStats:GetStat(statKey)
      end
      if value == nil and stat.defaultValue ~= nil then
        value = stat.defaultValue
      end
      UpdateStatBar(statKey, value)

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
          local radio = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
          radio:SetPoint('RIGHT', label, 'LEFT', -4, 0)
          radio:SetScale(0.7)
          AttachSettingCheckbox(radio, settingName)
        end
      end
    end
  end

  if nextColumn == 1 then
    accumulatedHeight = accumulatedHeight + pendingRowHeight
  end

  local totalHeight = math.max(rowHeight, accumulatedHeight + LAYOUT.CONTENT_PADDING * 2 - 12)
  parent:SetHeight(totalHeight + SECTION_CONTENT_BOTTOM_PADDING)
  return rowCount
end

local function CalculateTierProgress(value, base, multiplier)
  local currentValue = math.max(0, value or 0)
  base = tonumber(base) or 0
  multiplier = tonumber(multiplier) or 0

  -- Robust handling:
  -- - For multiplier <= 1 (or invalid), use linear tiers: tierMax = base * tier
  --   This avoids infinite loops and still allows "tier ups" to exist.
  if base <= 0 then
    return 1, 0, 0, 0
  end
  if multiplier <= 1 then
    local tier = math.floor(currentValue / base) + 1
    local tierMin = (tier - 1) * base
    local tierMax = tier * base
    local range = tierMax - tierMin
    local progress = range > 0 and (currentValue - tierMin) / range or 0
    return tier, tierMin, tierMax, math.min(math.max(progress, 0), 1)
  end

  local tier = 1
  local tierMax = base

  -- Inclusive boundary: hitting the max of a tier counts as entering the next tier.
  while currentValue >= tierMax do
    tier = tier + 1
    tierMax = tierMax * multiplier
  end

  local tierMin = tier == 1 and 0 or (tierMax / multiplier)
  local range = tierMax - tierMin
  local progress = range > 0 and (currentValue - tierMin) / range or 0

  return tier, tierMin, tierMax, math.min(math.max(progress, 0), 1)
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

  local showTiers = not GLOBAL_SETTINGS or GLOBAL_SETTINGS.showTiers ~= false
  local showNotifications = GLOBAL_SETTINGS and GLOBAL_SETTINGS.showStatisticsTracking

  local cfg = STAT_BAR_CONFIG[statKey] or STAT_BAR_CONFIG.default
  local valueOnly = cfg.valueOnly
  local fillColor = cfg.color or STAT_BAR_CONFIG.default.color
  local bgColor = cfg.bgColor or STAT_BAR_CONFIG.default.bgColor
  local effectiveFillColor = fillColor

  if valueOnly then
    -- Value-only mode: simple label + value (no bar visuals)
    if bar.bg then
      bar.bg:Hide()
    end
    if bar.fill then
      bar.fill:Hide()
    end
    local rawValue = value or 0
    local isZero = rawValue == 0
    local displayText
    local textColor = fillColor or { 1, 1, 1, 1 }
    if cfg.type == 'percent' then
      local pctMax = cfg.max or 100
      local percent = math.max(0, math.min(value or 0, pctMax))
      displayText = isZero and '-' or string.format('%.1f%%', percent)
      -- Hide tier for percent stats
      if bar.tier then
        bar.tier:SetText('')
        bar.tier:Hide()
      end
      if bar.tierBg then
        bar.tierBg:Hide()
      end
      if bar.tierIcon then
        bar.tierIcon:Hide()
      end
      -- Don't hide toast button here - it will be handled in the toast button section below
    else
      if cfg.type == 'money' then
        displayText = isZero and '-' or FormatMoneyText(rawValue)
      else
        local suffix = cfg.suffix or ''
        displayText = isZero and '-' or (formatNumberWithCommas(rawValue) .. suffix)
      end

      -- Calculate and show tier for non-percent valueOnly stats (unless noTier is set), or use white when Show Tiers off
      if not cfg.noTier then
        local base = cfg.base or STAT_BAR_CONFIG.default.base
        local multiplier = cfg.multiplier or STAT_BAR_CONFIG.default.multiplier
        if multiplier <= 1 then
          multiplier = STAT_BAR_CONFIG.default.multiplier
        end

        local tier, tierMin, tierMax, progress = CalculateTierProgress(value or 0, base, multiplier)
        local tierName = TIER_NAMES[tier] or TIER_NAMES[5] -- Default to Demon for tier 5+
        if showTiers then
          -- Use tier color for value text
          local tierColorIndex = math.min(tier, #TIER_COLORS)
          local tierColor = TIER_COLORS[tierColorIndex] or { 1, 1, 1, 1 }
          textColor = tierColor
          -- Store tier info for positioning after value text is set up
          if bar.tier then
            bar.tier:SetText(tierName)
            -- Check if toast is disabled and grey out if so
            local toastEnabled =
              GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[statKey] ~= false
            if toastEnabled then
              bar.tier:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
            else
              bar.tier:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when toast disabled
            end
            bar.tier.tierMin = tierMin
            bar.tier.tierMax = tierMax
            bar.tier.tierCurrent = value or 0
            bar.tier.tierName = tierName
          end
        else
          -- Show Tiers off: white text, tier UI hidden (toast button shown later when notifications on)
          textColor = { 1, 1, 1, 1 }
          if bar.tier then
            bar.tier:SetText('')
            bar.tier:Hide()
          end
          if bar.tierBg then
            bar.tierBg:Hide()
          end
          if bar.tierIcon then
            bar.tierIcon:Hide()
          end
        end
      else
        -- Hide tier for stats with noTier flag
        if bar.tier then
          bar.tier:SetText('')
          bar.tier:Hide()
        end
        if bar.tierBg then
          bar.tierBg:Hide()
        end
        if bar.tierIcon then
          bar.tierIcon:Hide()
        end
      end
    end
    if bar.minText then
      bar.minText:Hide()
    end
    if bar.maxText then
      bar.maxText:Hide()
    end
    bar.frame:SetBackdrop(nil)
    bar.text:ClearAllPoints()
    -- Nudge value up slightly to align with label baseline
    bar.text:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 6)
    bar.text:SetJustifyH('RIGHT')
    bar.text:SetText(displayText or '')
    bar.text:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1, 1)

    -- Position tier text after value text is positioned (for non-percent valueOnly stats, when Show Tiers on)
    if cfg.type ~= 'percent' and not cfg.noTier and showTiers and bar.tier and bar.tier:GetText() ~= '' then
      bar.tier:Show()
      bar.tier:ClearAllPoints()
      -- Position tier text consistently from the right (moved 30px left)
      bar.tier:SetPoint('RIGHT', bar.frame, 'RIGHT', -130, 6)
      if bar.tierIcon and showNotifications then
        bar.tierIcon:ClearAllPoints()
        bar.tierIcon:SetPoint('LEFT', bar.tier, 'RIGHT', STAT_TIER_ICON_GAP, 0)
        bar.tierIcon:Show()
      elseif bar.tierIcon then
        bar.tierIcon:Hide()
      end
      if bar.tierBg then
        bar.tierBg:ClearAllPoints()
        bar.tierBg:SetPoint('TOPLEFT', bar.tier, 'TOPLEFT', -8, 2)
        -- Pill should wrap tier text only (icon sits outside the pill)
        bar.tierBg:SetPoint('BOTTOMRIGHT', bar.tier, 'BOTTOMRIGHT', 8, -2)
        bar.tierBg:Show()
      end
    end

    -- Show toast button: when Notifications on, for noTier/percent-with-toast stats or for any tier stat when Show Tiers off
    local shouldShowToastButton = false
    if bar.toastButton and showNotifications then
      local percentStatsWithToast = { duelsWinPercent = true }
      if cfg.noTier or percentStatsWithToast[statKey] or (not showTiers and cfg.type ~= 'percent' and not cfg.noTier) then
        shouldShowToastButton = true
      end
    end

    if shouldShowToastButton then
      bar.toastButton:Show()
      bar.toastButton:ClearAllPoints()
      -- Position toast button consistently from the right (moved 30px left)
      bar.toastButton:SetPoint('RIGHT', bar.frame, 'RIGHT', -130, 6)
      -- Show stat icon to the right of the toast button only when Notifications on (deaths have no icon)
      if bar.tierIcon and statKey and showNotifications and not STATS_WITHOUT_TOAST_ICON[statKey] then
        local iconKey = ResolveStatIconKey(statKey)
        bar.tierIcon:ClearAllPoints()
        bar.tierIcon:SetPoint('LEFT', bar.toastButton, 'RIGHT', STAT_TIER_ICON_GAP, 0)
        bar.tierIcon:SetTexture(
          'Interface\\AddOns\\UltraStatistics\\Textures\\stats-icons\\' .. iconKey .. '.png'
        )
        bar.tierIcon:Show()
      elseif bar.tierIcon then
        bar.tierIcon:Hide()
      end
      -- Update visual state based on toast enabled status
      local toastEnabled =
        GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[statKey] ~= false
      if toastEnabled then
        bar.toastButton:SetTextColor(0.7, 0.7, 0.7, 1)
      else
        bar.toastButton:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when disabled
      end
    elseif bar.toastButton then
      bar.toastButton:Hide()
      -- Don't hide tierIcon when tier is visible; it was set above and follows showNotifications like other icons
      local tierVisible =
        cfg.type ~= 'percent' and not cfg.noTier and showTiers and bar.tier and bar.tier:GetText() ~= ''
      if bar.tierIcon and not tierVisible then
        bar.tierIcon:Hide()
      end
    end

    -- Keep bar height consistent
    bar.frame:SetHeight(STAT_BAR_HEIGHT)
    return
  end

  -- Ensure visuals are shown for normal bar mode
  if bar.bg then
    bar.bg:Show()
  end
  if bar.fill then
    bar.fill:Show()
  end
  if bar.tier then
    bar.tier:Show()
  end
  if bar.minText then
    bar.minText:Hide()
    bar.minText:SetText('')
  end
  if bar.maxText then
    bar.maxText:Show()
  end

  if cfg.type == 'percent' then
    local pctMax = cfg.max or 100
    local percent = math.max(0, math.min(value or 0, pctMax))
    local progress = pctMax > 0 and percent / pctMax or 0
    if statKey == 'level' and #LEVEL_COLOR_STEPS > 0 then
      local idx =
        math.min(#LEVEL_COLOR_STEPS, math.max(1, math.floor(progress * #LEVEL_COLOR_STEPS) + 1))
      effectiveFillColor = LEVEL_COLOR_STEPS[idx] or effectiveFillColor
    end
    local availableWidth =
      (bar.bg and (bar.bg:GetWidth() - STAT_FILL_INSET * 2)) or bar.frame:GetWidth()
    bar.fill:SetWidth(availableWidth * progress)
    if statKey == 'level' then
      bar.text:SetText(string.format('%d', value or 0))
    else
      bar.text:SetText(string.format('%.1f%%', percent))
    end
    bar.tier:SetText('')
    -- Don't hide toast button here - it will be handled in the toast button section below
    if bar.minText then
      bar.minText:SetText('0')
    end
    if bar.maxText then
      bar.maxText:SetText(string.format('%d', pctMax))
    end
  else
    local base = cfg.base or STAT_BAR_CONFIG.default.base
    local multiplier = cfg.multiplier or STAT_BAR_CONFIG.default.multiplier
    if multiplier <= 1 then
      multiplier = STAT_BAR_CONFIG.default.multiplier
    end

    local tier, tierMin, tierMax, progress = CalculateTierProgress(value or 0, base, multiplier)
    local tierColor = nil
    if showTiers and not cfg.color and #TIER_COLORS > 0 then
      local tierColorIndex = math.min(tier, #TIER_COLORS)
      tierColor = TIER_COLORS[tierColorIndex] or { 1, 1, 1, 1 }
      effectiveFillColor = tierColor
    end
    local availableWidth =
      (bar.bg and (bar.bg:GetWidth() - STAT_FILL_INSET * 2)) or bar.frame:GetWidth()
    bar.fill:SetWidth(availableWidth * progress)
    bar.text:SetText(formatNumberWithCommas(value or 0))

    -- Set tier name and colours when Show Tiers on; otherwise white text
    local tierName = TIER_NAMES[tier] or TIER_NAMES[5] -- Default to Demon for tier 5+
    if showTiers then
      bar.tier:SetText(tierName)
      if not tierColor then
        local tierColorIndex = math.min(tier, #TIER_COLORS)
        tierColor = TIER_COLORS[tierColorIndex] or { 1, 1, 1, 1 }
      end
      local toastEnabled =
        GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[statKey] ~= false
      if toastEnabled then
        bar.tier:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
      else
        bar.tier:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when toast disabled
      end
      if not cfg.color then
        bar.text:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
      end
      if bar.tier then
        bar.tier.tierMin = tierMin
        bar.tier.tierMax = tierMax
        bar.tier.tierCurrent = value or 0
        bar.tier.tierName = tierName
      end
    else
      bar.tier:SetText('')
      bar.text:SetTextColor(1, 1, 1, 1)
    end

    if bar.minText then
      bar.minText:SetText(formatNumberWithCommas(tierMin))
    end
    if bar.maxText then
      bar.maxText:SetText(formatNumberWithCommas(tierMax))
    end
  end

  -- Style end value to exactly match the centered value and sit above fills
  if bar.maxText then
    bar.maxText:Show()
    bar.maxText:ClearAllPoints()
    bar.maxText:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 0)
    bar.maxText:SetJustifyH('RIGHT')
    local font, fontSize, fontFlags = bar.text:GetFont()
    if font then
      bar.maxText:SetFont(font, fontSize, fontFlags)
    end
    local fontObj = bar.text:GetFontObject()
    if fontObj then
      bar.maxText:SetFontObject(fontObj)
    end
    local r, g, b, a = bar.text:GetTextColor()
    bar.maxText:SetTextColor(r or 1, g or 1, b or 1, a or 1)
    local sr, sg, sb, sa = bar.text:GetShadowColor()
    if sr and sg and sb and sa then
      bar.maxText:SetShadowColor(sr, sg, sb, sa)
    end
    local sx, sy = bar.text:GetShadowOffset()
    if sx and sy then
      bar.maxText:SetShadowOffset(sx, sy)
    end
    -- Force max text to the topmost layer
    bar.maxText:SetDrawLayer('OVERLAY', 50)
  end

  -- Layout: tier on the left, value on the right (only when Show Tiers on); hide tier icon when Notifications off
  if bar.tier then
    if cfg.type == 'percent' or cfg.noTier or not showTiers then
      bar.tier:Hide()
      if bar.tierIcon then
        bar.tierIcon:Hide()
      end
      if bar.tierBg then
        bar.tierBg:Hide()
      end
    else
      bar.tier:Show()
      bar.tier:ClearAllPoints()
      bar.tier:SetPoint('RIGHT', bar.frame, 'RIGHT', -130, 6)
      if bar.tierIcon and showNotifications then
        bar.tierIcon:ClearAllPoints()
        bar.tierIcon:SetPoint('LEFT', bar.tier, 'RIGHT', STAT_TIER_ICON_GAP, 0)
        bar.tierIcon:Show()
      elseif bar.tierIcon then
        bar.tierIcon:Hide()
      end
      if bar.tierBg then
        bar.tierBg:ClearAllPoints()
        bar.tierBg:SetPoint('TOPLEFT', bar.tier, 'TOPLEFT', -8, 2)
        bar.tierBg:SetPoint('BOTTOMRIGHT', bar.tier, 'BOTTOMRIGHT', 8, -2)
        bar.tierBg:Show()
      end
    end
  end

  -- Show toast button when Notifications on: noTier/percent-with-toast, or any tier stat when Show Tiers off
  if bar.toastButton then
    local shouldShowToastButton = false
    if showNotifications then
      local percentStatsWithToast = { duelsWinPercent = true }
      if cfg.noTier or percentStatsWithToast[statKey] or (not showTiers and cfg.type ~= 'percent' and not cfg.noTier) then
        shouldShowToastButton = true
      end
    end

    if shouldShowToastButton then
      bar.toastButton:Show()
      bar.toastButton:ClearAllPoints()
      -- Position toast button consistently from the right (moved 30px left)
      bar.toastButton:SetPoint('RIGHT', bar.frame, 'RIGHT', -130, 6)
      -- Show stat icon to the right of the toast button only when Notifications on (deaths have no icon)
      if bar.tierIcon and statKey and showNotifications and not STATS_WITHOUT_TOAST_ICON[statKey] then
        local iconKey = ResolveStatIconKey(statKey)
        bar.tierIcon:ClearAllPoints()
        bar.tierIcon:SetPoint('LEFT', bar.toastButton, 'RIGHT', STAT_TIER_ICON_GAP, 0)
        bar.tierIcon:SetTexture(
          'Interface\\AddOns\\UltraStatistics\\Textures\\stats-icons\\' .. iconKey .. '.png'
        )
        bar.tierIcon:Show()
      elseif bar.tierIcon then
        bar.tierIcon:Hide()
      end
      -- Update visual state based on toast enabled status
      local toastEnabled =
        GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[statKey] ~= false
      if toastEnabled then
        bar.toastButton:SetTextColor(0.7, 0.7, 0.7, 1)
      else
        bar.toastButton:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when disabled
      end
    else
      bar.toastButton:Hide()
      -- Hide icon when toast hidden (not in tier mode here; tier mode icon is handled by Layout block above)
      if bar.tierIcon and (cfg.type == 'percent' or cfg.noTier or not showTiers) then
        bar.tierIcon:Hide()
      end
    end
  end
  bar.text:ClearAllPoints()
  bar.text:SetPoint('CENTER', bar.frame, 'CENTER', 0, 0)

  if effectiveFillColor then
    bar.fill:SetColorTexture(unpack(effectiveFillColor))
  end
  if bgColor then
    bar.bg:SetColorTexture(unpack(bgColor))
  end
  if effectiveFillColor then
    bar.fill:SetColorTexture(unpack(effectiveFillColor))
  end
  if bgColor then
    bar.bg:SetColorTexture(unpack(bgColor))
  end
end

-- Initialize Statistics Tab when called
function UltraStatistics_InitializeStatisticsTab(tabContents)
  -- Check if tabContents[1] exists
  if not tabContents or not tabContents[1] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[1].initialized then return end

  -- Mark as initialized
  tabContents[1].initialized = true

  local statsFrame = CreateFrame('Frame', nil, tabContents[1], 'BackdropTemplate')
  statsFrame:SetPoint('TOP', tabContents[1], 'TOP', 0, -55) -- Moved up 10px
  statsFrame:SetPoint('LEFT', tabContents[1], 'LEFT', 10, 0)
  statsFrame:SetPoint('RIGHT', tabContents[1], 'RIGHT', -10, 0)
  statsFrame:SetHeight(535) -- Height fixed, width set by LEFT/RIGHT anchors
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
  statsScrollChild:SetSize(435, 300) -- Width matches section header width
  statsScrollFrame:SetScrollChild(statsScrollChild)
  local resourceEventFrame

  -- Track all sections for dynamic positioning
  local sections = {}
  local function addSection(header, content, name)
    local section = {
      header = header,
      content = content,
      name = name,
      collapsed = GLOBAL_SETTINGS.collapsedStatsSections and GLOBAL_SETTINGS.collapsedStatsSections[name] or false,
    }
    table.insert(sections, section)
    return section
  end

  -- Function to update section positions based on collapsed state
  local function updateSectionPositions()
    for i, section in ipairs(sections) do
      -- Position header
      section.header:ClearAllPoints()
      if i == 1 then
        section.header:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -5)
      else
        -- Anchor to the previous section's header if collapsed, otherwise to its content
        local previousSection = sections[i - 1]
        local anchorFrame =
          previousSection.collapsed and previousSection.header or previousSection.content
        section.header:SetPoint(
          'TOPLEFT',
          anchorFrame,
          'BOTTOMLEFT',
          previousSection.collapsed and 0 or -LAYOUT.CONTENT_INDENT,
          previousSection.collapsed and -LAYOUT.SECTION_SPACING or -LAYOUT.SECTION_SPACING
        )
      end

      -- Show/hide content based on collapsed state
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
    end
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

    -- Enable mouse interaction
    header:EnableMouse(true)
    header:SetScript('OnMouseDown', function(self, button)
      if button == 'LeftButton' and section then
        section.collapsed = not section.collapsed
        -- Save state
        if not GLOBAL_SETTINGS.collapsedStatsSections then
          GLOBAL_SETTINGS.collapsedStatsSections = {}
        end
        GLOBAL_SETTINGS.collapsedStatsSections[sectionName] = section.collapsed
        -- Update icon
        updateIcon(section.collapsed)
        -- Update all positions
        updateSectionPositions()
        if not section.collapsed then
          if UpdateLowestHealthDisplay then
            UpdateLowestHealthDisplay()
          end
          -- XP verification removed in UltraStatistics
        end
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
  characterInfoHeader:SetSize(435, LAYOUT.SECTION_HEADER_HEIGHT)

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
  characterInfoContent:SetSize(415, LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Level only
  -- Position will be set by updateSectionPositions
  characterInfoContent:Show() -- Show by default
  -- Register section and make header clickable
  local characterInfoSection =
    addSection(characterInfoHeader, characterInfoContent, 'characterInfo')
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
    key = 'totalHP',
    label = 'Max Health:',
    tooltipKey = 'totalHP',
    width = 1,
    settingName = 'showMainStatisticsPanelTotalHP',
    valueFunc = function()
      return UnitHealthMax('player') or 0
    end,
    defaultValue = 0,
  }, {
    key = 'maxResource',
    label = 'Max Resource:',
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

  -- Create Health Tracking section
  local healthTrackingHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  healthTrackingHeader:SetSize(435, LAYOUT.SECTION_HEADER_HEIGHT)

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
  healthTrackingContent:SetSize(415, 6 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, recalculated after grid layout
  healthTrackingContent:Show()
  local healthTrackingSection =
    addSection(healthTrackingHeader, healthTrackingContent, 'healthTracking')
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
    key = 'playerDeathsOpenWorld',
    label = 'Deaths (Open World):',
    tooltipKey = 'playerDeathsOpenWorld',
    settingName = 'showMainStatisticsPanelPlayerDeathsOpenWorld',
    defaultValue = 0,
    width = 0.5,
  }, {
    key = 'playerDeathsDungeon',
    label = 'Deaths (Dungeon):',
    tooltipKey = 'playerDeathsDungeon',
    settingName = 'showMainStatisticsPanelPlayerDeathsDungeon',
    defaultValue = 0,
    width = 0.5,
  }, {
    key = 'playerDeathsRaid',
    label = 'Deaths (Raid):',
    tooltipKey = 'playerDeathsRaid',
    settingName = 'showMainStatisticsPanelPlayerDeathsRaid',
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
  }, {
    key = 'partyMemberDeaths',
    label = 'Party Deaths Witnessed:',
    tooltipKey = 'partyDeathsWitnessed',
    settingName = 'showMainStatisticsPanelPartyMemberDeaths',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(healthTrackingContent, healthStats, { defaultWidth = 0.5 })

  -- Create modern WoW-style Combat section (collapsible)
  local combatHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  combatHeader:SetSize(435, LAYOUT.SECTION_HEADER_HEIGHT)
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
  combatContent:SetSize(415, 8 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, recalculated after grid layout
  -- Position will be set by updateSectionPositions
  combatContent:Show() -- Show by default
  -- Register section and make header clickable
  local combatSection = addSection(combatHeader, combatContent, 'combat')
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
  survivalHeader:SetSize(435, LAYOUT.SECTION_HEADER_HEIGHT)
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
  survivalContent:SetSize(415, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, will be corrected below
  -- Position will be set by updateSectionPositions
  survivalContent:Show() -- Always show
  -- Register section and make header clickable
  local survivalSection = addSection(survivalHeader, survivalContent, 'survival')
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

  -- Create modern WoW-style Misc section (collapsible)
  local miscHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  miscHeader:SetSize(435, LAYOUT.SECTION_HEADER_HEIGHT)
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
  miscContent:SetSize(415, 6 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, will be corrected below
  -- Position will be set by updateSectionPositions
  miscContent:Show()

  -- Register section and make header clickable
  local miscSection = addSection(miscHeader, miscContent, 'misc')
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

  -- Create misc statistics display inside the content frame (includes former Social stats)
  local miscStats = { {
    key = 'playerJumps',
    label = 'Jumps Performed:',
    tooltipKey = 'playerJumps',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'player360s',
    label = '360s During Jumps:',
    tooltipKey = 'player360s',
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
  }, {
    key = 'duelsTotal',
    label = 'Duels Total:',
    tooltipKey = 'duelsTotal',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsWon',
    label = 'Duels Won:',
    tooltipKey = 'duelsWon',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsLost',
    label = 'Duels Lost:',
    tooltipKey = 'duelsLost',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsWinPercent',
    label = 'Duel Win Percent:',
    tooltipKey = 'duelsWinPercent',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(miscContent, miscStats, { defaultWidth = 0.5 })

  -- Network section removed in UltraStatistics

  -- Settings XP Gain Verification section removed in UltraStatistics

  -- Set initial positioning after all statistics are created
  updateSectionPositions()

  -- Update the lowest health display
  local function UpdateLowestHealthDisplay()
    if not UltraStatisticsDB then return end

    UpdateStatBar('level', UnitLevel('player') or 1)
    UpdateStatBar('totalHP', UnitHealthMax('player') or 0)
    local resourceLabel, powerType = GetPlayerPrimaryResourceLabelAndType()
    if statLabels.maxResource then
      statLabels.maxResource:SetText('Max ' .. (resourceLabel or 'Resource') .. ':')
    end
    UpdateStatBar('maxResource', UnitPowerMax('player', powerType or 0) or 0)

    -- Only update pet deaths for pet classes (hunter and warlock)
    local _, playerClass = UnitClass('player')
    if playerClass == 'HUNTER' or playerClass == 'WARLOCK' then
      UpdateStatBar('petDeaths', CharacterStats:GetStat('petDeaths') or 0)
    end
    UpdateStatBar('closeEscapes', CharacterStats:GetStat('closeEscapes') or 0)
    UpdateStatBar('playerDeaths', CharacterStats:GetStat('playerDeaths') or 0)
    UpdateStatBar('playerDeathsOpenWorld', CharacterStats:GetStat('playerDeathsOpenWorld') or 0)
    UpdateStatBar(
      'playerDeathsBattleground',
      CharacterStats:GetStat('playerDeathsBattleground') or 0
    )
    UpdateStatBar('playerDeathsDungeon', CharacterStats:GetStat('playerDeathsDungeon') or 0)
    UpdateStatBar('playerDeathsRaid', CharacterStats:GetStat('playerDeathsRaid') or 0)
    UpdateStatBar('playerDeathsArena', CharacterStats:GetStat('playerDeathsArena') or 0)
    UpdateStatBar('partyMemberDeaths', CharacterStats:GetStat('partyMemberDeaths') or 0)
    UpdateStatBar('blocks', CharacterStats:GetStat('blocks') or 0)
    UpdateStatBar('parries', CharacterStats:GetStat('parries') or 0)
    UpdateStatBar('dodges', CharacterStats:GetStat('dodges') or 0)
    UpdateStatBar('resists', CharacterStats:GetStat('resists') or 0)

    UpdateStatBar('elitesSlain', CharacterStats:GetStat('elitesSlain') or 0)
    UpdateStatBar('rareElitesSlain', CharacterStats:GetStat('rareElitesSlain') or 0)
    UpdateStatBar('worldBossesSlain', CharacterStats:GetStat('worldBossesSlain') or 0)
    UpdateStatBar('enemiesSlain', CharacterStats:GetStat('enemiesSlain') or 0)
    UpdateStatBar('dungeonBossesKilled', CharacterStats:GetStat('dungeonBossesKilled') or 0)
    UpdateStatBar('dungeonsCompleted', CharacterStats:GetStat('dungeonsCompleted') or 0)

    UpdateStatBar('highestCritValue', CharacterStats:GetStat('highestCritValue') or 0)
    UpdateStatBar('highestHealCritValue', CharacterStats:GetStat('highestHealCritValue') or 0)

    for _, stat in ipairs(survivalStats) do
      UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key) or 0)
    end

    for _, stat in ipairs(miscStats) do
      UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key) or 0)
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
