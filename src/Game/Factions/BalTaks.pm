package Game::Factions::BalTaks;

use strict;
use Readonly;

Readonly our $auren => {
    C => 15, O => 4, P1 => 2, P2 => 2,
    GAIA_PROJECT => 1,
    color => 'orange',
    display => "Bal T'aks",
    faction_board_id => 13,
	gaia_project => {
		gaiaform => 1,
		Q => 1
	},
    buildings => {
        D => { advance_cost => { O => 1, C => 2 },
               income => { O => [ 1, 2, 3, 3, 4, 5, 6, 7, 8 ] } },
        TP => { advance_cost => { O => 2, C => 3 },
                income => { C => [ 0, 3, 7, 11, 16 ] } },
        TE => { advance_cost => { O => 3, C => 5 },
                income => { K => [ 0, 1, 2, 3 ] } },
        SH => { advance_cost => { O => 4, C => 6 },
                advance_gain => [ { ALLOW_NAV => 1 } ],
                income => { PW => [ 0, 2 ] } },
        SA_K => { advance_cost => { O => 6, C => 6 },
                income => { K => [ 0, 2 ] } },
        SA_Q => { advance_cost => { O => 6, C => 6 },
				advance_gain => [ { ACTBa => 1 } ]
                income => { } },
    }
};

