-- SettingsTab.lua (UltraStatistics)
-- Blank placeholder tab for future settings options.

function InitializeSettingsTab(tabContents)
  local parent = tabContents and tabContents[2]
  if not parent or parent._ultraStatsInitialized then return end
  parent._ultraStatsInitialized = true

  local scroll = CreateFrame('ScrollFrame', nil, parent, 'UIPanelScrollFrameTemplate')
  scroll:SetPoint('TOPLEFT', parent, 'TOPLEFT', 18, -18)
  scroll:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -28, 18)

  local child = CreateFrame('Frame', nil, scroll)
  child:SetSize(1, 1)
  scroll:SetScrollChild(child)
end


