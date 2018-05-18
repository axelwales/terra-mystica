package Game::Factions::Nevlas;

use strict;
use Readonly;

Readonly our $nevlas => { 
    C => 15, O => 4, K => 3, Q => 1, P1 => 2, P2 => 4,
	SCIENCE => 1,
    color => 'white',
    display => "Nevlas",
    faction_board_id => 6,
    gaia_project => {
		gaiaform => 1,
	},
	special => {
        cost => { PW => 1, GAIA_AREA => 1 },
        gain => { K => 1 },
        mode => 'build',
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
                income => { PT => [ 0, 1 ], PW => [0, 4] } },
        AC_K => { advance_cost => { O => 6, C => 6 },
                income => { K => [ 0, 2 ] } },
        AC_Q => { advance_cost => { O => 6, C => 6 },
				advance_gain => [ { ACTQ => 1 } ]
                income => { } },
    }
};

