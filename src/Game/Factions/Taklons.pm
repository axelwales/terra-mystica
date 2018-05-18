package Game::Factions::Taklons;

use strict;
use Readonly;

Readonly our $taklons => {
    C => 15, O => 4, K => 3, Q => 1, P1 => 2, P2 => 4, Brainstone => 1,
    color => 'brown',
    display => "Taklons",
    faction_board_id => 2,
    gaia_project => {
		gaiaform => 1,
	},
	power_leech => {
        gain => { PT => 1 },
		enable_if => { PI => 1 },
    },
    buildings => {
        M => { advance_cost => { O => 1, C => 2 },
               income => { O => [ 1, 2, 3, 3, 4, 5, 6, 7, 8 ] } },
        TS => { advance_cost => { O => 2, C => 3 },
                income => { C => [ 0, 3, 7, 11, 16 ] } },
        RL => { advance_cost => { O => 3, C => 5 },
                income => { K => [ 1, 2, 3, 4 ] } },
        PI => { advance_cost => { O => 4, C => 6 },
                advance_gain => [ ],
                income => { PT => [ 1, 2 ], PW => [0, 4] } },
        AC_K => { advance_cost => { O => 6, C => 6 },
                income => { K => [ 0, 2 ] } },
        AC_Q => { advance_cost => { O => 6, C => 6 },
				advance_gain => [ { ACTQ => 1 } ]
                income => { } },
    }
};

