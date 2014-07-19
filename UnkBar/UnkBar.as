var FONT_SIZE:Number = 11;
var COLOR:Number = 0xFFFFFF;
var HEADLINE:TextFormat = new TextFormat("_Headline",FONT_SIZE,COLOR,true);
var STANDARD_FONT:TextFormat = new TextFormat("_StandardFont",FONT_SIZE,COLOR,true);

var m_Character:Character;

var m_LatencyContainer:MovieClip;
var m_PRIconContainer:MovieClip;
var m_WMIconContainer:MovieClip;
var m_BMIconContainer:MovieClip;
var m_BBIconContainer:MovieClip;
var m_AureusIconContainer:MovieClip;

var m_Window:WinComp;
var m_WindowMonitor:DistributedValue;

var m_HeigthMonitor:DistributedValue;
var m_BarMonitor:DistributedValue;

var m_EscapeNode:com.GameInterface.EscapeStackNode;
function onLoad()
{
	DockInit();
	m_EscapeNode = new com.GameInterface.EscapeStackNode  ;
	m_EscapeNode.SignalEscapePressed.Connect(SlotCloseWindow,this);

	m_LatencyContainer = createEmptyMovieClip("m_LatencyContainer",getNextHighestDepth());
	m_LatencyContainer.attachMovie("LatencyIcon","m_LatencyIcon",m_LatencyContainer.getNextHighestDepth());
	var label:TextField = m_LatencyContainer.createTextField("m_Label",m_LatencyContainer.getNextHighestDepth(),0,0,0,0);
	label.autoSize = "left";
	label.setNewTextFormat(STANDARD_FONT);
	label.embedFonts = true;
	label.text = "42";

	m_PRIconContainer = createEmptyMovieClip("m_PRIconContainer",getNextHighestDepth());
	m_PRIconContainer.attachMovie("PaxRomana","m_PRIcon",m_PRIconContainer.getNextHighestDepth());
	label = m_PRIconContainer.createTextField("m_Label",m_PRIconContainer.getNextHighestDepth(),0,0,0,0);
	label.autoSize = "left";
	label.setNewTextFormat(STANDARD_FONT);
	label.embedFonts = true;

	m_WMIconContainer = createEmptyMovieClip("m_WMIconContainer",getNextHighestDepth());
	m_WMIconContainer.attachMovie("T91","m_WMIcon",m_WMIconContainer.getNextHighestDepth());
	label = m_WMIconContainer.createTextField("m_Label",m_WMIconContainer.getNextHighestDepth(),0,0,0,0);
	label.autoSize = "left";
	label.setNewTextFormat(STANDARD_FONT);
	label.embedFonts = true;

	m_BMIconContainer = createEmptyMovieClip("m_BMIconContainer",getNextHighestDepth());
	m_BMIconContainer.attachMovie("T90","m_BMIcon",m_BMIconContainer.getNextHighestDepth());
	label = m_BMIconContainer.createTextField("m_Label",m_BMIconContainer.getNextHighestDepth(),0,0,0,0);
	label.autoSize = "left";
	label.setNewTextFormat(STANDARD_FONT);
	label.embedFonts = true;

	m_BBIconContainer = createEmptyMovieClip("m_BBIconContainer",getNextHighestDepth());
	m_BBIconContainer.attachMovie("T200","m_BBIcon",m_BBIconContainer.getNextHighestDepth());
	label = m_BBIconContainer.createTextField("m_Label",m_BBIconContainer.getNextHighestDepth(),0,0,0,0);
	label.autoSize = "left";
	label.setNewTextFormat(STANDARD_FONT);
	label.embedFonts = true;

	m_AureusIconContainer = createEmptyMovieClip("m_AureusIconContainer",getNextHighestDepth());
	m_AureusIconContainer.attachMovie("T51","m_AureusIcon",m_AureusIconContainer.getNextHighestDepth());
	label = m_AureusIconContainer.createTextField("m_Label",m_AureusIconContainer.getNextHighestDepth(),0,0,0,0);
	label.autoSize = "left";
	label.setNewTextFormat(STANDARD_FONT);
	label.embedFonts = true;

	m_LatencyContainer.onPress = function() { };
	m_LatencyContainer.onPress = function() { };

	m_Latency = 0;

	ClientServerPerfTracker.SignalLatencyUpdated.Connect(SlotLatencyUpdated,this);
	SlotLatencyUpdated(ClientServerPerfTracker.GetLatency());

	m_HeigthMonitor = DistributedValue.Create("UnkBar_Height");
	m_HeigthMonitor.SignalChanged.Connect(ResizeIcons,this);

	m_BarMonitor = DistributedValue.Create("UnkBar_Loaded");
	m_BarMonitor.SignalChanged.Connect(RegisterIcons,this);

	DistrubutedValue.SetDValue("UnkBar_Window",false);
	m_WindowMonitor = DistributedValue.Create("UnkBar_Window");
	m_WindowMonitor.SignalChanged.Connect(windowStateChanged,this);

	RegisterIcons();
	setTimeout(delayedInit,250);
}

function OnModuleActivated(config:Archive)
{
	DockLoad(config);

	m_Character = Character.GetClientCharacter();
	m_Character.SignalTokenAmountChanged.Connect(SlotTokenAmountChanged,this);

	m_AureusIconContainer.m_Label.text = m_Character.GetTokens(_global.Enums.Token.e_Scenario_Token);
	m_BBIconContainer.m_Label.text = m_Character.GetTokens(_global.Enums.Token.e_Heroic_Token);
	m_BMIconContainer.m_Label.text = m_Character.GetTokens(_global.Enums.Token.e_Major_Anima_Fragment);
	m_WMIconContainer.m_Label.text = m_Character.GetTokens(_global.Enums.Token.e_Minor_Anima_Fragment);
	m_PRIconContainer.m_Label.text = m_Character.GetTokens(_global.Enums.Token.e_Cash);
	LayoutDock();
}

function delayedInit()
{
	m_Window = attachMovie("UnkWindow","m_Window",getNextHighestDepth());
	m_Window.SetPadding(10);
	m_Window.SetTitle("UnkBar Information Overload");
	m_Window.SignalClose.Connect(SlotCloseWindow,this);
	m_Window.SetContent("UnkPrefContent");
	m_Window.ShowFooter(false);
	m_Window.ShowResizeButton(true);
	m_Window.ShowStroke(true);
	m_Window._visible = false;
	m_Window._x = 100;
	m_Window._y = 50;
}
function OnModuleDeactivated()
{
	var conf:Archive = new Archive  ;
	DockSave(conf);
	return conf;
}
function onUnload():Void
{
}

function ResizeIcons()
{
	var h = DistributedValue.GetDValue("UnkBar_Height");

	var scale = h / m_LatencyContainer.m_LatencyIcon._height;
	m_LatencyContainer.m_LatencyIcon._width = m_LatencyContainer.m_LatencyIcon._width * scale;
	m_LatencyContainer.m_LatencyIcon._height = m_LatencyContainer.m_LatencyIcon._height * scale;
	m_LatencyContainer.m_Label._x = m_LatencyContainer.m_LatencyIcon._width + 2;

	scale = h / m_PRIconContainer.m_PRIcon._height;
	m_PRIconContainer.m_PRIcon._width = m_PRIconContainer.m_PRIcon._width * scale;
	m_PRIconContainer.m_PRIcon._height = m_PRIconContainer.m_PRIcon._height * scale;
	m_PRIconContainer.m_Label._x = m_PRIconContainer.m_PRIcon._width + 2;

	scale = h / m_WMIconContainer.m_WMIcon._height;
	m_WMIconContainer.m_WMIcon._width = m_WMIconContainer.m_WMIcon._width * scale;
	m_WMIconContainer.m_WMIcon._height = m_WMIconContainer.m_WMIcon._height * scale;
	m_WMIconContainer.m_Label._x = m_WMIconContainer.m_WMIcon._width + 2;

	scale = h / m_BMIconContainer.m_BMIcon._height;
	m_BMIconContainer.m_BMIcon._width = m_BMIconContainer.m_BMIcon._width * scale;
	m_BMIconContainer.m_BMIcon._height = m_BMIconContainer.m_BMIcon._height * scale;
	m_BMIconContainer.m_Label._x = m_BMIconContainer.m_BMIcon._width + 2;

	scale = h / m_BBIconContainer.m_BBIcon._height;
	m_BBIconContainer.m_BBIcon._width = m_BBIconContainer.m_BBIcon._width * scale;
	m_BBIconContainer.m_BBIcon._height = m_BBIconContainer.m_BBIcon._height * scale;
	m_BBIconContainer.m_Label._x = m_BBIconContainer.m_BBIcon._width + 2;

	scale = h / m_AureusIconContainer.m_AureusIcon._height;
	m_AureusIconContainer.m_AureusIcon._width = m_AureusIconContainer.m_AureusIcon._width * scale;
	m_AureusIconContainer.m_AureusIcon._height = m_AureusIconContainer.m_AureusIcon._height * scale;
	m_AureusIconContainer.m_Label._x = m_AureusIconContainer.m_AureusIcon._width + 2;
}

function RegisterIcons()
{
	ResizeIcons();

	latencyOpt = new Array  ;
	latencyOpt[0] = new Object  ;
	latencyOpt[0].name = "Show Icon";
	latencyOpt[0].type = "Boolean";
	latencyOpt[0].value = true;

	latencyOpt[1] = new Object  ;
	latencyOpt[1].name = "Show Color";
	latencyOpt[1].type = "Boolean";
	latencyOpt[1].value = false;

	doRegister("ping","Latency",m_LatencyContainer,latencyOpt);

	doRegister("paxRomana","Pax Romana",m_PRIconContainer,undefined);
	doRegister("whiteMark","White Mark",m_WMIconContainer,undefined);
	doRegister("blackMark","Black Mark",m_BMIconContainer,undefined);
	doRegister("blackBulion","Black Bulion",m_BBIconContainer,undefined);
	doRegister("aureus","Aureus",m_AureusIconContainer,undefined);
}

function SlotLatencyUpdated(latency:Number):Void
{
	var newStr=Format.Printf("%d",latency * 1000) + " ms";
	var redwraw=newStr.length>m_LatencyContainer.m_Label.text.length;
	m_LatencyContainer.m_Label.text = newStr;
	m_LatencyContainer.m_LatencyIcon.m_LatencyBar1._visible = true;
	m_LatencyContainer.m_LatencyIcon.m_LatencyBar2._visible = latency < 0.5;
	m_LatencyContainer.m_LatencyIcon.m_LatencyBar3._visible = latency < 0.15;
	m_LatencyContainer.m_LatencyIcon.m_LatencyBar4._visible = latency < 0.05;

	if (redraw) {
		LayoutDock();
	}
}

function formatAmount(amount)
{
	var val = int(amount);
	var str:String = "";
	while ((val > 1000))
	{
		str = " " + val % 1000 + str;
		val /=  1000;
	}
	return val + str;
}

function SlotTokenAmountChanged(tokenId,newAmount,oldAmount)
{
	var redraw = false;
	var amount = formatAmount(newAmount);
	switch (tokenId) {
		case _global.Enums.Token.e_Cash :
			if (m_PRIconContainer.m_Label.text.length < amount.length) {
				redraw = true;
			}
			m_PRIconContainer.m_Label.text = amount;
			break;
		case _global.Enums.Token.e_Heroic_Token :
			if (m_BBIconContainer.m_Label.text.length < amount.length) {
				redraw = true;
			}
			m_BBIconContainer.m_Label.text = amount;
			break;
		case _global.Enums.Token.e_Major_Anima_Fragment :
			if (m_BMIconContainer.m_Label.text.length < amount.length) {
				redraw = true;
			}
			m_BMIconContainer.m_Label.text = amount;
			break;
		case _global.Enums.Token.e_Minor_Anima_Fragment :
			if (m_WMIconContainer.m_Label.text.length < amount.length) {
				redraw = true;
			}
			m_WMIconContainer.m_Label.text = amount;
			break;
		case _global.Enums.Token.e_Scenario_Token :
			if (m_AureusIconContainer.m_Label.text.length < amount.length) {
				redraw = true;
			}
			m_AureusIconContainer.m_Label.text = amount;
			break;
	}
	if (redraw) {
		LayoutDock();
	}
}

function windowStateChanged()
{
	if (DistributedValue.GetDValue("UnkBar_Window")) {
		m_Window._visible = true;
		com.GameInterface.EscapeStack.Push(m_EscapeNode);
	}
	else {
		m_Window._visible = false;
	}
}
function SlotCloseWindow()
{
	DistributedValue.SetDValue("UnkBar_Window",false);
}