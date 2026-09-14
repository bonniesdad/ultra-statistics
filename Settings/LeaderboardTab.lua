-- Leaderboard Tab: Guild / Server multi-column stats table.

function UltraStatistics_InitializeLeaderboardTab(tabContents)
  if not tabContents or not tabContents[2] then
    return
  end
  if tabContents[2].initialized then
    return
  end
  tabContents[2].initialized = true

  local LB = UltraStatistics_Leaderboard
  if not LB then
    return
  end

  local scope = 'guild'
  -- nil sortStat = unsorted (name order). First click uses the column's natural direction.
  local sortStat = 'playerDeaths'
  local sortAscending = true
  local ROW_HEIGHT = 24
  local HEADER_HEIGHT = 26
  local MAX_ROWS = 60
  local COL_GAP = 6
  local NAME_WEIGHT = 1.25
  local STAT_WEIGHT = {
    playerDeaths = 1.0,
    dungeonsCompleted = 1.15,
    enemiesSlain = 1.35,
    playerJumps = 1.35,
    goldGained = 1.35,
  }
  local DEFAULT_STAT_WEIGHT = 1.0

  local CREAM = { 0.922, 0.871, 0.761 }
  local CREAM_DIM = { 0.75, 0.72, 0.65 }
  local GOLD = { 1.0, 0.92, 0.55 }
  local SELF = { 0.45, 0.95, 0.58 }
  local ROW_A = { 0.14, 0.13, 0.16, 0.92 }
  local ROW_B = { 0.10, 0.095, 0.12, 0.72 }
  local ROW_SELF = { 0.12, 0.28, 0.16, 0.88 }
  local ROW_HOVER = { 0.22, 0.20, 0.28, 0.95 }

  -- Two-way Guild / Server switch (snapping slider).
  local SWITCH_W = 180
  local SWITCH_H = 26
  local THUMB_PAD = 2

  local scopeSwitch = CreateFrame('Frame', nil, tabContents[2], 'BackdropTemplate')
  scopeSwitch:SetSize(SWITCH_W, SWITCH_H)
  scopeSwitch:SetPoint('TOP', tabContents[2], 'TOP', 0, -62)
  scopeSwitch:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  scopeSwitch:SetBackdropColor(0.08, 0.08, 0.1, 0.95)
  scopeSwitch:SetBackdropBorderColor(0.45, 0.42, 0.36, 0.85)

  local thumb = CreateFrame('Frame', nil, scopeSwitch, 'BackdropTemplate')
  thumb:SetSize((SWITCH_W / 2) - (THUMB_PAD * 2), SWITCH_H - (THUMB_PAD * 2) - 2)
  thumb:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  thumb:SetBackdropColor(0.18, 0.17, 0.24, 0.98)
  thumb:SetBackdropBorderColor(0.55, 0.52, 0.42, 0.95)
  thumb:SetFrameLevel(scopeSwitch:GetFrameLevel() + 1)

  local labelLayer = CreateFrame('Frame', nil, scopeSwitch)
  labelLayer:SetAllPoints()
  labelLayer:SetFrameLevel(thumb:GetFrameLevel() + 1)
  labelLayer:EnableMouse(false)

  local guildLabel = labelLayer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  guildLabel:SetPoint('LEFT', labelLayer, 'LEFT', 0, 0)
  guildLabel:SetPoint('RIGHT', labelLayer, 'CENTER', 0, 0)
  guildLabel:SetJustifyH('CENTER')
  guildLabel:SetText('Guild')

  local serverLabel = labelLayer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  serverLabel:SetPoint('LEFT', labelLayer, 'CENTER', 0, 0)
  serverLabel:SetPoint('RIGHT', labelLayer, 'RIGHT', 0, 0)
  serverLabel:SetJustifyH('CENTER')
  serverLabel:SetText('Server')

  local statusText = tabContents[2]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  statusText:SetPoint('LEFT', scopeSwitch, 'RIGHT', 12, 0)
  statusText:SetTextColor(CREAM_DIM[1], CREAM_DIM[2], CREAM_DIM[3], 1)
  statusText:SetJustifyH('LEFT')
  statusText:SetText('')

  local SCROLLBAR_INSET = 28

  local headerBar = CreateFrame('Frame', nil, tabContents[2], 'BackdropTemplate')
  headerBar:SetPoint('TOPLEFT', tabContents[2], 'TOPLEFT', 0, -96)
  headerBar:SetPoint('TOPRIGHT', tabContents[2], 'TOPRIGHT', 0, -96)
  headerBar:SetHeight(HEADER_HEIGHT)
  headerBar:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  headerBar:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
  headerBar:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)

  local headerRow = CreateFrame('Frame', nil, headerBar)
  headerRow:SetPoint('TOPLEFT', headerBar, 'TOPLEFT', 0, 0)
  headerRow:SetPoint('BOTTOMRIGHT', headerBar, 'BOTTOMRIGHT', -SCROLLBAR_INSET, 0)

  local headerName = headerRow:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  headerName:SetJustifyH('LEFT')
  headerName:SetText('Player')
  headerName:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
  headerName:SetShadowOffset(1, -1)
  headerName:SetShadowColor(0, 0, 0, 0.8)

  local sortButtons = {}
  for _, key in ipairs(LB.STAT_KEYS) do
    local btn = CreateFrame('Button', nil, headerRow)
    btn:SetHeight(HEADER_HEIGHT - 2)
    local label = btn:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    label:SetPoint('TOPLEFT', btn, 'TOPLEFT', 0, 0)
    label:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMRIGHT', 0, 0)
    label:SetJustifyH('RIGHT')
    label:SetText(LB.STAT_SHORT_LABELS[key] or key)
    label:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 0.8)
    btn.label = label

    local arrow = btn:CreateTexture(nil, 'ARTWORK')
    arrow:SetTexture('Interface\\Buttons\\UI-SortArrow')
    arrow:SetSize(9, 8)
    arrow:Hide()
    btn.sortArrow = arrow

    btn._statKey = key
    btn:SetScript('OnEnter', function(self)
      if self._statKey ~= sortStat then
        self.label:SetTextColor(1, 1, 0.92)
      end
    end)
    btn:SetScript('OnLeave', function(self)
      if self._statKey == sortStat then
        self.label:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
      else
        self.label:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
      end
    end)
    sortButtons[key] = btn
  end

  local accentLine = tabContents[2]:CreateTexture(nil, 'ARTWORK')
  accentLine:SetColorTexture(GOLD[1], GOLD[2], GOLD[3], 0.35)
  accentLine:SetHeight(1)
  accentLine:SetPoint('TOPLEFT', headerBar, 'BOTTOMLEFT', 1, -1)
  accentLine:SetPoint('TOPRIGHT', headerBar, 'BOTTOMRIGHT', -1, -1)

  local tableBody = CreateFrame('Frame', nil, tabContents[2], 'BackdropTemplate')
  tableBody:SetPoint('TOPLEFT', headerBar, 'BOTTOMLEFT', 0, -4)
  tableBody:SetPoint('BOTTOMRIGHT', tabContents[2], 'BOTTOMRIGHT', 0, 10)
  tableBody:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  tableBody:SetBackdropColor(0.06, 0.06, 0.08, 0.92)
  tableBody:SetBackdropBorderColor(0.45, 0.42, 0.36, 0.75)

  local scrollFrame = CreateFrame('ScrollFrame', nil, tableBody, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', tableBody, 'TOPLEFT', 0, -1)
  scrollFrame:SetPoint('BOTTOMRIGHT', tableBody, 'BOTTOMRIGHT', 0, 1)
  local scrollChild = CreateFrame('Frame', nil, scrollFrame)
  scrollChild:SetSize(100, 100)
  scrollFrame:SetScrollChild(scrollChild)

  local scrollBar = scrollFrame.ScrollBar
  if scrollBar then
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint('TOPRIGHT', tableBody, 'TOPRIGHT', -1, -16)
    scrollBar:SetPoint('BOTTOMRIGHT', tableBody, 'BOTTOMRIGHT', -1, 16)
    scrollBar:SetFrameLevel((scrollFrame:GetFrameLevel() or 1) + 5)
  end

  local rows = {}
  for i = 1, MAX_ROWS do
    local row = CreateFrame('Frame', nil, scrollChild)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, -(i - 1) * ROW_HEIGHT)
    row:SetPoint('TOPRIGHT', scrollChild, 'TOPRIGHT', 0, -(i - 1) * ROW_HEIGHT)
    row:EnableMouse(true)

    local bg = row:CreateTexture(nil, 'BACKGROUND')
    bg:SetPoint('TOPLEFT', row, 'TOPLEFT', 0, 0)
    bg:SetPoint('BOTTOMLEFT', row, 'BOTTOMLEFT', 0, 0)
    bg:SetPoint('RIGHT', row, 'RIGHT', 0, 0)
    bg:SetColorTexture(ROW_A[1], ROW_A[2], ROW_A[3], ROW_A[4])
    row.bg = bg
    row._stripe = (i % 2 == 0) and 'b' or 'a'

    local leftAccent = row:CreateTexture(nil, 'ARTWORK')
    leftAccent:SetPoint('TOPLEFT', row, 'TOPLEFT', 0, 0)
    leftAccent:SetPoint('BOTTOMLEFT', row, 'BOTTOMLEFT', 0, 0)
    leftAccent:SetWidth(2)
    leftAccent:SetColorTexture(0, 0, 0, 0)
    row.leftAccent = leftAccent

    row.name = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.name:SetJustifyH('LEFT')
    row.name:SetWordWrap(false)

    row.cells = {}
    for _, key in ipairs(LB.STAT_KEYS) do
      local cell = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
      cell:SetJustifyH('RIGHT')
      row.cells[key] = cell
    end

    row:SetScript('OnEnter', function(self)
      if self._isSelf then
        self.bg:SetColorTexture(0.16, 0.34, 0.20, 0.95)
      else
        self.bg:SetColorTexture(ROW_HOVER[1], ROW_HOVER[2], ROW_HOVER[3], ROW_HOVER[4])
      end
    end)
    row:SetScript('OnLeave', function(self)
      if self._restoreBg then
        self._restoreBg()
      end
    end)

    row:Hide()
    rows[i] = row
  end

  local function computeWidths(totalWidth)
    local n = #LB.STAT_KEYS
    local gaps = COL_GAP * n
    local flex = math.max(n * 40, (totalWidth or 0) - gaps)
    local statWeightSum = 0
    for _, key in ipairs(LB.STAT_KEYS) do
      statWeightSum = statWeightSum + (STAT_WEIGHT[key] or DEFAULT_STAT_WEIGHT)
    end
    local weightSum = NAME_WEIGHT + statWeightSum
    local nameW = math.floor(flex * NAME_WEIGHT / weightSum)
    local rem = flex - nameW
    local statW = {}
    local used = 0
    for i, key in ipairs(LB.STAT_KEYS) do
      local w
      if i == n then
        w = rem - used
      else
        local weight = STAT_WEIGHT[key] or DEFAULT_STAT_WEIGHT
        w = math.floor(rem * weight / statWeightSum)
        used = used + w
      end
      statW[key] = math.max(36, w)
    end
    return nameW, statW
  end

  local function applyLayout(totalWidth)
    local nameW, statW = computeWidths(totalWidth)
    local x = 4

    headerName:ClearAllPoints()
    headerName:SetPoint('LEFT', headerRow, 'LEFT', x, 0)
    headerName:SetWidth(nameW)

    x = x + nameW + COL_GAP
    for _, key in ipairs(LB.STAT_KEYS) do
      local w = statW[key]
      local btn = sortButtons[key]
      btn:ClearAllPoints()
      btn:SetPoint('LEFT', headerRow, 'LEFT', x, 0)
      btn:SetWidth(w)
      x = x + w + COL_GAP
    end

    for i = 1, MAX_ROWS do
      local row = rows[i]
      local rx = 4
      row.name:ClearAllPoints()
      row.name:SetPoint('LEFT', row, 'LEFT', rx, 0)
      row.name:SetWidth(nameW)

      rx = rx + nameW + COL_GAP
      for _, key in ipairs(LB.STAT_KEYS) do
        local w = statW[key]
        local cell = row.cells[key]
        cell:ClearAllPoints()
        cell:SetPoint('LEFT', row, 'LEFT', rx, 0)
        cell:SetWidth(w)
        rx = rx + w + COL_GAP
      end
    end
  end

  local function formatValue(statKey, value)
    value = tonumber(value) or 0
    if statKey == 'goldGained' then
      local copper = math.floor(value + 0.5)
      local g = math.floor(copper / 10000)
      if UltraStatistics_FormatNumberWithCommas then
        return UltraStatistics_FormatNumberWithCommas(g) .. 'g'
      end
      return tostring(g) .. 'g'
    end
    if UltraStatistics_FormatNumberWithCommas then
      return UltraStatistics_FormatNumberWithCommas(math.floor(value + 0.5))
    end
    return tostring(math.floor(value + 0.5))
  end

  local function defaultAscendingFor(statKey)
    return LB.LOWER_IS_BETTER and LB.LOWER_IS_BETTER[statKey] == true
  end

  local function cycleSort(statKey)
    if sortStat ~= statKey then
      sortStat = statKey
      sortAscending = defaultAscendingFor(statKey)
      return
    end
    local natural = defaultAscendingFor(statKey)
    if sortAscending == natural then
      -- Second click: reverse direction.
      sortAscending = not natural
    else
      -- Third click: clear sort.
      sortStat = nil
      sortAscending = true
    end
  end

  local function updateSortHeaders()
    for key, btn in pairs(sortButtons) do
      local label = LB.STAT_SHORT_LABELS[key] or key
      btn.label:SetText(label)
      if key == sortStat then
        btn.label:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
        -- Leave room on the left of the label for the Blizzard sort arrow.
        btn.label:ClearAllPoints()
        btn.label:SetPoint('TOPLEFT', btn, 'TOPLEFT', 0, 0)
        btn.label:SetPoint('BOTTOMRIGHT', btn, 'BOTTOMRIGHT', 0, 0)
        btn.label:SetJustifyH('RIGHT')
        local textWidth = btn.label:GetStringWidth() or 0
        btn.sortArrow:ClearAllPoints()
        -- Independent Y nudges (WoW +Y is up). Atlas crop sits opposite of the glyph tip.
        local arrowY = sortAscending and -1 or 2
        btn.sortArrow:SetPoint('RIGHT', btn, 'RIGHT', -(textWidth + 3), arrowY)
        if sortAscending then
          btn.sortArrow:SetTexCoord(0, 0.5625, 0, 1)
        else
          btn.sortArrow:SetTexCoord(0, 0.5625, 1, 0)
        end
        btn.sortArrow:Show()
      else
        btn.label:SetTextColor(CREAM[1], CREAM[2], CREAM[3])
        btn.sortArrow:Hide()
      end
    end
  end

  local function applyRowBackground(row, isSelf)
    row._isSelf = isSelf and true or false
    row._restoreBg = function()
      if row._isSelf then
        row.bg:SetColorTexture(ROW_SELF[1], ROW_SELF[2], ROW_SELF[3], ROW_SELF[4])
        row.leftAccent:SetColorTexture(SELF[1], SELF[2], SELF[3], 0.95)
      elseif row._stripe == 'b' then
        row.bg:SetColorTexture(ROW_B[1], ROW_B[2], ROW_B[3], ROW_B[4])
        row.leftAccent:SetColorTexture(0.35, 0.32, 0.28, 0.35)
      else
        row.bg:SetColorTexture(ROW_A[1], ROW_A[2], ROW_A[3], ROW_A[4])
        row.leftAccent:SetColorTexture(0.45, 0.42, 0.36, 0.45)
      end
    end
    row._restoreBg()
  end

  local function setRowColors(row, isSelf)
    local r, g, b = 0.92, 0.90, 0.86
    if isSelf then
      r, g, b = SELF[1], SELF[2], SELF[3]
    end
    row.name:SetTextColor(r, g, b)
    for key, cell in pairs(row.cells) do
      if sortStat and key == sortStat and not isSelf then
        cell:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
      elseif isSelf then
        cell:SetTextColor(SELF[1], SELF[2], SELF[3])
      else
        cell:SetTextColor(r, g, b)
      end
    end
  end

  local function refreshTable()
    LB.UpsertOwnEntry(scope)
    local list = LB.GetEntries(scope) or {}
    LB.SortEntries(list, sortStat, sortAscending)
    local myKey = LB.GetPlayerKey()
    -- Row backgrounds fill the body; column layout reserves room for the overlaid scrollbar.
    local fullWidth = math.max(100, tableBody:GetWidth() or scrollFrame:GetWidth() or 400)
    local contentWidth = math.max(80, fullWidth - SCROLLBAR_INSET)
    scrollChild:SetWidth(fullWidth)
    scrollChild:SetHeight(math.max(#list, 1) * ROW_HEIGHT)
    applyLayout(contentWidth)
    updateSortHeaders()

    for i = 1, MAX_ROWS do
      local row = rows[i]
      local data = list[i]
      if data then
        local displayName = data.name or data.key
        if Ambiguate then
          displayName = Ambiguate(displayName, 'none')
        end
        row.name:SetText(displayName)
        for _, key in ipairs(LB.STAT_KEYS) do
          local raw = data.values and data.values[key]
          row.cells[key]:SetText(formatValue(key, raw))
        end
        local isSelf = data.key == myKey
        applyRowBackground(row, isSelf)
        setRowColors(row, isSelf)
        row:Show()
      else
        row:Hide()
      end
    end

    if scope == 'guild' and LB.IsGuildOptedOut() then
      statusText:SetText('Guild sharing opted out')
    elseif scope == 'server' and LB.IsServerOptedOut() then
      statusText:SetText('Server sharing opted out')
    elseif #list == 0 then
      statusText:SetText('No entries yet')
    else
      statusText:SetText(#list .. ' players')
    end
  end

  local function updateScopeSwitch()
    thumb:ClearAllPoints()
    if scope == 'guild' then
      thumb:SetPoint('LEFT', scopeSwitch, 'LEFT', THUMB_PAD, 0)
      guildLabel:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
      serverLabel:SetTextColor(CREAM_DIM[1], CREAM_DIM[2], CREAM_DIM[3])
    else
      thumb:SetPoint('RIGHT', scopeSwitch, 'RIGHT', -THUMB_PAD, 0)
      guildLabel:SetTextColor(CREAM_DIM[1], CREAM_DIM[2], CREAM_DIM[3])
      serverLabel:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    end
  end

  local function setScope(nextScope)
    if nextScope ~= 'guild' and nextScope ~= 'server' then
      return
    end
    if scope == nextScope then
      updateScopeSwitch()
      return
    end
    scope = nextScope
    updateScopeSwitch()
    refreshTable()
  end

  scopeSwitch:EnableMouse(true)
  scopeSwitch:SetScript('OnMouseUp', function(_, button)
    if button ~= 'LeftButton' then
      return
    end
    local x = GetCursorPosition()
    local scale = scopeSwitch:GetEffectiveScale() or 1
    local left = scopeSwitch:GetLeft() or 0
    local width = scopeSwitch:GetWidth() or SWITCH_W
    local localX = (x / scale) - left
    if localX < (width / 2) then
      setScope('guild')
    else
      setScope('server')
    end
  end)

  LB.RefreshUI = refreshTable

  for _, btn in pairs(sortButtons) do
    btn:SetScript('OnClick', function(self)
      cycleSort(self._statKey)
      refreshTable()
    end)
  end

  updateScopeSwitch()
  refreshTable()
  scrollFrame:SetScript('OnSizeChanged', function()
    refreshTable()
  end)
  headerRow:SetScript('OnSizeChanged', function()
    refreshTable()
  end)
end
