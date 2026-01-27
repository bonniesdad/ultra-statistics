local jumpTrackingFrame = CreateFrame('Frame')
jumpTrackingFrame:RegisterEvent('ADDON_LOADED')

jumpTrackingFrame:SetScript('OnEvent', function(_, _, addonName)
  if addonName ~= 'UltraStatistics' then return end
  if not CharacterStats then return end

  local JumpCounter = {}
  JumpCounter.count = CharacterStats:GetStat('playerJumps') or 0
  JumpCounter.lastJump = 0
  JumpCounter.debounce = 0.75

  function JumpCounter:OnJump()
    self.count = self.count + 1
    self.lastJump = GetTime()
    CharacterStats:UpdateStat('playerJumps', self.count)
  end

  hooksecurefunc('AscendStop', function()
    if not IsFalling() then
      return
    end
    local now = GetTime()
    if not JumpCounter.lastJump or (now - JumpCounter.lastJump > JumpCounter.debounce) then
      JumpCounter:OnJump()
    end
  end)
end)


