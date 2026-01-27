local GLOBAL_DUEL_WINNER_KNOCKOUT = getglobal('DUEL_WINNER_KNOCKOUT')
local GLOBAL_DUEL_WINNER_RETREAT = getglobal('DUEL_WINNER_RETREAT')

local DUEL_WIN_PATTERN = GLOBAL_DUEL_WINNER_KNOCKOUT:gsub('%%1%$s', '(.+)'):gsub('%%2%$s', '(.+)')
local DUEL_WIN_RETREAT_PATTERN =
  GLOBAL_DUEL_WINNER_RETREAT:gsub('%%1%$s', '(.+)'):gsub('%%2%$s', '(.+)')

function DuelTracker(msg)
  if not CharacterStats then return end
  local myName = UnitName('player')

  local winner, loser = msg:match(DUEL_WIN_PATTERN)
  local retreatLoser, retreatWinner = msg:match(DUEL_WIN_RETREAT_PATTERN)

  local duelsWon = CharacterStats:GetStat('duelsWon') or 0
  local duelsLost = CharacterStats:GetStat('duelsLost') or 0
  local ourDuelSeen = false

  if winner and loser then
    if winner == myName then
      ourDuelSeen = true
      duelsWon = duelsWon + 1
      CharacterStats:UpdateStat('duelsWon', duelsWon)
    elseif loser == myName then
      ourDuelSeen = true
      duelsLost = duelsLost + 1
      CharacterStats:UpdateStat('duelsLost', duelsLost)
    end
  elseif retreatLoser and retreatWinner then
    if retreatLoser == myName then
      ourDuelSeen = true
      duelsLost = duelsLost + 1
      CharacterStats:UpdateStat('duelsLost', duelsLost)
    elseif retreatWinner == myName then
      ourDuelSeen = true
      duelsWon = duelsWon + 1
      CharacterStats:UpdateStat('duelsWon', duelsWon)
    end
  end

  if ourDuelSeen then
    local total = duelsWon + duelsLost
    if total > 0 then
      CharacterStats:UpdateStat('duelsWinPercent', (duelsWon / total) * 100)
      CharacterStats:UpdateStat('duelsTotal', total)
    end
  end
end
