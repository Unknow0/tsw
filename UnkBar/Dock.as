var m_BarItems:Object;

var m_RedrawMonitor:DistributedValue;
var m_BarMonitor:DistributedValue;

var minx:Number = 75;
var margin:Number = 5;

var m_Options:Array;

var m_KnownConstraints:Archive;

function DockInit()
{
	DistributedValue.SetDValue("UnkBar_Register",undefined);
	DistributedValue.SetDValue("UnkBar_Redraw",undefined);
	DistributedValue.SetDValue("UnkBar_Loaded",false);

	m_BarItems = new Object;

	m_BarMonitor = DistributedValue.Create("UnkBar_Register");
	m_BarMonitor.SignalChanged.Connect(Register,this);

	m_RedrawMonitor = DistributedValue.Create("UnkBar_Redraw");
	m_RedrawMonitor.SignalChanged.Connect(LayoutDock,this);

	m_Options = new Array  ;

	var group:Object = new Object  ;
	group.name = "General";
	group.id="general";
	group.opts = new Array  ;
	group.opts[0] = new Object  ;
	group.opts[0].name = "Icon Spacing";
	group.opts[0].type = "Integer";
	group.opts[0].value = margin;
	group.opts[0].update=function(value) {
		margin=parseFloat(value);
		LayoutDock();
	};

	m_Options[0] = group;
	
	DistributedValue.SetDValue("UnkBar_Loaded",true);
}

function DockLoad(conf:Archive) {
	m_KnownConstraints=conf.FindEntry("knownConstrains");
}

function DockSave(conf:Archive) {
	var c:Archive=new Archive;
	for(var id in m_BarItems) {
		c.AddEntry(id, m_BarItems[id].x);
	}
	conf.AddEntry("knownConstrains", c);
}

function Register():Void
{
	var loc = DistributedValue.GetDValue("UnkBar_Register");
	if (loc) {
		var arr = loc.split("|");
		var id = arr[0];
		if (! m_BarItems.hasOwnProperty(id)) {
			var name = arr[1];
			var icon = eval(arr[2]);
			var opts = eval(arr[3]);
			if (icon) {
				doRegister(id,name,icon,opts);
			}
		}
	}
}

function doRegister(id:String,name:String,icon:MovieClip,opts:Array):Void
{
	var item = new Object  ;
	item.icon = icon;
	icon.swapDepth(getNextHighestDepth());
	m_BarItems[id] = item;
	item.icon._visible = true;
	
	var c=m_KnownConstrains.FindEntry(id);
	m_BarItems[id].x=c?c:0;

	var group = new Object  ;
	group.name = name;
	group.opts=new Array;
	group.opts[0]=new Object;
	group.opts[0].name="Position";
	group.opts[0].type="Integer";
	group.opts[0].value=m_BarItems[id].x;
	group.opts[0].update=function(value) {
		m_BarItems[id].x=parseInt(value);
		LayoutDock();
	};
	
	if (opts!=undefined) {
		for(i=0; i<opts.length; i++) {
			group.opts.push(opts[i]);
		}
	}
	
	m_Options.push(group);
	
	LayoutDock();
}

function LayoutDock():Void
{
	var tab:Array = new Array  ;
	for (var key:String in m_BarItems) {
		var clip = m_BarItems[key];
		if (clip.icon._visible) {
			tab.push(clip);
		}
	}
	tab.sortOn("x",Array.NUMERIC);
	var x:Number = minx;
	for (i = 0; i < tab.length; i++) {
		if (tab[i].x > x) {
			x = tab[i].x;
		}
		tab[i].icon._x = x;
		x +=  tab[i].icon._width + margin;
	}

	DistributedValue.SetDValue("UnkBar_Redraw",undefined);
}