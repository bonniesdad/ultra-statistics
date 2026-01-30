local jumpTrackingFrame = CreateFrame('Frame')
jumpTrackingFrame:RegisterEvent('ADDON_LOADED')

jumpTrackingFrame:SetScript('OnEvent', function(_, _, addonName)
  if addonName ~= 'UltraStatistics' then return end
  if not CharacterStats then return end

  local JumpCounter = {}
  -- Don't cache count at ADDON_LOADED: UnitGUID('player') may be nil so we'd read wrong table. We sync from DB on each increment.
  JumpCounter.count = 0
  JumpCounter.lastJump = 0
  JumpCounter.debounce = 0.75

  function JumpCounter:OnJump()
    -- Always read current from DB so imported stats are not overwritten (avoid stale cache from ADDON_LOADED when guid was nil).
    local current = CharacterStats:GetStat('playerJumps') or 0
    self.count = current + 1
    self.lastJump = GetTime()
    CharacterStats:UpdateStat('playerJumps', self.count)
  end

  hooksecurefunc('AscendStop', function()
    if not IsFalling() then return end
    local now = GetTime()
    if not JumpCounter.lastJump or (now - JumpCounter.lastJump > JumpCounter.debounce) then
      JumpCounter:OnJump()
    end
  end)
end)
