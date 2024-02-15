echo("\n\n====== MOSAIC ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

// game box interior
Vgame = [225, 310, 100];
Hwrap = 82;  // cover art wrap ends here, approximately

// component metrics
Nplayers = 6;
Npillars = 9;
Hboard = tround(32.10 / 15);  // measured from achievement tiles
Hmat = tround(13 / Nplayers);  // measured from player boards
echo(Hboard=Hboard, Hmat=Hmat);
Vmat = [196, 296, Hmat];  // player boards
Hmap = 21;  // measurement varies from 20-21
Vmap = [199, 305, Hmap];  // approximately 7.75"x12"
echo(Vmat=Vmat, Vmap=Vmap);
Rhex = 3/4 * INCH;  // note: hex tiles are symmetric, but the map grid is not
Rtrade = 1/2 * INCH;  // cache & trade goods tokens
Vtile = [45, 70];  // Wonder, Golden Age, Civilization Achievement, Government

// available space
Hmanual = 3;  // spine: 2.5, pages: 1.5, reference card: TODO
Hmain = 63;
Vside = [Vgame.x - Vmap.x, Vgame.y, Hceiling];  // side gap dimensions

// card metrics
// Sleeve Kings "Card Game" card sleeves
// - 0.470 measured = 0.340 unsleeved (base game)
Hcard_unsleeved = 0.34;
Hcard_sleeve = Hsleeve_kings;
Vcard = Vsleeve_card_game;
Vcard_divider = [92, 67.5];
Hcard_divider = 2;
Vcard_leader = [130, 92];
// deck sizes & minimum box heights
Hcard_tech = 52;
Hcard_tech_general = 32;  // 36+ box
Hcard_tech_starter = 20;  // 24+ box
Hcard_build = 20;  // 24+ box
Hcard_pop = 11;  // 15+ box
Hcard_tax = 11;  // 15+ box

// container metrics
Hlip = 1;
Htray = 15;
Vtray = [97, 72.5, Htray];
Vtray_tech = [Vtray.x, Vtray.y, 55];
Vtray_build = [Vtray.x, Vtray.y, 25];
echo(Vtray_tech=Vtray_tech, Vtray_build=Vtray_build);
Dlid = 1;
Vtray_currency = [75, 90, 24];
echo(Vtray_currency=Vtray_currency);
Vtray_player = [144, 70, 14];
Vtray_hex = [110, 66, 20];
Vtray_unit = [65, 30, 30];
// deck box sizes
Hbox_tech_general = 38;
Hbox_tech_starter = 25;
Hbox_build = 25;
Hbox_pop = 16;
Hbox_tax = 16;
Vbox_leaders = [Vcard_leader.x + 6, 9, Vtray.x];
// cache tokens, fish, and start player
Hbox_cache = 14;

module leader_box(size=Vbox_leaders, color=undef) {
    box(size=size, draw=true, color=color);
}
module tile_box(n=Npillars, color=undef) {
    thick = wall_thickness(thick=true);
    thin = wall_thickness(thick=false);
    tiles = Htile*n;
    echo(tiles=tiles);
    d = ceil(tiles) + 2*Dwall;
    d9 = ceil(Htile*Npillars) + 2*Dwall;
    w = Vtile.y + 2*Rext;
    h = Vtile.x + Hfloor + Hlip;
    vbox = [w, d, h];
    vbox9 = [w, d9, h];
    well = vbox - [2*thick, 2*thin, 0];
    ot = [0, vbox.y/2 - d9/2];
    difference() {
        box(vbox, well=well, draw=tround(Vtile.x/3), color=color);
        translate(ot) stacking_tabs(vbox9, slot=true);
    }
    colorize(color) translate(ot) raise(vbox.z) stacking_tabs(vbox9);
    // children
    if ($children) raise() children(0);
    if (1<$children) translate(ot) raise(vbox.z+EPSILON) children([1:$children-1]);
}
module token_rack(n=undef, height=Hmain, last=undef, r=Rext,
                  wall=Dwall, divider=Dwall, lip=Htoken/3, color=undef) {
    // create a rack for cache & trade goods tokens
    nstack = floor((height - lip - Hfloor) / Htoken);
    n = is_undef(n) ? nstack : n;
    ncols = ceil(n / nstack);
    nlast = (n-1) % nstack + 1;  // number of tokens in the last column
    last = is_undef(last) ? floor(ncols/2) : last;  // index of "last" column
    dwell = ceil(2*Rtrade);
    w = ncols * (dwell + divider) - divider + 2*wall;
    d = dwell + wall;
    v = [w, d, height];
    o = wall + dwell/2 - v.x/2;
    dx = dwell + divider;
    echo(v=v, n=n, nstack=nstack, ncols=ncols, nlast=nlast, last=last);
    colorize(color) difference() {
        prism(v, r=r);
        for (i=[0:ncols-1]) {
            hstack = Htoken * (i == last ? nlast : nstack);
            hwell = lceil(hstack + lip);
            echo(i=i, hstack=hstack, hwell=hwell);
            translate([o+i*dx, -v.y/2, v.z - hwell])
                prism(height=hwell+Dcut) circle_notch(d=dwell);
        }
    }
    // preview fit
    %for (i=[0:ncols-1]) {
        hstack = Htoken * (i == last ? nlast : nstack);
        hwell = lceil(hstack + lip);
        translate([o+i*dx, -wall/2, v.z - hwell]) cylinder(h=hstack, r=Rtrade);
    }
}

module currency_tray(size=Vtray_currency, slots=1, color=undef) {
    r = Rext;
    lip = size.z - Hfloor - 2*r;
    scoop_tray(size=size, grid=[1, slots], rscoop=r, lip=lip, color=color);
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
    *%box_frame();
    *hex_caddy();
    *player_tray();
    *box([20, 25], height=5, tabs=true, slots=true);
    *box(25, height=5, tabs=true, slots=true);
    *box(50, height=5, grid=2, tabs=true, slots=true);
    *box_lid(25);
    *translate([-15, 0]) tab([30, 10], joiner=1);
    *translate([+15, 0]) tab([30, 10], width=10, joiner=1);
    *box([96, 144, 72], index=true)
        %raise(36) rotate(Sup) box_divider([96, 72], index=true);
    *box([72, 144, 96], index=true);
    *box([96, 144, 72], index=true, tabs=true, slots=true);
    *box([96, 72, 25], notch=true, hole=true);
    *box(Vtray, height=15, notch=true, hole=true) {
        %box_divider(Vtray, notch=true);
        *box_divider(Vtray, notch=true)
        *rotate(90) deck_divider(swapxy(Vcard_divider));
    }
    *raise(Hfloor) rotate(90) deck_divider();
    *card_tray();
    *tab([50, 20], w1=undef, w2=50, angle=135, rext=1, joiner=1);
    *hex_tab([60, 60], rhex=25, angle=60, r=3);
    *box(Vtray, height=Hbox_tech_general, tabs=true, notch=true, hole=true);
    *%translate([0, 12.5]) rotate(-90)
        deck_box(size=Vcard, width=25, draw=true, feet=true);
    *box(size=[97, 25, 70.5], draw=true, feet=true);
    *%translate([0, 5]) rotate(-90)
        deck_box(size=[93, 130], width=10, draw=true, feet=true);
    *box(size=[136, 9, 97], draw=true);
    *tile_box(n=12, $fa=Qprint) { union(); tile_box(); }
    translate([0, -15]) token_rack(38, height=43, $fa=Qprint);
    translate([0, +15]) token_rack(138, $fa=Qprint);
}

token_rack(38, height=43, lip=0, $fa=Qprint);  // cache tokens & fish (tighter)
*token_rack(38, height=44, lip=Htoken/2, $fa=Qprint);  // cache tokens & fish
*token_rack(138, $fa=Qprint);  // trade goods tokens
*leader_box($fa=Qprint);
*tile_box($fa=Qprint);
*tile_box(n=12, $fa=Qprint);
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
*box(Vtray, height=Hbox_tax, notch=true, hole=true, $fa=Qprint);
*box(Vtray, height=Hbox_build, notch=true, hole=true, $fa=Qprint);
*box(Vtray, height=Hbox_tech_starter, slots=true, notch=true, hole=true, $fa=Qprint);
*box(Vtray, height=Hbox_tech_general, tabs=true, notch=true, hole=true, $fa=Qprint);
*box_divider(Vtray, notch=true, $fa=Qprint);

*organizer();
