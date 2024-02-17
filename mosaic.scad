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
Vunit = [27.25, 27.25];  // military units

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
Vtray_player = [71.5, 135, 31.5];
Vtray_hex = [71.5, 110, 19.5];  // TODO: shrink if possible
// deck box sizes
Hbox_tech_general = 38;
Hbox_tech_starter = 25;
Hbox_build = 25;
Hbox_pop = 16;
Hbox_tax = 16;
Vbox_leaders = [Vcard_leader.x + 6, 9, Vtray.x];
// bin sizes
Hbox_misc = 13;  // miscellaneous bits (start player, wonder board tiles, etc.)
Hbox_bag = 25;  // token bag storage
Vbox_cache_spacer = [58, 28, 20];  // spacer for cache token rack

module basic_box(size=Vbox, height=undef, stack=false, scoop=false,
                    thick=true, color=undef) {
    // simple box for storage & spacing
    box(size=size, height=height, tabs=stack, slots=stack, scoop=scoop,
        thick=thick, color=color) {
        union();
        children();
    }
}
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
    v = Vtray_hex;
    // dimensions of city & town tiles
    rtown = Rhex;
    rcity = Rhex + Dthin;
    dtown = tround(2*rtown*sin(60));
    dcity = tround(2*rcity*sin(60));
    htown = Htile;
    hcity = Htile + Dgap + Dthin;
    ztown = lfloor(5*hcity - 6*htown);
    echo(ztown=ztown);
    // spacing & layout
    slack = (v.x - dtown - dcity) / 3;  // available wiggle room
    gap = tround(slack / 3);
    echo(slack=slack, gap=gap);
    xmid = dtown/2 - dcity/2;  // horizontal centerline
    xint = xmid + (rtown - rcity)/2 * sin(60);  // hex slot intersection
    wall = wall_thickness(thick=false);
    rext = Rext;
    rint = Rext - wall;
    wgrip = 2*(rcity + gap + wall);
    zgrip = Hfloor - Djoiner;
    vgrip = [v.x, wgrip, v.z - zgrip];
    module hex_slot(rhex, dhex, gap) {
        // draw a diamond to hold a hex within vertical constraints
        y = rhex + gap/sin(60);
        x = y*tan(60);
        polygon([[x, 0], [0, y], [-x, 0], [0, -y]]);
    }
    dy = v.y/2 - vgrip.y/2;
    xmargin = v.x/2 - slack;
    xtown = dtown/2 - xmargin;
    xcity = xmargin - dcity/2;
    open = 2*rext*sin(60);
    colorize(color) {
        box(v, height=Hfloor, depth=0, r=rext, slots=true);
        raise(zgrip) for (i=[-1,+1]) translate([0, dy*i]) {
            prism(height=vgrip.z) difference() {
                fillet(rint, rext) difference() {
                    square(area(vgrip), center=true);
                    translate([rtown/2-v.x/2, 0]) square(rtown+open, center=true);
                    translate([v.x/2-rcity/2, 0]) square(rcity+open, center=true);
                    for (j=[-1,+1]) translate([xint, (3/2*rcity + wall + 2*gap)*j])
                        hex_slot(rcity, dcity, gap);
                }
                xmargin = v.x/2 - slack;
                fillet(rext, rint) {
                    translate([xtown, 0]) hex_slot(rtown, dtown, gap);
                    translate([xcity, 0]) hex_slot(rcity, dcity, gap);
                }
            }
            // town riser
            prism(height=ztown+Djoiner) intersection() {
                translate([xtown, 0]) hex(r=rtown+wall);
                square([vgrip.x - 2*rext, vgrip.y], center=true);
                // don't cross the midpoint
                wint = xint + vgrip.x/2;
                translate([wint/2-vgrip.x/2, 0])
                    square([wint, vgrip.y], center=true);
            }
        }
    }
    colorize(color, 0.5) {
        %raise() {
            for (i=[-1,+1]) {
                translate([xtown, dy*i, ztown]) hex_tile(height=6*htown);
                translate([xcity, dy*i]) hex_tile(height=5*hcity, r=rcity);
            }
            translate([xint, 0]) hex_tile(height=5*hcity, r=rcity);
        }
    }
}
module player_tray(color=undef) {
    v = Vtray_player;
    r = Rext;
    lip = 1.5;
    wall = wall_thickness(thick=true);
    ddiv = wall_thickness(thick=false);
    vbase = volume(Vtray_hex, v.z - Vtray_hex.z);
    dbase = vbase.z - 1;
    translate([0, v.y/2 - Vtray_hex.y/2]) {
        box(vbase, grid=[1, 2], depth=dbase, tabs=true, scoop=true, color=color) {
            union();
            children();
        }
    }
    wunits = eround(2*Vunit.x + 2*wall + ddiv + 4, 0.5);
    vunits = [wunits, v.y - vbase.y + wall - Djoiner, v.z];
    dunits = lround(Vunit.y + lip);
    colorize(color) translate([0, vunits.y/2 -v.y/2]) difference() {
        box(vunits, grid=[2, 1], depth=dunits, wall=wall, divider=ddiv);
        translate([-vunits.x/2, vunits.y/2, vunits.z])
            rotate([-90, 0, -90]) punch(vunits.x)
            notch([2*vunits.y-2*Rext, vunits.z-vbase.z+Djoiner], w2=2*Rext);
    }
    vstack = volume(Vunit, 10*Htoken);
    %colorize(color, 0.5) for (i=[-1,+1]) {
        o = [(vunits.x-2*wall+ddiv)/4, vstack.z+Rext-v.y/2, vstack.y/2+v.z-dunits];
        translate([o.x*i, o.y, o.z]) rotate(Sup) prism(vstack, r=1);
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
                raise(explode) tile_box(color=Cbronze)
                    %translate(o9) rotate(r) tile_stack(color=Cgolden);
            }
        }
    }
    // map tokens
    translate(q4) {
        // cache & fish tokens
        translate([-29, 14])
            basic_box(Vbox_cache_spacer, color=Cbronze)
                raise(explode) token_rack(38, height=43, lip=0, color=Cbronze);
        // trade goods tokens
        translate([-Dgap-129, 14]) token_rack(138, color=Cbronze);
    }
    // cards & currency
    translate(q4 + [-Vtray.x-1/2*Dgap, Vtray.y+28+3/2*Dgap]) {
        translate([-Vtray.x/2-Dgap/2, Vtray.y/2+Dgap/2])
            card_box(Hbox_tech_general, tabs=true, color=Ctech)
                card_box(Hbox_tech_starter, slots=true, color=Ctech);
        translate([-Vtray.x/2-Dgap/2, -Vtray.y/2-Dgap/2])
            basic_box(height=Hbox_bag, stack=true, scoop=true, color=Cbronze)
            raise(explode)
                basic_box(height=Hbox_misc, stack=true, scoop=true, color=Cbronze)
            raise(explode)
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
            player_tray(color=Cplayer[i])
                raise(i < 3 ? (3-i)*explode/2 : 0) hex_caddy(color=Cplayer[i]);
        }
    }
}

*basic_box(height=Hbox_bag, stack=true, scoop=true, $fa=Qprint);
*basic_box(height=Hbox_misc, stack=true, scoop=true, $fa=Qprint);
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
*basic_box(Vbox_cache_spacer, $fa=Qprint);  // token rack spacer
*hex_base($fa=Qprint);
*hex_base(snug=0.1, $fa=Qprint);  // tighter fit
*hex_caddy($fa=Qprint);
*player_tray($fa=Qprint);

*organizer();
organizer(explode=30);
