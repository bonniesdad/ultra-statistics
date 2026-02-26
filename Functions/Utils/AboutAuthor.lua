-- Reusable About the Author component (same pattern as UltraHardcore)
-- Uses UltraHardcore texture path for profile picture so both addons look identical.

local TEXTURE_PATH = 'Interface\\AddOns\\UltraStatistics\\Textures'

function UHC_CreateAboutAuthorSection(parent, point, relativeTo, relativePoint, xOfs, yOfs, width)
  width = width or 440

  local aboutAuthorFrame = CreateFrame('Frame', nil, parent)
  aboutAuthorFrame:SetSize(width, 300)
  if point and relativeTo and relativePoint then
    aboutAuthorFrame:SetPoint(point, relativeTo, relativePoint, xOfs or 0, yOfs or 0)
  end

  local profilePictureFrame = CreateFrame('Frame', nil, aboutAuthorFrame, 'BackdropTemplate')
  profilePictureFrame:SetSize(104, 104)
  profilePictureFrame:SetPoint('TOPLEFT', aboutAuthorFrame, 'TOPLEFT', 0, 0)
  profilePictureFrame:SetBackdrop({
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    edgeSize = 2,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  profilePictureFrame:SetBackdropBorderColor(0.8, 0.6, 0.2, 1)
  local profilePicture = profilePictureFrame:CreateTexture(nil, 'ARTWORK')
  profilePicture:SetSize(100, 100)
  profilePicture:SetPoint('CENTER', profilePictureFrame, 'CENTER', 0, 0)
  profilePicture:SetTexture(TEXTURE_PATH .. '\\profile-picture.png')
  profilePicture:SetTexCoord(0, 1, 0, 1)

  local aboutAuthorTitle = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
  aboutAuthorTitle:SetPoint('LEFT', profilePictureFrame, 'RIGHT', 15, 0)
  aboutAuthorTitle:SetPoint('TOP', profilePictureFrame, 'TOP', 0, 0)
  aboutAuthorTitle:SetText('Follow the Author!')
  aboutAuthorTitle:SetTextColor(0.922, 0.871, 0.761)

  local streamsTitle = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  streamsTitle:SetPoint('TOPLEFT', aboutAuthorTitle, 'BOTTOMLEFT', 0, -8)
  streamsTitle:SetText('BonniesDadTV on Twitch')
  streamsTitle:SetTextColor(0.922, 0.871, 0.761)

  local aboutText = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  aboutText:SetPoint('TOPLEFT', profilePictureFrame, 'BOTTOMLEFT', 0, -15)
  aboutText:SetWidth(width)
  aboutText:SetText(
    'BonniesDadTV develops this addon live on Twitch and is always happy to answer any questions about the addon.\n\nFound a bug? Report bugs directly to him and he will fix them live. New suggestions are a great way to keep the addon alive, so please feel free to pop by and give yours.\n\nWant to contribute? You are more than welcome, and wouldn\'t be the first! We have built a friendly, lively community from people wanting to get involved and learn more about development and addon creation.'
  )
  aboutText:SetJustifyH('LEFT')
  aboutText:SetNonSpaceWrap(false)
  aboutText:SetTextColor(0.8, 0.8, 0.8)

  return aboutAuthorFrame
end
