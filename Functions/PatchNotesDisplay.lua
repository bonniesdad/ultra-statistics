-- Reusable Patch Notes Display Component
-- This component can be used in multiple places (version dialog, settings info tab, etc.)

function CreatePatchNotesDisplay(parent, width, height, xOffset, yOffset)
  xOffset = xOffset or 10
  yOffset = yOffset or -10
  local scrollBarPad = 20
  local bottomPad = 10

  -- Create scrollable frame for patch notes (leave room on the right for the scrollbar)
  local patchNotesScrollFrame =
    CreateFrame('ScrollFrame', nil, parent, 'UIPanelScrollFrameTemplate')
  if width and height then
    patchNotesScrollFrame:SetSize(width, height)
    patchNotesScrollFrame:SetPoint('TOPLEFT', parent, 'TOPLEFT', xOffset, yOffset)
  else
    patchNotesScrollFrame:SetPoint('TOPLEFT', parent, 'TOPLEFT', xOffset, yOffset)
    patchNotesScrollFrame:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -(xOffset + scrollBarPad), bottomPad)
  end

  local function getContentWidth()
    local w = patchNotesScrollFrame:GetWidth()
    if w and w > 0 then
      return w
    end
    local parentW = parent:GetWidth()
    if parentW and parentW > 0 then
      return math.max(50, parentW - xOffset * 2 - scrollBarPad)
    end
    return width or 400
  end

  -- Create scroll child frame
  local patchNotesScrollChild = CreateFrame('Frame', nil, patchNotesScrollFrame)
  local contentWidth = getContentWidth()
  local contentHeight = height or 200
  patchNotesScrollChild:SetSize(contentWidth, contentHeight)
  patchNotesScrollFrame:SetScrollChild(patchNotesScrollChild)

  local contentBuilt = false

  -- Helper function to create properly formatted bullet point text
  local function createBulletText(textParent, text, noteYOffset, fontSize, textColor)
    local indentLevel = 0
    local cleanText = text

    local spaces = string.match(text, '^%s*')
    if spaces then
      indentLevel = math.floor(#spaces / 2)
    end

    local indent
    if indentLevel == 0 then
      indent = 10
    elseif indentLevel == 1 then
      indent = 30
    else
      indent = 50
    end

    local textWidth = math.max(50, contentWidth - indent)

    local textFrame = textParent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    textFrame:SetPoint('TOPLEFT', textParent, 'TOPLEFT', indent, noteYOffset)
    textFrame:SetWidth(textWidth)
    textFrame:SetJustifyH('LEFT')
    local font, _, flags = textFrame:GetFont()
    textFrame:SetFont(font, fontSize, flags)
    textFrame:SetTextColor(textColor[1], textColor[2], textColor[3])
    textFrame:SetText(cleanText)
    return textFrame
  end

  -- Generate patch notes content
  local function generatePatchNotes()
    if contentBuilt then
      return
    end
    contentWidth = getContentWidth()
    patchNotesScrollChild:SetWidth(contentWidth)

    local noteYOffset = 0

    for _, patch in ipairs(ULTRA_STATISTICS_PATCH_NOTES) do
      local versionHeader =
        patchNotesScrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      versionHeader:SetPoint('TOPLEFT', patchNotesScrollChild, 'TOPLEFT', 0, noteYOffset)
      versionHeader:SetWidth(contentWidth)
      versionHeader:SetJustifyH('LEFT')
      local font, _, flags = versionHeader:GetFont()
      versionHeader:SetFont(font, 14, flags)
      versionHeader:SetTextColor(1, 1, 0)
      versionHeader:SetText('Version ' .. patch.version .. ' (' .. patch.date .. ')')

      local headerHeight = versionHeader:GetStringHeight()
      noteYOffset = noteYOffset - headerHeight - 12

      for j, note in ipairs(patch.notes) do
        local spaces = string.match(note, '^%s*')
        local indentLevel = spaces and math.floor(#spaces / 2) or 0
        if indentLevel == 0 and j > 1 then
          noteYOffset = noteYOffset - 8
        end

        local noteText =
          createBulletText(patchNotesScrollChild, note, noteYOffset, 13, { 0.9, 0.9, 0.9 })

        local noteHeight = noteText:GetStringHeight()
        noteYOffset = noteYOffset - noteHeight - 3
      end

      noteYOffset = noteYOffset - 12
    end

    local viewHeight = patchNotesScrollFrame:GetHeight() or contentHeight
    patchNotesScrollChild:SetHeight(math.max(viewHeight, math.abs(noteYOffset) + 20))
    contentBuilt = true
  end

  patchNotesScrollFrame:SetScript('OnSizeChanged', function()
    contentWidth = getContentWidth()
    patchNotesScrollChild:SetWidth(contentWidth)
    if not contentBuilt and contentWidth > 50 then
      generatePatchNotes()
    end
  end)

  -- Build immediately when possible; otherwise OnSizeChanged will.
  if getContentWidth() > 50 then
    generatePatchNotes()
  elseif C_Timer and C_Timer.After then
    C_Timer.After(0, function()
      if not contentBuilt then
        generatePatchNotes()
      end
    end)
  end

  return patchNotesScrollFrame
end
