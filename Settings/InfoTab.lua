-- Info Tab Content
-- Initialize Info Tab when called
function UltraStatistics_InitializeInfoTab(tabContents)
  if not tabContents or not tabContents[4] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[4].initialized then return end

  -- Mark as initialized
  tabContents[4].initialized = true

  -- Philosophy text (at top, moved down by 30)
  local philosophyText = tabContents[4]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  philosophyText:SetPoint('TOP', tabContents[4], 'TOP', 0, -73)
  philosophyText:SetWidth(475)
  philosophyText:SetText(
    'Ultra Statistics\nVersion: ' .. (C_AddOns.GetAddOnMetadata(
      'UltraStatistics',
      'Version'
    ) or '?')
  )
  philosophyText:SetJustifyH('CENTER')
  philosophyText:SetNonSpaceWrap(true)

  -- Bug report text
  local bugReportText = tabContents[4]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  bugReportText:SetPoint('TOP', philosophyText, 'BOTTOM', 0, -10)
  bugReportText:SetText(
    'Found a bug or have suggestions?\n\nJoin the developers discord community to have your say on the future of this addon!'
  )
  bugReportText:SetJustifyH('CENTER')
  bugReportText:SetTextColor(0.95, 0.95, 0.9)
  bugReportText:SetWidth(475)
  bugReportText:SetNonSpaceWrap(true)

  -- Discord invite button (opens dialog with copyable invite link)
  local discordButton = CreateFrame('Button', nil, tabContents[4], 'UIPanelButtonTemplate')
  discordButton:SetSize(220, 24)
  discordButton:SetPoint('TOP', bugReportText, 'BOTTOM', 0, -10)
  discordButton:SetText('Discord Invite Link')
  discordButton:SetScript('OnClick', function()
    if _G.UHC_DiscordInvite_ShowDialog then
      _G.UHC_DiscordInvite_ShowDialog()
    end
  end)

  -- Patch Notes Section
  local patchNotesTitle = tabContents[4]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  patchNotesTitle:SetPoint('TOP', discordButton, 'BOTTOM', 0, -30)
  patchNotesTitle:SetText('Patch Notes')
  patchNotesTitle:SetJustifyH('CENTER')
  patchNotesTitle:SetTextColor(1, 1, 0.5)

  -- Patch notes panel fills remaining space so its scrollbar is usable
  local patchNotesFrame = CreateFrame('Frame', nil, tabContents[4], 'BackdropTemplate')
  patchNotesFrame:SetPoint('TOP', patchNotesTitle, 'BOTTOM', 0, -17)
  patchNotesFrame:SetPoint('LEFT', tabContents[4], 'LEFT', 0, 0)
  patchNotesFrame:SetPoint('RIGHT', tabContents[4], 'RIGHT', 0, 0)
  patchNotesFrame:SetPoint('BOTTOM', tabContents[4], 'BOTTOM', 0, 10)
  patchNotesFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  patchNotesFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  patchNotesFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  -- Fill parent; leave room for scrollbar on the right
  CreatePatchNotesDisplay(patchNotesFrame)
end
