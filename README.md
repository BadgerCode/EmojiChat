Font method:
* https://github.com/Facepunch/garrysmod-requests/issues/47
* http://wiki.garrysmod.com/page/surface/CreateFont
* http://wiki.garrysmod.com/page/Structures/FontData
* Doesn't support above unicode U+FFFF (no emoji :()



HTML method:
* http://wiki.garrysmod.com/page/Category:DHTML
* http://wiki.garrysmod.com/page/Panel/OpenURL
* http://wiki.garrysmod.com/page/Panel/SetHTML
* http://wiki.garrysmod.com/page/DHTML/QueueJavascript

Unicode emoji fonts:
* https://demos.emojione.com/latest/jstoimage.html



General chatbox stuff:
* https://wiki.garrysmod.com/page/Advanced_Chatbox
* https://github.com/Exho1/eChat/blob/master/lua/autorun/cl_chat.lua


TODO: 
* Replace text entry with HTML version
    * Will need to call out to Lua
        * eChat.entry.OnTextChanged
* Tab auto-complete emoji
    * Show selectable suggestions (like discord)
* Tab auto-complete player name
    * Maybe try to fix the "space in name" problem
    * And non-typeable characters problem
* Make sure basics work- ctrl+a/c/v/x
* Make double quotes work in this version
* Font looks awful over bright lights
* Make entity messages a blue colour
* Future
    * Support for server-custom emojis?
    * Allow styling tags?
        * Could allow some basic markdown
    * Maybe show history before player joined?
    * How will this hook into other chat systems?
        * Tags etc
    * Update emojione version
* Tidy up
    * Sort out all the logic which builds the text box if it doesn't exist already
        * Just update the state and rely on the text box using the current state when it is drawn
    * Separate modules
        * Default chat/hooks override
        * GUI setup
        * GUI event callbacks
    * Rename that oldPaint2 stuff
    * better logic to detect when a timestamp should be added (always?)