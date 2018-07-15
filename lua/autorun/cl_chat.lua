----// eChat //----
-- Author: Exho (obviously), Tomelyr, LuaTenshi
-- Version: 4/12/15

if SERVER then
	AddCSLuaFile()
	return
end

TEXTENTRYMODE_GLOBAL = 1
TEXTENTRYMODE_TEAM = 2
TEXTENTRYMODE_CONSOLE = 3

eChat = {
	html = {},
	SelectedTextEntryMode = TEXTENTRYMODE_GLOBAL
}

eChat.config = {
	timeStamps = true,
	position = 1,	
	fadeTime = 12,
}

surface.CreateFont( "eChat_18", {
	font = "Roboto Lt",
	size = 18,
	weight = 500,
	antialias = true,
	shadow = true,
	extended = true,
} )

--// Prevents errors if the script runs too early, which it will
if not GAMEMODE then
	hook.Remove("Initialize", "echat_init")
	hook.Add("Initialize", "echat_init", function()
		include("autorun/cl_chat.lua")
		print("GM init")
		eChat.buildBox()
	end)
	return
end

--// Builds the chatbox but doesn't display it
function eChat.buildBox()
	print("Running buildbox")
	eChat.frame = vgui.Create("DFrame")
	eChat.frame:SetSize( ScrW()*0.375, ScrH()*0.25 )
	eChat.frame:SetTitle("")
	eChat.frame:ShowCloseButton( false )
	eChat.frame:SetDraggable( true )
	eChat.frame:SetSizable( true )
	eChat.frame:SetPos( ScrW()*0.0116, (ScrH() - eChat.frame:GetTall()) - ScrH()*0.177)
	eChat.frame:SetMinWidth( 300 )
	eChat.frame:SetMinHeight( 100 )
	eChat.frame.Paint = function( self, w, h )
		eChat.blur( self, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )
	end
	eChat.oldPaint = eChat.frame.Paint
	eChat.frame.Think = function()
		if input.IsKeyDown( KEY_ESCAPE ) then
			eChat.hideBox()
		end
	end
	
	local serverName = vgui.Create("DLabel", eChat.frame)
	serverName:SetText( GetHostName() )
	serverName:SetFont( "eChat_18")
	serverName:SizeToContents()
	serverName:SetPos( 5, 4 )
	
	local settings = vgui.Create("DButton", eChat.frame)
	settings:SetText("Settings")
	settings:SetFont( "eChat_18")
	settings:SetTextColor( Color( 230, 230, 230, 150 ) )
	settings:SetSize( 70, 25 )
	settings:SetPos( eChat.frame:GetWide() - settings:GetWide(), 0 )
	settings.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
	end
	settings.DoClick = function( self )
		eChat.openSettings()
	end

	eChat.chatLog = vgui.Create( "DHTML" , eChat.frame )
	eChat.chatLog:SetSize( eChat.frame:GetWide() - 10, eChat.frame:GetTall() - 40 )
	eChat.chatLog:SetPos( 5, 30 )
	eChat.chatLog.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
	end
	eChat.oldPaint2 = eChat.chatLog.Paint
	eChat.chatLog:SetVisible( true )
	eChat.chatLog:OpenURL("http://localhost/~michael/emojichat/emojichat.html?cachebuster=" .. os.time())
	eChat.chatLog:SetAllowLua( true )
	UpdateFadeTime()
	
	eChat.hideBox()
end

--// Hides the chat box but not the messages
function eChat.hideBox()
	eChat.frame.Paint = function() end
	eChat.chatLog.Paint = function() end
	
	SetTextOutputInactive()
	ScrollToTextEnd()
	
	-- Hide the chatbox except the log
	local children = eChat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == eChat.frame.btnMaxim or pnl == eChat.frame.btnClose or pnl == eChat.frame.btnMinim then continue end
		
		if pnl != eChat.chatLog then
			pnl:SetVisible( false )
		end
	end
	
	-- Give the player control again
	eChat.frame:SetMouseInputEnabled( false )
	eChat.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )
	
	-- We are done chatting
	gamemode.Call("FinishChat")
end

--// Shows the chat box
function eChat.showBox()
	-- Draw the chat box again
	eChat.frame.Paint = eChat.oldPaint
	eChat.chatLog.Paint = eChat.oldPaint2
	
	SetTextOutputActive()
	
	-- Show any hidden children
	local children = eChat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == eChat.frame.btnMaxim or pnl == eChat.frame.btnClose or pnl == eChat.frame.btnMinim then continue end
		
		pnl:SetVisible( true )
	end
	
	-- MakePopup calls the input functions so we don't need to call those
	eChat.frame:MakePopup()
	eChat.chatLog:RequestFocus()
	
	-- Make sure other addons know we are chatting
	gamemode.Call("StartChat")
end

--// Opens the settings panel
function eChat.openSettings()
	eChat.hideBox()
	
	eChat.frameS = vgui.Create("DFrame")
	eChat.frameS:SetSize( 400, 300 )
	eChat.frameS:SetTitle("")
	eChat.frameS:MakePopup()
	eChat.frameS:SetPos( ScrW()/2 - eChat.frameS:GetWide()/2, ScrH()/2 - eChat.frameS:GetTall()/2 )
	eChat.frameS:ShowCloseButton( true )
	eChat.frameS.Paint = function( self, w, h )
		eChat.blur( self, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 200 ) )
		
		draw.RoundedBox( 0, 0, 0, w, 25, Color( 80, 80, 80, 100 ) )
		
		draw.RoundedBox( 0, 0, 25, w, 25, Color( 50, 50, 50, 50 ) )
	end
	
	local serverName = vgui.Create("DLabel", eChat.frameS)
	serverName:SetText( "eChat - Settings" )
	serverName:SetFont( "eChat_18")
	serverName:SizeToContents()
	serverName:SetPos( 5, 4 )
	
	local label1 = vgui.Create("DLabel", eChat.frameS)
	label1:SetText( "Time stamps: " )
	label1:SetFont( "eChat_18")
	label1:SizeToContents()
	label1:SetPos( 10, 40 )
	
	local checkbox1 = vgui.Create("DCheckBox", eChat.frameS ) 
	checkbox1:SetPos(label1:GetWide() + 15, 42)
	checkbox1:SetValue( eChat.config.timeStamps )
	
	local label2 = vgui.Create("DLabel", eChat.frameS)
	label2:SetText( "Fade time: " )
	label2:SetFont( "eChat_18")
	label2:SizeToContents()
	label2:SetPos( 10, 70 )
	
	local textEntry = vgui.Create("DTextEntry", eChat.frameS) 
	textEntry:SetSize( 50, 20 )
	textEntry:SetPos( label2:GetWide() + 15, 70 )
	textEntry:SetText( eChat.config.fadeTime ) 
	textEntry:SetTextColor( color_white )
	textEntry:SetFont("eChat_18")
	textEntry:SetDrawBorder( false )
	textEntry:SetDrawBackground( false )
	textEntry:SetCursorColor( color_white )
	textEntry:SetHighlightColor( Color(52, 152, 219) )
	textEntry.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 30, 30, 30, 100 ) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	local save = vgui.Create("DButton", eChat.frameS)
	save:SetText("Save")
	save:SetFont( "eChat_18")
	save:SetTextColor( Color( 230, 230, 230, 150 ) )
	save:SetSize( 70, 25 )
	save:SetPos( eChat.frameS:GetWide()/2 - save:GetWide()/2, eChat.frameS:GetTall() - save:GetTall() - 10)
	save.Paint = function( self, w, h )
		if self:IsDown() then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 80, 80, 80, 200 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
		end
	end
	save.DoClick = function( self )
		eChat.frameS:Close()
		
		eChat.config.timeStamps = checkbox1:GetChecked() 
		UpdateFadeTime(tonumber(textEntry:GetText()))
	end
end

--// Panel based blur function by Chessnut from NutScript
local blur = Material( "pp/blurscreen" )
function eChat.blur( panel, layers, density, alpha )
	-- Its a scientifically proven fact that blur improves a script
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

local oldAddText = chat.AddText

--// Overwrite chat.AddText to detour it into my chatbox
function chat.AddText(...)
	if not eChat.chatLog then
		print("Add text build box")
		eChat.buildBox()
	end
	
	local defaultTextColour = Color(255, 255, 255, 255)
	local activeColour = Color(255, 255, 255, 255) // TODO: Default chat colour
	local textComponents = {}

	// TODO: Delete all eChat.chatLog lines
	-- Iterate through the strings and colors
	for _, obj in pairs( {...} ) do
		if type(obj) == "table" then
			activeColour = obj
		elseif type(obj) == "string"  then
			table.insert( textComponents, TextComponent(obj, activeColour))
		elseif obj:IsPlayer() then
			local ply = obj
			
			if eChat.config.timeStamps then
				table.insert( textComponents, TextComponent("["..os.date("%X").."] ", Color(130, 130, 130, 255)))
			end

			local col = GAMEMODE:GetTeamColor( obj )
			table.insert( textComponents, TextComponent(ply:Nick(), Color(col.r, col.g, col.b, 255)))
		elseif IsEntity(obj) then
			table.insert( textComponents, TextComponent(obj:GetClass(), defaultTextColour))
		end
	end

	RenderTextLine(textComponents)
end

--// Write any server notifications
hook.Remove( "ChatText", "echat_joinleave")
hook.Add( "ChatText", "echat_joinleave", function( index, name, text, type )
	if not eChat.chatLog then
		print("Chat text build box")
		eChat.buildBox()
	end
	
	if type != "chat" then
		RenderTextLine({ { text = text.."\n", colour = Color(0, 128, 255, 255) } })
		return true
	end
end)

--// Stops the default chat box from being opened
hook.Remove("PlayerBindPress", "echat_hijackbind")
hook.Add("PlayerBindPress", "echat_hijackbind", function(ply, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		if bind == "messagemode2" then 
			eChat.SelectedTextEntryMode = TEXTENTRYMODE_TEAM
		else
			eChat.SelectedTextEntryMode = TEXTENTRYMODE_GLOBAL
		end
		
		if IsValid( eChat.frame ) then
			eChat.showBox()
		else
			print("Player bind press build box")
			eChat.buildBox()
			eChat.showBox()
		end
		return true
	end
end)

--// Hide the default chat too in case that pops up
hook.Remove("HUDShouldDraw", "echat_hidedefault")
hook.Add("HUDShouldDraw", "echat_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)

 --// Modify the Chatbox for align.
local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
	return eChat.frame:GetPos()
end

function chat.GetChatBoxSize()
	return eChat.frame:GetSize()
end

chat.Open = eChat.showBox
function chat.Close(...) 
	if IsValid( eChat.frame ) then 
		eChat.hideBox(...)
	else
		print("Chat close build box")
		eChat.buildBox()
		eChat.showBox()
	end
end


function TextComponent(text, colour)
	local component = { text = text, colour = colour }
	return component
end

function RenderTextLine(textComponents)
	local json = string.JavascriptSafe(util.TableToJSON(textComponents))
	eChat.chatLog:QueueJavascript("addOutput('" .. json  .. "')")
end

function SetTextOutputActive()
	eChat.chatLog:QueueJavascript("setActive()")
end

function SetTextOutputInactive()
	eChat.chatLog:QueueJavascript("setInactive()")
end

function ScrollToTextEnd()
	eChat.chatLog:QueueJavascript("scrollToBottom()")
end

function UpdateFadeTime(durationInSeconds)
	if(durationInSeconds != nil) then
		eChat.config.fadeTime = durationInSeconds;
	end
	eChat.chatLog:QueueJavascript("setFadeTime(" .. eChat.config.fadeTime .. ")")
end

function SelectTextEntryMode(textEntryMode)
	eChat.SelectedTextEntryMode = textEntryMode
	eChat.chatLog:QueueJavascript("setTextEntryMode('" .. eChat.SelectedTextEntryMode .. "')")
end

function eChat.SendMessage(message)
	// TODO: Proper empty string check
	if string.Trim( message ) != "" then

		if eChat.SelectedTextEntryMode == TEXTENTRYMODE_TEAM then
			LocalPlayer():ConCommand("say_team \"" .. (message or "") .. "\"")

		elseif eChat.SelectedTextEntryMode == TEXTENTRYMODE_CONSOLE then
			LocalPlayer():ConCommand(message or "")

		else
			LocalPlayer():ConCommand("say \"" .. message .. "\"")

		end
	end

	SelectTextEntryMode(TEXTENTRYMODE_GLOBAL)
	eChat.hideBox()
end

function eChat.InputChange(newValue)
	gamemode.Call( "ChatTextChanged", newValue )
end

function eChat.CloseChat()
	eChat.hideBox()
	gui.HideGameUI()
end

function eChat.ChangeTextEntryMode()
	local newMode = eChat.SelectedTextEntryMode + 1
	if(newMode > TEXTENTRYMODE_CONSOLE) then
		newMode = TEXTENTRYMODE_GLOBAL
	end

	SelectTextEntryMode(newMode);
end
