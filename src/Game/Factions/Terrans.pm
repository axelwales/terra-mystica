package Game::Factions::Terrans;

use strict;
use Readonly;

Readonly our $terrans => {
    C => 15, O => 4, K => 3, Q => 1, P1 => 2, P2 => 4,
	GAIA_PROJECT => 1,
    color => 'blue',
    display => "Terrans",
    faction_board_id => 5,
    gaia_project => {
		gaiaform => 1,
	},
    buildings => {
        D => { advance_cost => { O => 1, C => 2 },
               income => { O => [ 1, 2, 3, 3, 4, 5, 6, 7, 8 ] } },
        TP => { advance_cost => { O => 2, C => 3 },
                income => { C => [ 0, 3, 7, 11, 16 ] } },
        TE => { advance_cost => { O => 3, C => 5 },
                income => { K => [ 1, 2, 3, 4 ] } },
        SH => { advance_cost => { O => 4, C => 6 },
                advance_gain => [ ],
                income => { PT => [ 0, 1 ], PW => [0, 4] } },
        SA_K => { advance_cost => { O => 6, C => 6 },
                income => { K => [ 0, 2 ] } },
        SA_Q => { advance_cost => { O => 6, C => 6 },
				advance_gain => [ { ACTQ => 1 } ]
                income => { } },
    }
};
