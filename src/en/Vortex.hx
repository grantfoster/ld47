package en;

class Vortex extends Entity {
	public static var ALL : Array<Vortex> = [];
	var data : Entity_Vortex;
	var content : Null<Enum_ItemType>;
	var itemOrigin : Null<CPoint>;
	var ignoreItem : Null<en.Item>;

	public function new(e:Entity_Vortex) {
		super(e.cx, e.cy);
		gravityMul = 0;
		ALL.push(this);
		darkMode = Stay;
		data = e;
		game.scroller.add(spr, Const.DP_BG);
	}

	override function postUpdate() {
		super.postUpdate();
		if( !cd.hasSetS("fx",0.06) )
			fx.vortex(
				footX, footY,
				cd.has("error") ? 9 : content==null ? 12 : 5,
				cd.has("error") ? 0xff2200 : content==null ? 0x00ff00 : 0x8b95cf
			);
		spr.visible = false;
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function onLight() {
		super.onLight();

		if( content!=null ) {
			var e = new en.Item(cx,cy, content);
			e.origin = itemOrigin==null ? null : itemOrigin.clone();
			e.dx = rnd(0.01,0.02,true);
			e.dy = -0.1;
			ignoreItem = e;
			Assets.SLIB.vortexIn(1);
			game.fx.vortexOut(centerX, centerY, 0x8b95cf);
			itemOrigin = null;
			content = null;
		}
	}

	override function update() {
		super.update();

		if( ignoreItem!=null && !ignoreItem.destroyed && distCase(ignoreItem)>2.5 )
			ignoreItem = null;

		if( content==null  )
			for(e in en.Item.ALL)
				if( e.isAlive() && distCase(e)<=1.6 && e!=ignoreItem && e.cd.has("recentThrow") && !e.isGrabbedByHero() ) {
					switch e.type {
						case Ammo:
						case DiamondDup:
							cd.setS("error",1);

						case DoorKey, Diamond:
							if( e.type==Diamond ) {
								content = DiamondDup;
								itemOrigin = null;
							}
							else {
								content = e.type;
								itemOrigin = e.origin.clone();
							}
							Assets.SLIB.vortexOut1(1);
							game.delayer.addS(()->game.popText(centerX, centerY, "Item captured", 0x9ed5ff), 0.4);
							e.destroy();
					}
				}
	}
}