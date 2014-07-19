class GUI.Pref extends com.Components.WindowComponentContent
{
	var m_Group:Array;
	var _redraw=false;
	
	var m_OptionList;

	public function Pref()
	{
		super();
		m_Group=new Array;
	}

	function configUI()
	{
		this.m_Background.onPress = function()
		{
		};
		Selection.captureFocus(false);
		Selection.disableFocusAutoRelease = false;
		this.m_ContentContainer = this.createEmptyMovieClip("m_ContentContainer",this.getNextHighestDepth());
		this.m_ContentContainer._x = 4;
		this.m_ContentContainer._y = 4;
		Redraw();
	}

	function Redraw()
	{
		if(this.m_ContentContainer.m_OptionList)
      	{
         this.m_ContentContainer.m_OptionList.removeMovieClip();
      	}
		if(this.m_Scrollbar) {
			this.m_Scrollbar.removeMovieClip();
		}
      if(this.m_ContentContainer.mask)
      {
         this.m_ContentContainer.setMask(null);
         this.m_ContentContainer.mask.removeMovieClip();
      }
		m_OptionList = this.m_ContentContainer.createEmptyMovieClip("m_OptionList", this.getNextHighestDepth());
		m_OptionList.addEventListener("scroll",this,"OnScrollbarUpdate");
		
		for(var i=0; i<m_Options.length; i++)
		{
			var group=m_Options[i];
			var clip = m_OptionList.createEmptyMovieClip("OptGroup_"+i, m_OptionList.getNextHighestDepth());
			var label = clip.createTextField("label", clip.getNextHighestDepth(), 0, 0, 0, 0);
			label.autoSize = "left";
			label.setNewTextFormat(HEADLINE);
			label.embedFonts = true;
			label.text = group.name;
	
	
			m_Group[i]=new Object();
			m_Group[i].clip=clip;
			m_Group[i].items=new Array;
			for (var j = 0; j < group.opts.length; j++) {
				var item:MovieClip = clip.createEmptyMovieClip("item_"+j, clip.getNextHighestDepth());
				addItem(item, group.opts[j]);
				m_Group[i].items[j]=item;
			}
		}
		
		Layout();
	
		var h = this.m_ContentSize.y - this._y;
		com.GameInterface.ProjectUtils.SetMovieClipMask(m_OptionList,this.m_ContentContainer,h);
		this.m_Scrollbar = this.m_ContentContainer.attachMovie("ScrollBar", "m_Scrollbar", this.m_ContentContainer.getNextHighestDepth());
		this.m_Scrollbar._y = 0;
		this.m_Scrollbar._x = this.m_ContentSize.x-15;
		this.m_Scrollbar.setScrollProperties(h,0,m_OptionList._height - h);
		this.m_Scrollbar._height = h;
		this.m_Scrollbar.addEventListener("scroll",this,"OnScrollbarUpdate");
		this.m_Scrollbar.position = 0;
		this.m_Scrollbar.trackMode = "scrollPage";
		this.m_Scrollbar.trackScrollPageSize = h;
		this.m_Scrollbar.disableFocus = true;
		Mouse.addListener(this);
	}
	
	function Layout()
	{
		var y:Number = 0;
		for(var i=0; i<m_Options.length; i++)
		{
			var group=m_Group[i];
			for (var j = 0; j < group.items.length; j++) {
				var item=group.items[j];
				item._y = j * 18 + 20;
				item._x = 10;
				
				item.input._x= this.m_ContentSize.x-70
			}
			group.clip._y = y;
			y += group.clip._height + 10;
		}
	}
	
	function onEnterFrame()
   {
      if(this._redraw)
      {
         this.Redraw();
         this._redraw = false;
      }
   }
	
	function SetSize(width, height)
	{
//		super.SetSize(width, height);
		this.m_ContentSize = new flash.geom.Point(width, height);
		this.SignalSizeChanged.Emit();
		
		this._redraw=true;
	}
	function GetSize()
	{
		return this.m_ContentSize;
	}
	
	function addItem(item:MovieClip, opt:Object)
	{
		var label = item.createTextField("label", item.getNextHighestDepth(), 0, 0, m_ContentSize.x-48, 18);
		label.setNewTextFormat(STANDARD_FONT);
		label.embedFonts = true;
		label.text = opt.name;
	
		var input = item.createTextField("input", item.getNextHighestDepth(), m_ContentSize.x-50, 0, 40, 18);
		input.setNewTextFormat(STANDARD_FONT);
		input.type = "input";
		input.border = true;
		input.borderColor = 10790052;
		input.background = true;
		input.backgroundColor = 3158064;
		input.text = opt.value;
		if(opt.hasOwnProperty("update")) {
			input.onChanged=function() {
				opt.update(input.text);
			};
		}
		// TODO check type
		if(opt.type=="Integer") {
			}
	}
	function OnScroll(event) {
		this.m_ContentContainer.m_Option._y-=10;
		Listthis.m_Scrollbar.position -= 10;
	}
	function OnScrollbarUpdate(event)
	{
		var _loc4_ = event.target;
		var _loc2_ = event.target.position;
		this.m_ContentContainer.m_OptionList._y = 0 - _loc2_;
		Selection.setFocus(null);
	}
}