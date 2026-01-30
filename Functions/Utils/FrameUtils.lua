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
  if not frame or type(frame) ~= 'table' then return end

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
  if type(opts) ~= 'table' then
    return nil
  end

  local scrollChild = opts.scrollChild
  local layout = opts.layout
  local instances = opts.instances
  local collapsedStateTable = opts.collapsedStateTable
  local onLayoutUpdated = (type(opts.onLayoutUpdated) == 'function') and opts.onLayoutUpdated or nil

  if not scrollChild or not layout or type(instances) ~= 'table' or type(
    collapsedStateTable
  ) ~= 'table' then
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

  local function ShowSpellTooltip(owner, spellId)
    if not owner or not spellId then
      return
    end
    if not GameTooltip then
      return
    end

    GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT')

    -- Prefer direct spell ID tooltip when available (Classic-era clients generally support this),
    -- but fall back to a spell hyperlink to be safe across clients.
    if GameTooltip.SetSpellByID then
      GameTooltip:SetSpellByID(tonumber(spellId))
    elseif GameTooltip.SetHyperlink then
      GameTooltip:SetHyperlink('spell:' .. tostring(spellId))
    end

    GameTooltip:Show()
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

  local function AdjustSectionContentHeight(content)
    if not content or not content.GetTop then
      return
    end

    -- This only works once the content frame is positioned (GetTop/GetBottom are nil otherwise).
    local contentTop = content:GetTop()
    if not contentTop then
      return
    end

    local minHeight = tonumber(content._ultraMinHeight) or 130
    local paddingBottom = tonumber(content._ultraPaddingBottom) or 16

    local lastBossRow = content._ultraLastBossRow
    local emptyBosses = content._ultraEmptyBosses
    local bossesTitle = content._ultraBossesTitle

    local lowest = nil
    if lastBossRow and lastBossRow.GetBottom then
      lowest = lastBossRow:GetBottom()
    elseif emptyBosses and emptyBosses.GetBottom then
      lowest = emptyBosses:GetBottom()
    elseif bossesTitle and bossesTitle.GetBottom then
      lowest = bossesTitle:GetBottom()
    end

    if lowest then
      local neededHeight = (contentTop - lowest) + paddingBottom
      content:SetHeight(math.max(minHeight, neededHeight))
    end

    -- Keep the background texture from ever rendering outside the content frame.
    local bg = content._ultraBg
    local bgHeight = tonumber(content._ultraBgHeight)
    if bg and bg.SetHeight and bgHeight then
      local ch = content:GetHeight()
      if ch then
        bg:SetHeight(math.min(bgHeight, ch))
      end
    end
  end

  local sections = {}

  local function addSection(header, content, key)
    local collapsedByDefault =
      defaultCollapsed and (collapsedStateTable[key] ~= false) or (collapsedStateTable[key] == true)
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
          -- Recalculate height after positioning so dynamic boss ability rows never clip/spill.
          AdjustSectionContentHeight(content)
          local contentHeight = content:GetHeight() or 0
          y = y - headerHeight - contentHeight - layout.SECTION_SPACING
        else
          y = y - headerHeight - layout.SECTION_SPACING
        end
      end
    end

    scrollChild:SetHeight(math.max(1, -y + 20))
    if onLayoutUpdated then
      onLayoutUpdated(scrollChild:GetHeight() or 0)
    end
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
      insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
      },
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
      insets = {
        left = 3,
        right = 3,
        top = 3,
        bottom = 3,
      },
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
    content._ultraBg = bg
    content._ultraBgHeight = bgHeight
    content._ultraMinHeight = 130
    content._ultraPaddingBottom = 16

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
    local completeTexture = 'Interface\\AddOns\\UltraStatistics\\Textures\\complete.png'
    local incompleteTexture = 'Interface\\AddOns\\UltraStatistics\\Textures\\incomplete.png'
    statusIcon:SetTexture(isCleared and completeTexture or incompleteTexture)

    local summaryLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    summaryLabel:SetPoint('TOPLEFT', content, 'TOPLEFT', 12, -10)
    summaryLabel:SetText('Summary')
    summaryLabel:SetTextColor(1, 0.82, 0, 1) -- WoW yellow/gold
    summaryLabel:SetShadowOffset(1, -1)
    summaryLabel:SetShadowColor(0, 0, 0, 0.9)

    -- Completion icon duplicated inside the dropdown content (right, vertically centered).
    local contentStatusIcon = content:CreateTexture(nil, 'OVERLAY')
    contentStatusIcon:SetSize(62, 62)
    -- Position roughly centered vertically in the summary block, between header and bosses list.
    contentStatusIcon:SetPoint('TOPRIGHT', content, 'TOPRIGHT', -16, -28)
    contentStatusIcon:SetTexture(isCleared and completeTexture or incompleteTexture)

    -- Centered status text above the icon, e.g. "Incomplete" (white) or "Cleared" + date (yellow).
    local contentStatusLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    contentStatusLabel:SetPoint('BOTTOM', contentStatusIcon, 'TOP', 0, 0)
    contentStatusLabel:SetJustifyH('CENTER')
    contentStatusLabel:SetShadowOffset(1, -1)
    contentStatusLabel:SetShadowColor(0, 0, 0, 0.9)

    local clearDateText = instance.firstClearDate
    if isCleared then
      contentStatusLabel:SetTextColor(1, 0.82, 0, 1) -- WoW yellow/gold
      if type(clearDateText) == 'string' and clearDateText ~= '' then
        contentStatusLabel:SetText('Cleared\n' .. clearDateText)
      else
        contentStatusLabel:SetText('Cleared')
      end
    else
      contentStatusLabel:SetTextColor(1, 1, 1, 1) -- White for Incomplete
      contentStatusLabel:SetText('Incomplete')
    end

    -- Summary table: labels left, values right-aligned (same style as boss rows).
    local summaryGap = 2
    local summaryLabelWidth = 140

    local sumLabel1 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    sumLabel1:SetPoint('TOPLEFT', summaryLabel, 'BOTTOMLEFT', 0, -4)
    sumLabel1:SetJustifyH('LEFT')
    sumLabel1:SetWidth(summaryLabelWidth)
    sumLabel1:SetText('|cffb0b0b0First attempt deaths:|r')
    sumLabel1:SetShadowOffset(1, -1)
    sumLabel1:SetShadowColor(0, 0, 0, 0.8)

    local sumValue1 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    sumValue1:SetPoint('LEFT', sumLabel1, 'RIGHT', 4, 0)
    sumValue1:SetJustifyH('LEFT')
    sumValue1:SetText('|cffffd100' .. formatStat(firstClearDeaths) .. '|r')
    sumValue1:SetShadowOffset(1, -1)
    sumValue1:SetShadowColor(0, 0, 0, 0.8)

    local sumLabel2 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    sumLabel2:SetPoint('TOPLEFT', sumLabel1, 'BOTTOMLEFT', 0, -summaryGap)
    sumLabel2:SetJustifyH('LEFT')
    sumLabel2:SetWidth(summaryLabelWidth)
    sumLabel2:SetText('|cffb0b0b0Clears:|r')
    sumLabel2:SetShadowOffset(1, -1)
    sumLabel2:SetShadowColor(0, 0, 0, 0.8)

    local sumValue2 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    sumValue2:SetPoint('LEFT', sumLabel2, 'RIGHT', 4, 0)
    sumValue2:SetJustifyH('LEFT')
    sumValue2:SetText('|cffffd100' .. formatStat(totalClears) .. '|r')
    sumValue2:SetShadowOffset(1, -1)
    sumValue2:SetShadowColor(0, 0, 0, 0.8)

    local sumLabel3 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    sumLabel3:SetPoint('TOPLEFT', sumLabel2, 'BOTTOMLEFT', 0, -summaryGap)
    sumLabel3:SetJustifyH('LEFT')
    sumLabel3:SetWidth(summaryLabelWidth)
    sumLabel3:SetText('|cffb0b0b0Deaths:|r')
    sumLabel3:SetShadowOffset(1, -1)
    sumLabel3:SetShadowColor(0, 0, 0, 0.8)

    local sumValue3 = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    sumValue3:SetPoint('LEFT', sumLabel3, 'RIGHT', 4, 0)
    sumValue3:SetJustifyH('LEFT')
    sumValue3:SetText('|cffffd100' .. formatStat(totalDeaths) .. '|r')
    sumValue3:SetShadowOffset(1, -1)
    sumValue3:SetShadowColor(0, 0, 0, 0.8)

    local bossesTitle = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    bossesTitle:SetPoint('TOPLEFT', sumLabel3, 'BOTTOMLEFT', 0, -10)
    bossesTitle:SetText('Bosses')
    bossesTitle:SetTextColor(1, 0.82, 0, 1) -- WoW yellow/gold
    bossesTitle:SetShadowOffset(1, -1)
    bossesTitle:SetShadowColor(0, 0, 0, 0.9)

    local bossCount = 0
    local baseRowHeight = 86
    local rowSpacing = 6
    local previousRow = nil
    local lastBossRow = nil

    if type(bosses) == 'table' and #bosses > 0 then
      for _, boss in ipairs(bosses) do
        local bossName
        local totalBossKills = 0
        local totalBossDeaths = 0
        local firstBossDeaths = 0
        local spellIds = nil

        if type(boss) == 'table' then
          bossName = boss.name or boss.title
          totalBossKills = boss.totalKills or boss.kills or 0
          totalBossDeaths = boss.totalDeaths or boss.deaths or 0
          firstBossDeaths = boss.firstClearDeaths or boss.firstDeaths or 0
          spellIds = boss.spellIds
        elseif type(boss) == 'string' then
          bossName = boss
        end

        if type(bossName) == 'string' and bossName ~= '' then
          bossCount = bossCount + 1

          local hasAbilities = type(spellIds) == 'table' and #spellIds > 0
          local rowHeight = baseRowHeight

          local row = CreateFrame('Frame', nil, content, 'BackdropTemplate')
          row:SetSize(width - 24, rowHeight)
          row:SetBackdrop({
            bgFile = 'Interface\\Buttons\\WHITE8X8',
            edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
            tile = true,
            tileSize = 8,
            edgeSize = 10,
            insets = {
              left = 2,
              right = 2,
              top = 2,
              bottom = 2,
            },
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
            'Interface\\AddOns\\UltraStatistics\\Textures\\' .. texturesRoot .. '\\' .. folderSlug .. '\\' .. bossSlug .. '.png'
          icon:SetTexture(bossTexturePath)
          icon:SetTexCoord(0, 1, 0, 1)

          local nameFS = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
          nameFS:SetPoint('TOPLEFT', icon, 'TOPRIGHT', 8, 0)
          nameFS:SetText(bossName)
          nameFS:SetTextColor(1, 0.82, 0, 1) -- WoW yellow/gold
          nameFS:SetShadowOffset(1, -1)
          nameFS:SetShadowColor(0, 0, 0, 0.9)

          local titleToDividerGap = 8
          local divider = row:CreateTexture(nil, 'BACKGROUND')
          divider:SetColorTexture(1, 1, 1, 0.15)
          divider:SetHeight(1)
          divider:SetPoint('TOPLEFT', nameFS, 'BOTTOMLEFT', 0, -titleToDividerGap)
          divider:SetPoint('RIGHT', row, 'RIGHT', -4, 0)

          -- Stats block below the title and divider: labels left, values next to labels
          local statsGap = 2
          local labelWidth = 140
          local statsTopGap = 8
          -- First attempt deaths row
          local label1 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          label1:SetPoint('TOPLEFT', divider, 'BOTTOMLEFT', 0, -statsTopGap)
          label1:SetJustifyH('LEFT')
          label1:SetWidth(labelWidth)
          label1:SetText('|cffb0b0b0First attempt deaths:|r')
          label1:SetShadowOffset(1, -1)
          label1:SetShadowColor(0, 0, 0, 0.8)

          local value1 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          value1:SetPoint('LEFT', label1, 'RIGHT', 4, 0)
          value1:SetPoint('RIGHT', row, 'RIGHT', -12, 0)
          value1:SetJustifyH('RIGHT')
          value1:SetText('|cffffd100' .. formatStat(firstBossDeaths) .. '|r')
          value1:SetShadowOffset(1, -1)
          value1:SetShadowColor(0, 0, 0, 0.8)

          -- Kills row
          local label2 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          label2:SetPoint('TOPLEFT', label1, 'BOTTOMLEFT', 0, -statsGap)
          label2:SetJustifyH('LEFT')
          label2:SetWidth(labelWidth)
          label2:SetText('|cffb0b0b0Kills:|r')
          label2:SetShadowOffset(1, -1)
          label2:SetShadowColor(0, 0, 0, 0.8)

          local value2 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          value2:SetPoint('LEFT', label2, 'RIGHT', 4, 0)
          value2:SetPoint('RIGHT', row, 'RIGHT', -12, 0)
          value2:SetJustifyH('RIGHT')
          value2:SetText('|cffffd100' .. formatStat(totalBossKills) .. '|r')
          value2:SetShadowOffset(1, -1)
          value2:SetShadowColor(0, 0, 0, 0.8)

          -- Deaths row
          local label3 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          label3:SetPoint('TOPLEFT', label2, 'BOTTOMLEFT', 0, -statsGap)
          label3:SetJustifyH('LEFT')
          label3:SetWidth(labelWidth)
          label3:SetText('|cffb0b0b0Deaths:|r')
          label3:SetShadowOffset(1, -1)
          label3:SetShadowColor(0, 0, 0, 0.8)

          local value3 = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
          value3:SetPoint('LEFT', label3, 'RIGHT', 4, 0)
          value3:SetPoint('RIGHT', row, 'RIGHT', -12, 0)
          value3:SetJustifyH('RIGHT')
          value3:SetText('|cffffd100' .. formatStat(totalBossDeaths) .. '|r')
          value3:SetShadowOffset(1, -1)
          value3:SetShadowColor(0, 0, 0, 0.8)

          -- Boss Abilities (icons + in-game tooltip)
          -- Shown below the boss image, wrapping to new lines as needed.
          if hasAbilities then
            local iconSize = 18
            local iconSpacingX = 4
            local iconSpacingY = 4
            local abilitiesTopGap = 6
            local abilitiesLeftPadding = 8
            local rowBottomPadding = 10
            local maxIcons = 40 -- safety cap; layout will wrap before this

            local abilitiesFrame = CreateFrame('Frame', nil, row)
            abilitiesFrame:SetPoint('TOPLEFT', icon, 'BOTTOMLEFT', abilitiesLeftPadding, -abilitiesTopGap)
            abilitiesFrame:SetPoint('RIGHT', row, 'RIGHT', -12, 0)
            abilitiesFrame:SetHeight(1)

            -- Compute wrapping based on available width.
            local availableWidth = (row.GetWidth and row:GetWidth()) or (width - 24)
            availableWidth = availableWidth - 4 - 12 -- left padding (icon x) + right padding
            availableWidth = availableWidth - abilitiesLeftPadding
            local perIconW = iconSize + iconSpacingX
            local iconsPerRow = math.floor((availableWidth + iconSpacingX) / perIconW)
            if not iconsPerRow or iconsPerRow < 1 then
              iconsPerRow = 1
            end

            local shown = 0
            for _, spellId in ipairs(spellIds) do
              if shown >= maxIcons then
                break
              end
              local sid = tonumber(spellId)
              if sid then
                shown = shown + 1

                local col = (shown - 1) % iconsPerRow
                local rowIdx = math.floor((shown - 1) / iconsPerRow)

                local btn = CreateFrame('Button', nil, abilitiesFrame)
                btn:SetSize(iconSize, iconSize)
                btn:SetPoint('TOPLEFT', abilitiesFrame, 'TOPLEFT', col * perIconW, -rowIdx * (iconSize + iconSpacingY))

                local tex = btn:CreateTexture(nil, 'ARTWORK')
                tex:SetAllPoints(btn)
                local iconTexture =
                  (GetSpellTexture and GetSpellTexture(sid)) or (GetSpellInfo and select(3, GetSpellInfo(sid))) or nil
                tex:SetTexture(iconTexture or 'Interface\\Icons\\INV_Misc_QuestionMark')

                btn:SetScript('OnEnter', function(self)
                  ShowSpellTooltip(self, sid)
                end)
                btn:SetScript('OnLeave', function()
                  if GameTooltip then
                    GameTooltip:Hide()
                  end
                end)
              end
            end

            local rowsUsed = math.ceil(shown / iconsPerRow)
            if rowsUsed < 1 then
              rowsUsed = 1
            end
            local gridHeight = (rowsUsed * iconSize) + ((rowsUsed - 1) * iconSpacingY)
            abilitiesFrame:SetHeight(gridHeight)

            -- Expand row height so the wrapped icon grid doesn't clip.
            local neededHeight = rowTopPadding + 64 + abilitiesTopGap + gridHeight + rowBottomPadding
            if neededHeight > rowHeight then
              rowHeight = neededHeight
              row:SetHeight(rowHeight)
            end
          end

          if totalBossKills > 0 then
            -- Very pale green border for bosses with at least one kill
            row:SetBackdropBorderColor(0.7, 0.95, 0.7, 1)
          end

          previousRow = row
          lastBossRow = row
        end
      end
    end

    -- If a dungeon/instance has no boss list, show a friendly placeholder so the panel doesn't look "empty".
    local emptyBosses = nil
    if bossCount == 0 then
      emptyBosses = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
      emptyBosses:SetPoint('TOPLEFT', bossesTitle, 'BOTTOMLEFT', 0, -8)
      emptyBosses:SetPoint('RIGHT', content, 'RIGHT', -12, 0)
      emptyBosses:SetJustifyH('LEFT')
      emptyBosses:SetTextColor(0.8, 0.8, 0.8, 1)
      emptyBosses:SetShadowOffset(1, -1)
      emptyBosses:SetShadowColor(0, 0, 0, 0.8)
      emptyBosses:SetText('Boss list not available yet for this instance.')
    end

    -- Height is finalized in updateSectionPositions() after this content frame is positioned.
    -- Set a safe initial height so early renders don't look broken.
    content:SetHeight(tonumber(content._ultraMinHeight) or 130)
    content._ultraLastBossRow = lastBossRow
    content._ultraEmptyBosses = emptyBosses
    content._ultraBossesTitle = bossesTitle

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
    getHeight = function()
      return scrollChild and (scrollChild:GetHeight() or 0) or 0
    end,
    sections = sections,
  }
end
