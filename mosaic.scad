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
Vtray_currency = [Vtray.x, 2*Vtray.y, 11.75];
echo(Vtray_currency=Vtray_currency);
Vtray_player = [71.5, 136, 12];
Vtray_hex = [71.5, 110, 19.5];
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

module card_box(height, tabs=false, slots=false, color=undef) {
    box(Vtray, height, tabs=tabs, slots=slots, notch=true, hole=true, color=color) {
        union() {
            stack = height - 5;  // approximate deck height
            %rotate(90) color(color, 0.5) prism(Vcard, height-5);
            %raise(stack + EPSILON) deck_divider(color=color);
        }
        children();
    }
}
module currency_box(n=3, height=Vtray_currency.z, color=undef) {
    box(Vtray_currency, height, depth=height-1, grid=[1, n],
        slots=true, scoop=true, color=color) {
        union();
        children();
    }
    colorize(color) for (i=[-1,+1])
        translate([0, Vtray.y/2*i, Vtray_currency.z]) stacking_tabs(Vtray);
}
module leader_box(color=undef) {
    box(size=Vbox_leaders, draw=true, color=color);
}
module tile_stack(n=Npillars, up=false, color=undef) {
    h = n * Htile;
    colorize(color) prism([Vtile.x, Vtile.y, h]);
    raise(h + EPSILON) children();
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
    box(vbox, well=well, draw=tround(Vtile.x/3), tabs=-d9, slots=-d9, color=color);
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
    // children
    raise(height + EPSILON) children();
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
    echo("hex_caddy");
    v = Vtray_hex;
    base = area(v);
    wall = wall_thickness(thick=false);
    echo(v=v, wall=wall);
    // dimensions of city & town tiles
    rtown = Rhex;
    rcity = Rhex + Dthin;
    dtown = tround(2*rtown*sin(60));
    dcity = tround(2*rcity*sin(60));
    echo(rtown=rtown, rcity=rcity, dtown=dtown, dcity=dcity);
    // city & town slot layout
    dslack = (base.x - dcity - dtown - wall) / 2;  // wiggle room for hexes
    xmid = dtown/2 - dcity/2;  // horizontal centerline
    xint = xmid + tround((rtown - rcity)/2 * sin(60));  // hex slot intersection
    xtown = xmid - dslack/2 - dtown/2;
    xcity = xmid + dslack/2 + dcity/2;
    wcity = 2*rcity + tround(dslack/2 / sin(60));  // width of city slot
    hcity = Htile + Dgap + Dthin;
    echo(dslack=dslack, xmid=xmid, xint=xint, xtown=xtown, xcity=xcity, wcity=wcity);
    echo(wcity - 2*rcity);
    module hex_slot(rhex, dhex) {
        // draw a diamond to hold a hex within vertical constraints
        x1 = dhex/2;
        y1 = rhex/2;
        x0 = x1 + tround(y1/tan(30));
        y0 = y1 + tround(x1*tan(30));
        // hex = [[x0, 0], [0, y0], [-x0, 0], [0, -y0]];
        hex = [[x0, 0], [0, y0], [-x0, 0], [0, -y0]];
        polygon(hex);
    }
    module town_city_slot() {
        translate([xtown, 0]) hex_slot(rtown, dtown+dslack);
        translate([xcity, 0]) hex_slot(rcity, dcity+dslack);
    }
    dy = tround(rcity/2 + wcity/2 + wall/sin(60) + (xint-xmid)*cos(60));
    echo(dy=dy);
    colorize(color) {
        prism(base, height=Hfloor, r=Rext);
        raise(Hfloor-Dcut) prism(height=v.z-Hfloor+Dcut, rext=wall/2-EPSILON)
            for (i=[-1,+1]) translate([0, dy*i]) intersection() {
                square(base, center=true);
                difference() {
                    offset(delta=wall) town_city_slot();
                    town_city_slot();
                }
        }
    }
    // colorize(color, 0.5) {
    {
        %raise(-Dthin) prism(base, height=Hfloor, r=Rext);
        %raise() {
            for (i=[-1,+1]) {
                translate([xtown, dy*i]) hex_tile(height=6*Htile);
                translate([xcity, dy*i]) hex_tile(height=5*hcity, r=rcity);
            }
            translate([xint, 0]) hex_tile(height=5*hcity, r=rcity);
        }
    }
}
module unit_caddy(color=undef) {
    // TODO: remove
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
    r = Rext;
    colorize(color) difference() {
        prism(v, r=r);
    }
    translate([0, Vtray_hex.y/2 - v.y/2, v.z+EPSILON]) children();
    *union() {
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
}

// organizer components
Cbronze = "#888060";
Ctech = "#703030";
Cbuild = "#305870";
Ctax = "#a08030";
Cpop = "#307840";
Cred = "#c00000";
Corange = "#d07000";
Cyellow = "#c0c000";
Cgreen = "#008000";
Cblue = "#0000c0";
Cviolet = "#7000d0";
Cplayer = [Cviolet, Cred, Corange, Cyellow, Cgreen, Cblue];
// game components (transparent)
Cwonder = "#68181880";
Cachievement = "#20509880";
Cgovernment = "#f0d8b080";
Cgolden = "#f8f8f080";

module organizer(explode=0) {
    %box_frame();
    q1 = [+Vgame.x/2, +Vgame.y/2];
    q2 = [-Vgame.x/2, +Vgame.y/2];
    q3 = [-Vgame.x/2, -Vgame.y/2];
    q4 = [+Vgame.x/2, -Vgame.y/2];
    // leaders
    translate(q2 + [+Vbox_leaders.y/2, -Vbox_leaders.x/2])
        rotate(90) leader_box(color=Cbronze);
    // achievements, golden ages, governments, wonders
    translate(q3) {
        rotate(90) {
            o9 = [0, +9/2*Htile, Vtile.x/2];
            o12 = [0, +6*Htile, Vtile.x/2];
            r = [0, -90, 90];
            translate([38+Dgap+76, -15]) tile_box(n=12, color=Cbronze) {
                %translate(o12) rotate(r)
                    tile_stack(6, color=Cachievement)
                    tile_stack(6, color=Cgovernment);
                raise(explode) tile_box(color=Cbronze)
                    %translate(o9) rotate(r) tile_stack(color=Cachievement);
            }
            translate([38, -12]) tile_box(color=Cbronze) {
                %translate(o9) rotate(r) tile_stack(color=Cwonder);
                tile_box(color=Cbronze)
                    %translate(o9) rotate(r) tile_stack(color=Cgolden);
            }
        }
    }
    // map tokens
    translate(q4) {
        // cache & fish tokens
        translate([-29, 14]) box([58, 28, 20], thick=true, color=Cbronze) {
            union();
            raise(explode) token_rack(38, height=43, lip=0, color=Cbronze);
        }
        // trade goods tokens
        translate([-Dgap-129, 14]) token_rack(138, color=Cbronze);
    }
    // cards & currency
    translate(q4 + [-Vtray.x-1/2*Dgap, Vtray.y+28+3/2*Dgap]) {
        translate([-Vtray.x/2-Dgap/2, Vtray.y/2+Dgap/2])
            card_box(Hbox_tech_general, tabs=true, color=Ctech)
                card_box(Hbox_tech_starter, slots=true, color=Ctech);
        translate([-Vtray.x/2-Dgap/2, -Vtray.y/2-Dgap/2])
            rotate(180) card_box(Hbox_build, slots=true, color=Cbuild);
        translate([+Vtray.x/2+Dgap/2, 0])
            currency_box(color=Cbronze)
            raise(explode/6)
            currency_box(color=Cbronze)
            raise(explode)
            currency_box(2, color=Cbronze)
            raise(explode/6)
            currency_box(2, color=Cbronze)
            raise(explode) {
                translate([+0, -Vtray.y/2-EPSILON])
                    rotate(180) card_box(Hbox_tax, slots=true, color=Ctax);
                translate([+0, +Vtray.y/2+EPSILON])
                    rotate(180) card_box(Hbox_pop, slots=true, color=Cpop);
            }
    }
    // player consoles
    translate(q1 - area(Vtray_player)/2) for (i=[0:5]) {
        dx = Vtray_player.x + Dgap;
        dz = Hmain/2 + Dgap;
        o = [-(i < 3 ? i : 5-i)*dx, 0, floor((5-i)/3)*dz];
        translate (o) {
            player_tray(color=Cplayer[i]) hex_caddy(color=Cplayer[i]);
        }
    }
}

*box_divider(Vtray, notch=true, $fa=Qprint);
*card_box(Hbox_tax, slots=true, $fa=Qprint);
*card_box(Hbox_build, slots=true, $fa=Qprint);
*card_box(Hbox_tech_starter, slots=true, $fa=Qprint);
*card_box(Hbox_tech_general, tabs=true, $fa=Qprint);
*currency_box($fa=Qprint);  // stone, food, and ideas
*currency_box(2, $fa=Qprint);  // coins
*leader_box($fa=Qprint);
*tile_box($fa=Qprint);
*tile_box(n=12, $fa=Qprint);
*dice_rack(n=9, $fa=Qprint);
*token_rack(38, height=43, lip=0, $fa=Qprint);  // cache tokens & fish
*token_rack(138, $fa=Qprint);  // trade goods tokens
*box([58, 28, 20], thick=true, $fa=Qprint);  // token rack spacer
*hex_base($fa=Qprint);
*hex_base(snug=0.1, $fa=Qprint);  // tighter fit
// TODO: update
*hex_caddy($fa=Qprint);
*unit_caddy($fa=Qprint);
*player_tray($fa=Qprint);

organizer();
*organizer(explode=30);
