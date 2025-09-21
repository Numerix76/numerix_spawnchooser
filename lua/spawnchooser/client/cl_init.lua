--[[ SpawnChooser --------------------------------------------------------------------------------------

SpawnChooser made by Numerix (https://steamcommunity.com/id/numerix/)

--------------------------------------------------------------------------------------------------]]
local colorline_frame = Color( 255, 255, 255, 100 )
local colorbg_frame = Color(52, 55, 64, 200)

local colorline_button = Color( 255, 255, 255, 100 )
local colorbg_button = Color(33, 31, 35, 200)
local color_hover = Color(0, 0, 0, 100)

local colorbg_buttoninfo = Color(21, 101, 192, 120)

local color_text = Color(255,255,255,255)

local function drawRectOutline( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( x, y, w, h )
end

local SpawnBasePanel = nil;

local function CloseMenu()
  if IsValid(SpawnBasePanel) then
    SpawnBasePanel:Close()
  end
end

local function OpenMenu()
  local numspawn = 0
  local AllSpawn = SpawnChooser.Settings.Spawn
  local player = LocalPlayer()

  if ( IsValid(SpawnBasePanel) ) then
    SpawnBasePanel:Close()
  end

  -- Workaround to avoid LocalPlayer() being nil because the function is called too fast
  if !player then
    timer.Create("SpawnChooser:WaitPlayer", 0.1, 0, function()
      player = LocalPlayer()

      if IsValid(player) then
        timer.Remove("SpawnChooser:WaitPlayer")
        OpenMenu()
      end
    end)

    return
  end
  
  
  local team = player:Team()

  -- Fix for singleplayer
  if !AllSpawn then
    timer.Create("SpawnChooser:WaitSettings", 0.1, 0, function()
      AllSpawn = SpawnChooser.Settings.Spawn

      if AllSpawn then
        timer.Remove("SpawnChooser:WaitSettings")
        OpenMenu()
      end
    end)

    return
  end

  SpawnBasePanel = vgui.Create( "DFrame" )
  SpawnBasePanel:SetTitle( " " )
  SpawnBasePanel:SetDraggable( false )
  SpawnBasePanel:ShowCloseButton( false )
  SpawnBasePanel:MakePopup()
  SpawnBasePanel.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, colorbg_frame )
		surface.SetDrawColor( colorline_frame )
    surface.DrawOutlinedRect( 0, 0, w , h )
  end
  
  local TextInfo = vgui.Create( "DLabel", SpawnBasePanel )
  TextInfo:SetPos( 0, 30 )
  TextInfo:SetText( SpawnChooser.GetLanguage("Choose where your adventure will begin.") )
  TextInfo:SetTextColor(color_text)
  TextInfo:SetFont("Spawn.Start.Texte")
  TextInfo:SetSize(450, 10)
  TextInfo:SetContentAlignment(5)
  
  for k, v in SortedPairs(AllSpawn, false) do
    if v.restricted == false or v.restricted[team] then
      local SelectSpawn = vgui.Create( "DButton", SpawnBasePanel )
      SelectSpawn:SetPos( 7.5, 60 + numspawn * 50 )
      SelectSpawn:SetText( k )
      SelectSpawn:SetTextColor(color_text)
      SelectSpawn:SetSize( 435, 40 )
      SelectSpawn.Paint = function( self, w, h )
        draw.RoundedBox(0, 0, 0, w, h, colorbg_button)

        surface.SetDrawColor( colorline_button )
        surface.DrawOutlinedRect( 0, 0, w, h )

        if self:IsHovered() or self:IsDown() then
          draw.RoundedBox( 0, 0, 0, w, h, color_hover )
        end
      end
      SelectSpawn.DoClick = function()
        net.Start("SpawnChooser:SetPos")
        net.WriteString(k)
        net.SendToServer()
        CloseMenu()
      end

      numspawn = numspawn + 1
    end
  end

  SpawnBasePanel:SetSize( 450, numspawn * 50 + 80 )
  SpawnBasePanel:Center()

  local NomServeur = vgui.Create( "DLabel", SpawnBasePanel )
  NomServeur:SetPos( 5, SpawnBasePanel:GetTall() - 20 )
  NomServeur:SetSize(440, 15)
  NomServeur:SetText( SpawnChooser.Settings.CommunityName ) 
  NomServeur:SetTextColor(color_text)
  NomServeur:SetFont("Spawn.Start.Texte")
  NomServeur:SetContentAlignment(6)
  
  if SpawnChooser.Settings.CommunityLink != "" then
    local ButtonInfo = vgui.Create( "DButton", SpawnBasePanel )
    ButtonInfo:SetPos( 5, SpawnBasePanel:GetTall() - 20 )
    ButtonInfo:SetText( "?" )
    ButtonInfo:SetTextColor(color_text)
    ButtonInfo:SetSize( 15, 15 )
    ButtonInfo.Paint = function( self, w, h )
      draw.RoundedBox( 0, 0, 0, w, h, colorbg_buttoninfo ) 
    end
    ButtonInfo.DoClick = function()		   
      gui.OpenURL( SpawnChooser.Settings.CommunityLink )
    end
  end
end

net.Receive( "SpawnChooser:OpenMenu", function()
  OpenMenu()
end)

net.Receive( "SpawnChooser:CloseMenu" , function ( len , ply )
  CloseMenu()
end)
