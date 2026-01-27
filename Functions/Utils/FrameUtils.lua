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
