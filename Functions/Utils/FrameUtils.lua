-- Frame helpers shared by UI modules

local function SaveFramePointToDB(frame, key)
  if not frame or not UltraStatisticsDB then return end
  local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)
  UltraStatisticsDB[key] = {
    point = point,
    relativePoint = relativePoint,
    x = xOfs,
    y = yOfs,
  }
end

-- Make a frame draggable
function MakeFrameDraggable(frame, dbKey)
  if not frame or type(frame) ~= 'table' then
    print('UltraStatistics: Invalid frame provided to MakeFrameDraggable')
    return
  end

  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag('LeftButton')
  frame:SetScript('OnDragStart', frame.StartMoving)
  frame:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    if dbKey then
      SaveFramePointToDB(self, dbKey)
    end
  end)
end

function UltraStatistics_CreateInstanceAccordionList(opts)
  if type(opts) ~= 'table' then return nil end

  local scrollChild = opts.scrollChild
  local layout = opts.layout
  local instances = opts.instances
  local collapsedStateTable = opts.collapsedStateTable

  if not scrollChild or not layout or type(instances) ~= 'table' or type(collapsedStateTable) ~= 'table' then
    return nil
  end

  local width = tonumber(opts.width) or 435
  local bgHeight = tonumber(opts.bgHeight) or 200
  local bgInsetX = tonumber(opts.bgInsetX) or 0
  local bgInsetY = tonumber(opts.bgInsetY) or 0
  local texturesRoot = opts.texturesRoot or 'heroics'
  local defaultCollapsed = opts.defaultCollapsed ~= false

  local function formatStat(val)
    if val == nil or val == 0 then
      return '-'
    end
    return tostring(val)
  end

  local function SlugifyName(name)
    if not name or type(name) ~= 'string' then
      return ''
    end
    local slug = name:lower()
    slug = slug:gsub('%s+', '-')
    slug = slug:gsub('["\'%.,!%?]', '')
    slug = slug:gsub('%-+', '-')
    return slug
  end

  local sections = {}

  local function addSection(header, content, key)
    local collapsedByDefault = defaultCollapsed and (collapsedStateTable[key] ~= false) or (collapsedStateTable[key] == true)
    local section = {
      header = header,
      content = content,
      key = key,
      collapsed = collapsedByDefault,
      _updateIcon = nil,
    }
    table.insert(sections, section)
    return section
  end

  local function updateSectionPositions()
    local y = -5
    for _, section in ipairs(sections) do
      local header = section.header
      local content = section.content
      if header then
        header:ClearAllPoints()
        header:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, y)
      end

      local headerHeight = (header and header:GetHeight()) or layout.SECTION_HEADER_HEIGHT
      if section.collapsed then
        if content then
          content:Hide()
        end
        y = y - headerHeight - layout.SECTION_SPACING
      else
        if content then
          content:Show()
          content:ClearAllPoints()
          content:SetPoint('TOPLEFT', header, 'BOTTOMLEFT', 0, 0)
          local contentHeight = content:GetHeight() or 0
          y = y - headerHeight - contentHeight - layout.SECTION_SPACING
        else
          y = y - headerHeight - layout.SECTION_SPACING
        end
      end
    end

    scrollChild:SetHeight(math.max(1, -y + 20))
  end

  local function makeHeaderClickable(section)
    if not section or not section.header then return end

    local header = section.header
    local key = section.key

    local collapseIcon = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    collapseIcon:SetPoint('LEFT', header, 'LEFT', 10, 0)
    collapseIcon:SetTextColor(0.9, 0.85, 0.75, 1)
    collapseIcon:SetShadowOffset(1, -1)
    collapseIcon:SetShadowColor(0, 0, 0, 0.8)

    local function updateIcon()
      collapseIcon:SetText(section.collapsed and '+' or '-')
    end
    section._updateIcon = updateIcon
    updateIcon()

    header:EnableMouse(true)
    header:SetScript('OnMouseDown', function(_, button)
      if button ~= 'LeftButton' then return end
      section.collapsed = not section.collapsed
      collapsedStateTable[key] = section.collapsed and true or false
      if section._updateIcon then
        section._updateIcon()
      end
      updateSectionPositions()
    end)

    header:SetScript('OnEnter', function(self)
      self:SetBackdropColor(0.2, 0.2, 0.28, 0.95)
      self:SetBackdropBorderColor(0.6, 0.6, 0.75, 1)
    end)
    header:SetScript('OnLeave', function(self)
      self:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
      self:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
    end)
  end

  local function CreateInstanceSection(instance)
    if type(instance) ~= 'table' then return end

    local dungeonKey = instance.key or SlugifyName(instance.title or '')
    if not dungeonKey or dungeonKey == '' then return end

    local title = instance.title or dungeonKey

    local header = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    header:SetSize(width, layout.SECTION_HEADER_HEIGHT)
    header:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 8,
      edgeSize = 12,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    header:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
    header:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)

    local label = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    label:SetPoint('LEFT', header, 'LEFT', 24, 0)
    label:SetText(title)
    label:SetTextColor(0.9, 0.85, 0.75, 1)
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 0.8)

    local content = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    content:SetSize(width, 120)
    content:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 8,
      edgeSize = 10,
      insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    content:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
    content:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

    local folderSlug = SlugifyName(title)
    local baseTexturePath =
      'Interface\\AddOns\\UltraStatistics\\Textures\\' .. texturesRoot .. '\\' .. folderSlug .. '\\bg.png'

    local bg = content:CreateTexture(nil, 'BACKGROUND')
    bg:SetPoint('TOPLEFT', content, 'TOPLEFT', bgInsetX, bgInsetY)
    bg:SetPoint('TOPRIGHT', content, 'TOPRIGHT', -bgInsetX, bgInsetY)
    bg:SetHeight(bgHeight)
    bg:SetTexture(baseTexturePath)
    bg:SetAlpha(0.8)

    local bosses = instance.bosses or {}
    local hasFinalBossKill = false
    if type(bosses) == 'table' and #bosses > 0 then
      local finalIndex = nil
      for index, boss in ipairs(bosses) do
        if type(boss) == 'table' and boss.isFinal then
          finalIndex = index
          break
        end
      end
      if not finalIndex then
        finalIndex = #bosses
      end
      local finalBoss = bosses[finalIndex]
      if type(finalBoss) == 'table' then
        local kills = finalBoss.totalKills or finalBoss.kills or 0
        if kills > 0 then
          hasFinalBossKill = true
        end
      end
    end

    if hasFinalBossKill then
      -- Even softer, very pale green border for completed instances
      content:SetBackdropBorderColor(0.7, 0.95, 0.7, 1)
      header:SetBackdropBorderColor(0.7, 0.95, 0.7, 1)
    end

    local totalClears = instance.totalClears or 0
    local totalDeaths = instance.totalDeaths or 0
    local firstClearDeaths = instance.firstClearDeaths or 0

    -- Completion icons: header + inside content. Green if cleared at least once, incomplete icon otherwise.
    local isCleared = (totalClears or 0) > 0
    local statusIcon = header:CreateTexture(nil, 'ARTWORK')
    statusIcon:SetSize(20, 20)
    statusIcon:SetPoint('RIGHT', header, 'RIGHT', -8, 0)
    local completeTexture =
      'Interface\\AddOns\\UltraStatistics\\Textures\\complete.png'
    local incompleteTexture =
      'Interface\\AddOns\\UltraStatistics\\Textures\\incomplete.png'
    statusIcon:SetTexture(isCleared and completeTexture or incompleteTexture)

    local summaryLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    summaryLabel:SetPoint('TOPLEFT', content, 'TOPLEFT', 12, -10)
    summaryLabel:SetText('Summary')
    summaryLabel:SetTextColor(1, 0.95, 0.75, 1)
    summaryLabel:SetShadowOffset(1, -1)
    summaryLabel:SetShadowColor(0, 0, 0, 0.9)

    -- Completion icon duplicated inside the dropdown content (right, vertically centered).
    local contentStatusIcon = content:CreateTexture(nil, 'OVERLAY')
    contentStatusIcon:SetSize(62, 62)
    -- Position roughly centered vertically in the summary block, between header and bosses list.
    contentStatusIcon:SetPoint('TOPRIGHT', content, 'TOPRIGHT', -16, -28)
    contentStatusIcon:SetTexture(isCleared and completeTexture or incompleteTexture)

    -- Centered status text above the icon, e.g. "Incomplete" or "Cleared" + date.
    local contentStatusLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    -- Slightly above the icon; adjusted so two-line cleared text sits comfortably.
    contentStatusLabel:SetPoint('BOTTOM', contentStatusIcon, 'TOP', 0, 0)
    contentStatusLabel:SetJustifyH('CENTER')
    contentStatusLabel:SetTextColor(1, 0.98, 0.9, 1)
    contentStatusLabel:SetShadowOffset(1, -1)
    contentStatusLabel:SetShadowColor(0, 0, 0, 0.9)

    local clearDateText = instance.firstClearDate
    if isCleared then
      if type(clearDateText) == 'string' and clearDateText ~= '' then
        -- Two-line text when we have a date: "Cleared" on first line, date on second.
        contentStatusLabel:SetText('Cleared\n' .. clearDateText)
      else
        contentStatusLabel:SetText('Cleared')
      end
    else
      contentStatusLabel:SetText('Incomplete')
    end

    local summaryGap = 2
    local summaryLine1 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    summaryLine1:SetPoint('TOPLEFT', summaryLabel, 'BOTTOMLEFT', 0, -4)
    summaryLine1:SetText(
      string.format('|cffb0b0b0First attempt deaths:|r |cffffffff%s|r', formatStat(firstClearDeaths))
    )
    summaryLine1:SetShadowOffset(1, -1)
    summaryLine1:SetShadowColor(0, 0, 0, 0.8)

    local summaryLine2 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    summaryLine2:SetPoint('TOPLEFT', summaryLine1, 'BOTTOMLEFT', 0, -summaryGap)
    summaryLine2:SetText(string.format('|cffb0b0b0Clears:|r |cffffffff%s|r', formatStat(totalClears)))
    summaryLine2:SetShadowOffset(1, -1)
    summaryLine2:SetShadowColor(0, 0, 0, 0.8)

    local summaryLine3 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    summaryLine3:SetPoint('TOPLEFT', summaryLine2, 'BOTTOMLEFT', 0, -summaryGap)
    summaryLine3:SetText(string.format('|cffb0b0b0Deaths:|r |cffffffff%s|r', formatStat(totalDeaths)))
    summaryLine3:SetShadowOffset(1, -1)
    summaryLine3:SetShadowColor(0, 0, 0, 0.8)

    local bossesTitle = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    bossesTitle:SetPoint('TOPLEFT', content, 'TOPLEFT', 12, -78)
    bossesTitle:SetText('Bosses')
    bossesTitle:SetTextColor(1, 0.95, 0.75, 1)
    bossesTitle:SetShadowOffset(1, -1)
    bossesTitle:SetShadowColor(0, 0, 0, 0.9)

    local bossCount = 0
    local rowHeight = 86
    local rowSpacing = 6
    local previousRow = nil

    if type(bosses) == 'table' then
      for _, boss in ipairs(bosses) do
        local bossName
        local totalBossKills = 0
        local totalBossDeaths = 0
        local firstBossDeaths = 0

        if type(boss) == 'table' then
          bossName = boss.name or boss.title
          totalBossKills = boss.totalKills or boss.kills or 0
          totalBossDeaths = boss.totalDeaths or boss.deaths or 0
          firstBossDeaths = boss.firstClearDeaths or boss.firstDeaths or 0
        elseif type(boss) == 'string' then
          bossName = boss
        end

        if type(bossName) == 'string' and bossName ~= '' then
          bossCount = bossCount + 1

          local row = CreateFrame('Frame', nil, content, 'BackdropTemplate')
          row:SetSize(width - 24, rowHeight)
          row:SetBackdrop({
            bgFile = 'Interface\\Buttons\\WHITE8X8',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
            tile = true,
            tileSize = 8,
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
          })
          row:SetBackdropColor(0, 0, 0, 0.25)
          row:SetBackdropBorderColor(0.15, 0.15, 0.18, 0.8)

          if previousRow then
            row:SetPoint('TOPLEFT', previousRow, 'BOTTOMLEFT', 0, -rowSpacing)
          else
            row:SetPoint('TOPLEFT', bossesTitle, 'BOTTOMLEFT', 0, -6)
          end

          local rowTopPadding = 10
          local icon = row:CreateTexture(nil, 'ARTWORK')
          icon:SetSize(128, 64)
          icon:SetPoint('TOPLEFT', row, 'TOPLEFT', 4, -rowTopPadding)

          local bossSlug = SlugifyName(bossName)
          local bossTexturePath =
            'Interface\\AddOns\\UltraStatistics\\Textures\\' ..
            texturesRoot .. '\\' .. folderSlug .. '\\' .. bossSlug .. '.png'
          icon:SetTexture(bossTexturePath)
          icon:SetTexCoord(0, 1, 0, 1)

          local nameFS = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
          nameFS:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 8, 0)
          nameFS:SetText(bossName)
          nameFS:SetTextColor(1, 0.97, 0.9, 1)
          nameFS:SetShadowOffset(1, -1)
          nameFS:SetShadowColor(0, 0, 0, 0.9)

          local titleToDividerGap = 8
          local divider = row:CreateTexture(nil, 'BACKGROUND')
          divider:SetColorTexture(1, 1, 1, 0.15)
          divider:SetHeight(1)
          divider:SetPoint('TOPLEFT', nameFS, 'BOTTOMLEFT', 0, -titleToDividerGap)
          divider:SetPoint('RIGHT', row, 'RIGHT', -4, 0)

          -- Table-like layout: labels left-aligned, values right-aligned
          local statsGap = 2
          local labelWidth = 140 -- Fixed width for labels so values align

          -- First attempt deaths row
          local label1 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          label1:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', 0, -8)
          label1:SetJustifyH('LEFT')
          label1:SetWidth(labelWidth)
          label1:SetText('|cffa0a0a0First attempt deaths:|r')
          label1:SetShadowOffset(1, -1)
          label1:SetShadowColor(0, 0, 0, 0.8)

          local value1 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          value1:SetPoint('LEFT', label1, 'RIGHT', 4, 0)
          value1:SetPoint('RIGHT', row, 'RIGHT', -4, 0)
          value1:SetJustifyH('RIGHT')
          value1:SetText('|cffffffff' .. formatStat(firstBossDeaths) .. '|r')
          value1:SetShadowOffset(1, -1)
          value1:SetShadowColor(0, 0, 0, 0.8)

          -- Kills row
          local label2 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          label2:SetPoint('TOPLEFT', label1, 'BOTTOMLEFT', 0, -statsGap)
          label2:SetJustifyH('LEFT')
          label2:SetWidth(labelWidth)
          label2:SetText('|cffa0a0a0Kills:|r')
          label2:SetShadowOffset(1, -1)
          label2:SetShadowColor(0, 0, 0, 0.8)

          local value2 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          value2:SetPoint('LEFT', label2, 'RIGHT', 4, 0)
          value2:SetPoint('RIGHT', row, 'RIGHT', -4, 0)
          value2:SetJustifyH('RIGHT')
          value2:SetText('|cffffffff' .. formatStat(totalBossKills) .. '|r')
          value2:SetShadowOffset(1, -1)
          value2:SetShadowColor(0, 0, 0, 0.8)

          -- Deaths row
          local label3 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          label3:SetPoint('TOPLEFT', label2, 'BOTTOMLEFT', 0, -statsGap)
          label3:SetJustifyH('LEFT')
          label3:SetWidth(labelWidth)
          label3:SetText('|cffa0a0a0Deaths:|r')
          label3:SetShadowOffset(1, -1)
          label3:SetShadowColor(0, 0, 0, 0.8)

          local value3 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          value3:SetPoint('LEFT', label3, 'RIGHT', 4, 0)
          value3:SetPoint('RIGHT', row, 'RIGHT', -4, 0)
          value3:SetJustifyH('RIGHT')
          value3:SetText('|cffffffff' .. formatStat(totalBossDeaths) .. '|r')
          value3:SetShadowOffset(1, -1)
          value3:SetShadowColor(0, 0, 0, 0.8)

          if totalBossKills > 1 then
            -- Very pale green border for bosses with multiple kills
            row:SetBackdropBorderColor(0.7, 0.95, 0.7, 1)
          end

          previousRow = row
        end
      end
    end

    local minHeight = 130
    local computedHeight = 100 + (bossCount * (rowHeight + rowSpacing))
    content:SetHeight(math.max(minHeight, computedHeight))

    local section = addSection(header, content, dungeonKey)
    makeHeaderClickable(section)
    return section
  end

  for _, instance in ipairs(instances) do
    CreateInstanceSection(instance)
  end

  updateSectionPositions()

  return {
    updateSectionPositions = updateSectionPositions,
    sections = sections,
  }
end
