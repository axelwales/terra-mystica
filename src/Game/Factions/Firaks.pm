package Game::Factions::Firaks;

use strict;
use Readonly;

Readonly our $firaks => {
    C => 15, O => 4, K => 2, Q => 1, P1 => 2, P2 => 4,
    color => 'grey',
    display => "Firaks",
    faction_board_id => 10,
    gaia_project => {
		gaiaform => 1,
	},
    buildings => {
        M => { advance_cost => { O => 1, C => 2 },
               income => { O => [ 1, 2, 3, 3, 4, 5, 6, 7, 8 ] } },
        TS => { advance_cost => { O => 2, C => 3 },
                income => { C => [ 0, 3, 7, 11, 16 ] } },
        RL => { advance_cost => { O => 3, C => 5 },
                income => { K => [ 2, 3, 4, 5 ] } },
        PI => { advance_cost => { O => 4, C => 6 },
                advance_gain => [ { ACTF => 1 } ],
                income => { PT => [ 0, 1 ], PW => [0, 4] } },
        AC_K => { advance_cost => { O => 6, C => 6 },
                income => { K => [ 0, 2 ] } },
        AC_Q => { advance_cost => { O => 6, C => 6 },
				advance_gain => [ { ACTQ => 1 } ]
                income => { } },
    }
};
