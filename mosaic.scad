echo("\n\n====== MOSAIC ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

Nplayers = 6;

// game box interior
Vgame = [225, 310, 100];
Hwrap = 82;  // cover art wrap ends here, approximately

// component metrics
Hboard = 2.1;
Hmat = 2.2;  // player boards
Hgameboard = 21;  // measurement varies from 20-21
Vgameboard = [199, 305, Hgameboard];  // approximately 7.75"x12"
echo(Vgameboard=Vgameboard);
Rhex = 0.75 * INCH;  // note: hex tiles are symmetric, but the map grid is not

// available space
Hmanual = 3;  // measurement varies from 2.5-3.5
Hmain = 63;
Vside = [Vgame.x - Vgameboard.x, Vgame.y, Hceiling];  // side gap dimensions

// card metrics
// Sleeve Kings "Card Game" card sleeves
// - 0.470 measured = 0.340 unsleeved (base game)
Hcard_unsleeved = 0.34;
Hcard_sleeve = Hsleeve_kings;
Vcard = Vsleeve_card_game;
Vcard_divider = [67, 93];

// container metrics
Htray = 15;
Vtray = [72, 100, Htray];
Vtray_tech = [Vtray.x, Vtray.y, 55];
Vtray_build = [Vtray.x, Vtray.y, 25];
Vtray_leaders = [2*Vtray.x, Vtray.y, 8];
echo(Vtray_tech=Vtray_tech, Vtray_build=Vtray_build, Vtray_leaders=Vtray_leaders);
Dlid = 1;
Vtray_currency = [75, 90, 24];
echo(Vtray_currency=Vtray_currency);

module card_tray_leaders(size=Vtray_leaders, cut=Dcut, color=undef) {
    vtray = size;
    vwell = volume(area(vtray) - 2*area(Dwall), vtray.z-Hfloor);
    colorize(color) difference() {
        prism(vtray, r=Rext);
        raise(Hfloor) prism(vwell, height=vwell.z+cut, r=Rint);
        for (i=[-1, +1]) translate([vtray.x/4*i, 0]) {
            raise(Hfloor) {
                // thumb vee
                span = Dthumb + 2*Rint;
                dmax = (vwell.x - span) / 4;  // maximum spread of vee at top
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

module organizer() {
    %box_frame();
    card_tray_leaders() {
        card_tray(Vtray_tech);
        union() {
            card_tray();
            raise(Htray+Dgap) card_tray();
            raise(2*Htray+2*Dgap) card_tray(Vtray_build);
        }
    }
}

*card_tray_leaders($fa=Qprint);
*card_tray($fa=Qprint);
*card_tray(Vtray_build, $fa=Qprint);
*card_tray(Vtray_tech, $fa=Qprint);
*tray_foot($fa=Qprint);
*tray_divider($fa=Qprint);
currency_tray($fa=Qprint);
*currency_tray(slots=2, $fa=Qprint);
*currency_tray(slots=3, $fa=Qprint);
*currency_lid($fa=Qprint);

*organizer();
