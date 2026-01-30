local spinTrackingFrame = CreateFrame('Frame')
spinTrackingFrame:RegisterEvent('ADDON_LOADED')

spinTrackingFrame:SetScript('OnEvent', function(_, _, addonName)
  if addonName ~= 'UltraStatistics' then return end
  if not CharacterStats then return end

  local SpinCounter = {}
  -- Don't cache count at ADDON_LOADED: UnitGUID('player') may be nil. We sync from DB before each increment.
  SpinCounter.count = 0

  SpinCounter.active = false
  SpinCounter.countedThisJump = false
  SpinCounter.accumulated = 0
  SpinCounter.lastFacing = nil
  SpinCounter.jumpStartTime = 0
  SpinCounter.lastStart = 0
  SpinCounter.debounce = 0.75

  local TWO_PI = 2 * math.pi
  local MIN_ACTIVE_TIME = 0.1
  local MAX_JUMP_TIME = 3.0

  local function BeginJumpSpinTracking()
    local now = GetTime()
    if SpinCounter.active then return end
    if SpinCounter.lastStart and (now - SpinCounter.lastStart) < SpinCounter.debounce then return end

    SpinCounter.active = true
    SpinCounter.countedThisJump = false
    SpinCounter.accumulated = 0
    SpinCounter.lastFacing = GetPlayerFacing()
    SpinCounter.jumpStartTime = now
    SpinCounter.lastStart = now
  end

  local function EndJumpSpinTracking()
    SpinCounter.active = false
    SpinCounter.lastFacing = nil
    SpinCounter.accumulated = 0
    SpinCounter.countedThisJump = false
    SpinCounter.jumpStartTime = 0
  end

  hooksecurefunc('AscendStop', function()
    if not IsFalling() then return end
    BeginJumpSpinTracking()
  end)

  spinTrackingFrame:SetScript('OnUpdate', function()
    if not SpinCounter.active then return end

    local now = GetTime()
    local elapsedSinceStart = now - (SpinCounter.jumpStartTime or now)
    if elapsedSinceStart > MAX_JUMP_TIME then
      EndJumpSpinTracking()
      return
    end

    local facing = GetPlayerFacing()
    if facing and SpinCounter.lastFacing then
      local delta = facing - SpinCounter.lastFacing
      if delta > math.pi then
        delta = delta - TWO_PI
      elseif delta < -math.pi then
        delta = delta + TWO_PI
      end

      SpinCounter.accumulated = SpinCounter.accumulated + math.abs(delta)

      if not SpinCounter.countedThisJump and SpinCounter.accumulated >= TWO_PI then
        SpinCounter.countedThisJump = true
        -- Sync from DB so imported stats are not overwritten (avoid stale cache from ADDON_LOADED).
        local current = CharacterStats:GetStat('player360s') or 0
        if SpinCounter.count < current then
          SpinCounter.count = current
        end
        SpinCounter.count = SpinCounter.count + 1
        CharacterStats:UpdateStat('player360s', SpinCounter.count)
      end
    end
    SpinCounter.lastFacing = facing

    if elapsedSinceStart >= MIN_ACTIVE_TIME and not IsFalling() then
      EndJumpSpinTracking()
    end
  end)
end)
