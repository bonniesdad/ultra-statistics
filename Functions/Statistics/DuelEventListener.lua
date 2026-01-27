-- Listens for duel results in system chat and forwards to DuelTracker

local frame = CreateFrame('Frame')
frame:RegisterEvent('CHAT_MSG_SYSTEM')
frame:SetScript('OnEvent', function(_, _, msg)
  if type(msg) ~= 'string' then return end
  if DuelTracker then
    DuelTracker(msg)
  end
end)


