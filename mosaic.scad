echo("\n\n====== MOSAIC ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

Nplayers = 6;

// game box interior
Vgame = [225, 310, 100];
Hwrap = 82;  // cover art wrap ends here, approximately
Hmanual = 4;  // measurement varies from 2.5-3.5

// component metrics
Hboard = 2.1;
Hmat = 2.2;  // player boards
Hgameboard = 21;  // measurement varies from 20-21
Vgameboard = [199, 305, Hgameboard];  // approximately 7.75"x12"
echo(Vgameboard=Vgameboard);
Hspace = round(Hceiling - Hgameboard - Nplayers * Hmat);
echo(Hspace=Hspace);

// card metrics
// Sleeve Kings "Card Game" card sleeves
// - 0.470 measured = 0.340 unsleeved (base game)
Hcard_unsleeved = 0.34;
Hcard_sleeve = Hsleeve_kings;
Vcard = Vsleeve_card_game;
Vcard_divider = [66, 92];

// container metrics
Hfoot = 0;
Htray = eceil(Hceiling / 2, 5);
// wildlife card tray
Vtray = [72, 97, Htray];

module organizer() {
    %box_frame();
}

organizer();
*test_game_shapes($fa=Qdraft);

*todo($fa=Qprint);
