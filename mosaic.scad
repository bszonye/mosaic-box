echo("\n\n====== MOSAIC ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

Nplayers = 6;

// game box interior
Vgame = [225, 310, 100];
Hwrap = 82;  // cover art wrap ends here, approximately

// component metrics
Hboard = 2.15;
Hmat = 2.2;  // player boards
Hgameboard = 21;  // measurement varies from 20-21
Vgameboard = [199, 305, Hgameboard];  // approximately 7.75"x12"
echo(Vgameboard=Vgameboard);
Rhex = 0.75 * INCH;  // note: hex tiles are symmetric, but the map grid is not
Vtile = [45, 70];  // Wonder, Golden Age, Civilization Achievement, Government

// available space
Hmanual = 3;  // measurement varies from 2.5-3.5
Hmain = 64;
Vside = [Vgame.x - Vgameboard.x, Vgame.y, Hceiling];  // side gap dimensions

// card metrics
// Sleeve Kings "Card Game" card sleeves
// - 0.470 measured = 0.340 unsleeved (base game)
Hcard_unsleeved = 0.34;
Hcard_sleeve = Hsleeve_kings;
Vcard = Vsleeve_card_game;
Vcard_divider = [67, 93];
Vcard_leader = [130, 92];
// deck sizes & minimum box heights
Hcard_tech = 52;
Hcard_tech_general = 32;  // 35+ box
Hcard_tech_starter = 20;  // 23+ box
Hcard_build = 20;  // 23+ box
Hcard_pop = 11;  // 14+ box
Hcard_tax = 11;  // 14+ box

// container metrics
Htray = 15;
Vtray = [72, 100, Htray];
Vtray_tech = [Vtray.x, Vtray.y, 55];
Vtray_build = [Vtray.x, Vtray.y, 25];
Vtray_leaders = [2*Vtray.x, Vtray.y, 9];
echo(Vtray_tech=Vtray_tech, Vtray_build=Vtray_build, Vtray_leaders=Vtray_leaders);
Dlid = 1;
Vtray_currency = [75, 90, 24];
echo(Vtray_currency=Vtray_currency);
Vtray_player = [144, 70, 14];
Vtray_hex = [110, 66, 20];
Vtray_unit = [65, 30, 30];
// deck box sizes
Hbox_tech_general = 35;
Hbox_tech_starter = 24.5;
Hbox_build = 24.5;
Hbox_pop = 15;
Hbox_tax = 15;
// cache tokens, fish, and start player
Hbox_cache = 14;

module card_tray_leaders(size=Vtray_leaders, cut=Dcut, color=undef) {
    vtray = size;
    well = area(vtray) - 2*area(Dwall);
    bump = (vtray.x - Vcard_leader.x) / 2 - Rint;
    colorize(color) difference() {
        prism(vtray, r=Rext);
        raise(Hfloor) prism(height=vtray.z-Hfloor+cut, r=Rint) difference() {
            square(well, center=true);
            for (i=[-1,+1]) translate([(vtray.x/2)*i, 0]) rotate(90*i)
                semistadium(r=bump);
        }
        for (i=[-1, +1]) translate([vtray.x/4*i, 0]) {
            raise(Hfloor) {
                // thumb vee
                span = Dthumb + 2*Rint;
                dmax = (well.x - span) / 4;  // maximum spread of vee at top
                amin = atan((vtray.z-Hfloor)/dmax);  // minimum vee angle
                echo(span=span, dmax=dmax, amin=amin);
                angle = max(Avee, eround(amin, Qfinal));
                translate([0, Dwall-vtray.y]/2)
                    wall_vee_cut([span, Dwall, vtray.z-Hfloor], angle=angle, cut=cut);
            }
            floor_thumb_cut(vtray, cut=cut);
        }
    }
    raise(vtray.z+Dgap) {
        if ($children) translate([-vtray.x/4, 0]) children(0);
        if (1 < $children) translate([+vtray.x/4, 0]) children(1);
    }
}

module currency_tray(size=Vtray_currency, slots=1, color=undef) {
    r = Rext;
    lip = size.z - Hfloor - 2*r;
    colorize(color) {
        scoop_tray(size=size, grid=[1, slots], rscoop=r, lip=lip);
    }
}
module currency_lid(size=Vtray_currency, wall=Dlid, gap=Dgap, color=undef) {
    well = area(size) + area(2*gap);
    shell = well + area(2*wall);
    h = size.z/2 + wall;
    colorize(color) difference() {
        prism(shell, height=h, r=Rext+gap+wall);
        raise(wall) prism(well, height=h, r=Rext+gap);
    }
}

module hex_base(base=Dthin, wall=Dthin, snug=0.05, color=undef) {
    h = lfloor(Hboard) + base;
    colorize(color) difference() {
        prism(height=h, r=wall) hex(r=Rhex+wall);
        raise(base) prism(height=h) hex(r=Rhex-snug);
        raise(-Dcut) prism(height=base+2*Dcut) hex(r=Rhex-Rext);
    }
}
module hex_caddy(color=undef) {
    v = Vtray_hex;
    base = area(Vtray_player);
    shell = area(v);
    wall = Dwall - 2*Dgap;
    // dimensions of city & town tiles
    rtown = Rhex;
    rcity = Rhex + Dthin;
    dtown = tround(2*rtown*sin(60));
    dcity = tround(2*rcity*sin(60));
    echo(rtown=rtown, rcity=rcity, dtown=dtown, dcity=dcity);
    // city & town slot layout
    dslack = (base.y - dcity - dtown) / 2;  // vertical wiggle room
    ymid = dcity/2 - dtown/2;  // horizontal centerline
    yint = ymid + tround((rcity - rtown)/2 * sin(60));  // hex slot intersection
    ytown = ymid + dslack/2 + dtown/2;
    ycity = ymid - dslack/2 - dcity/2;
    wcity = 2*rcity + tround(dslack/2 / sin(60));  // width of city slot
    hcity = Htile + Dgap + Dthin;
    echo(dslack=dslack, ymid=ymid, yint=yint, ytown=ytown, ycity=ycity, wcity=wcity);
    echo(wcity - 2*rcity);
    module hex_slot(rhex, dhex) {
        // draw a diamond to hold a hex within vertical constraints
        y1 = dhex/2;
        x1 = rhex/2;
        x0 = x1 + tround(y1*tan(30));
        y0 = y1 + tround(x1/tan(30));
        hex = [[x0, 0], [0, y0], [-x0, 0], [0, -y0]];
        polygon(hex);
    }
    module town_city_slot() {
        translate([0, ytown]) hex_slot(rtown, dtown+dslack);
        translate([0, ycity]) hex_slot(rcity, dcity+dslack);
    }
    dx = tround(rcity/2 + wcity/2 + wall/sin(60) + (yint-ymid)*cos(60));
    echo(dx=dx);
    colorize(color) {
        prism(shell, height=Hfloor, r=Rext);
        raise(Hfloor-Dcut) prism(height=v.z-Hfloor+Dcut, rext=wall/2-EPSILON)
            for (i=[-1,+1]) translate([dx*i, 0]) intersection() {
                square(shell, center=true);
                difference() {
                    offset(delta=wall) town_city_slot();
                    town_city_slot();
                }
        }
    }
    %raise(-Dthin) prism(base, height=Hfloor, r=Rext);
    %raise() {
        for (i=[-1,+1]) {
            translate([dx*i, ytown]) rotate(90) hex_tile(height=6*Htile);
            translate([dx*i, ycity]) rotate(90) hex_tile(height=5*hcity, r=rcity);
        }
        translate([0, yint]) rotate(90) hex_tile(height=5*hcity, r=rcity);
    }
}
module unit_caddy(color=undef) {
    v = Vtray_unit;
    well = area(v) - area(2*Dwall);
    colorize(color) difference() {
        prism(v, r=Rext);
        hvee = v.z/2;
        zvee = v.z - hvee;
        xvee = v.y - hvee/tan(Avee);  // center ramp on side wall
        raise(hvee) {
            translate([0, -v.y/2]) rotate(90) wall_vee_cut([xvee, v.x, zvee]);
            prism(well, height=hvee+Dcut, r=Rint);
        }
        raise(Dthin) {
            dsiege = eceil(Hboard, 0.5);
            dunits = well.y - dsiege - Dthin;
            wunits = (well.x - Dthin) / 2;
            echo(dsiege=dsiege, dunits=dunits, wunits=wunits);
            dx = well.x/2 - wunits/2;
            for (i=[-1,+1]) {
                translate([dx*i, well.y/2 - dsiege/2])
                    prism([wunits, dsiege, hvee], r=Rint);
                translate([dx*i, dunits/2 - well.y/2])
                    prism([wunits, dunits, hvee], r=Rint);
            }
        }
    }
}
module player_tray(color=undef) {
    v = Vtray_player;
    lip = Hfloor;
    rim = Dthin/2;
    rrim = Rext-rim;
    well = area(v) - area(2*Dwall);
    dscoop = well.y - 2*rim;
    hscoop = v.z - lip - rim;
    rscoop = Rext;
    echo(dscoop=dscoop, hscoop=hscoop);
    v0 = [Vtray_unit.y+2*Dgap, well.y, v.z-Hfloor-lip+Dcut];
    x0 = v0.x/2 - well.x/2;
    v1 = [20, dscoop, hscoop];
    x1 = well.x/2 - v1.x/2 - rim;
    v2 = [(well.x - v0.x - v1.x - 3*Dwall - rim)/2, dscoop, hscoop];
    x2 = v0.x + Dwall + v2.x/2 - well.x/2;
    v3 = v2;
    x3 = well.x/2 - rim - v1.x - Dwall - v3.x/2;
    echo(well.x - v0.x - v1.x - v2.x - 3*Dwall - rim);
    echo(v0=v0, v1=v1, v2=v2);
    colorize(color) difference() {
        prism(v, r=Rext+Dwall);
        raise(v.z-lip) prism(well, height=lip+Dcut, r=Rext);
        raise(Hfloor) translate([x0, 0]) prism(v0, r=Rext);
        raise(Dthin) translate([x1, 0])
            scoop_well(v1, rint=rrim, rscoop=rscoop, lip=hscoop-rscoop);
        raise(Dthin) translate([x2, 0])
            scoop_well(v2, rint=rrim, rscoop=rscoop, lip=hscoop-rscoop);
        raise(Dthin) translate([x3, 0])
            scoop_well(v3, rint=rrim, rscoop=rscoop, lip=hscoop-rscoop);
    }
}

module organizer() {
    %box_frame();
    *card_tray_leaders() {
        card_tray(Vtray_tech);
        union() {
            card_tray();
            raise(Htray+Dgap) card_tray();
            raise(2*Htray+2*Dgap) card_tray(Vtray_build);
        }
    }
    *hex_caddy();
    *player_tray();
    box(25, height=5, tabs=true, slots=true);
    *box(50, height=5, grid=2, tabs=true, slots=true);
    *box_lid(25);
}

*card_tray_leaders($fa=Qprint);
*card_tray($fa=Qprint);
*card_tray(Vtray_build, $fa=Qprint);
*card_tray(Vtray_tech, $fa=Qprint);
*tray_foot($fa=Qprint);
*tray_divider($fa=Qprint);
*currency_tray($fa=Qprint);
*currency_tray(slots=2, $fa=Qprint);
*currency_tray(slots=3, $fa=Qprint);
*currency_lid($fa=Qprint);
*dice_rack(n=9, $fa=Qprint);
*hex_base($fa=Qprint);
*hex_base(snug=0.1, $fa=Qprint);  // tighter fit
*hex_caddy($fa=Qprint);
*unit_caddy($fa=Qprint);
*player_tray($fa=Qprint);

organizer();
