package Game::Constants;

use Exporter::Easy (EXPORT => [ '@research_areas',
                                '%actions',
                                '%building_aliases',
                                '%building_strength',
                                '@colors',
                                '%colors',
                                '%faction_setups',
                                '%faction_setups_extra',
                                '@base_map',
                                '%resource_aliases',
                                '%tiles',
                                '%final_scoring' ]);

use strict;
use Readonly;

## Cults

Readonly our @research_areas => qw( TERRAFORMING NAVIGATION ARTIFICIAL_INTELLIGENCE GAIA_PROJECT ECONOMY SCIENCE );

## Buildings

Readonly our %building_strength => (
    GF => 0,
    M => 1,
    TS => 2,
    RL => 2,
    PI => 3,
    AC_K => 3,
    AC_Q => 3,
);

Readonly our %building_aliases => (
    GAIAFORMER => 'GF',
    MINE => 'M',
    'TRADING STATION' => 'TS',
    'RESEARCH LAB' => 'RL',
    'PLANETARY INSTITUTE' => 'PI',
    ACADEMY => 'AC_K',
    ACADEMY => 'AC_Q',
);

## Resources

Readonly our %resource_aliases => (
    Knowledge => 'K',
    QIC => 'Q',
    'POWER TOKEN' => 'PT',
    POWER => 'PW',
    Ore => 'O',
    COIN => 'C',
    COINS => 'C',
);

## Tiles

Readonly our %actions => (
    ACTP1 => { cost => { PW => 3 }, gain => { PT => 2 } },
    ACTP2 => { cost => { PW => 3 },
			  gain => { TERRAFORM => 1 },
              subaction => { terraform => 1, 'build' => 1 } },
    ACTP3 => { cost => { PW => 4 }, gain => { K => 2 } },
    ACTP4 => { cost => { PW => 4 }, gain => { C => 7 } },
    ACTP5 => { cost => { PW => 4 }, gain => { O => 2 } },
    ACTP6 => { cost => { PW => 5 }, gain => { TERRAFORM => 2 },
              subaction => { terraform => 2, 'build' => 1} },
	ACTP7 => { cost => { PW => 7 }, gain => { K => 3 } },
	
	ACTQ1 => { cost => { Q => 2 }, gain => { VP => 3, VP => { PLANET_TYPES => [ map { $_  * 1 } 0..9 ] } },
	ACTQ2 => { cost => { Q => 3 }, gain => { SCORE_FED => 1 } },
	ACTQ3 => { cost => { Q => 4 }, gain => { TECH => 1 } },
    ACTA => { cost => {}, gain => { MOVE_PI => 1 } },
    ACTI => { cost => { }, gain => { SPACE_STATION => 1 },
              subaction => { 'space_station' => 1 } },
    ACTF => { cost => { }, gain => { DOWNGRADE_TS => 1, NEED_RL => 1 },
              subaction => { 'upgrade' => 1 } },
    ACTBe => { cost => {}, gain => { FREE_RESEARCH => 1, MIN_RESEARCH => 1 },
              subaction => { 'upgrade' => 1 }},
	ACTBa => { cost => {}, gain => { C => 4 } }
	ACTQ => { cost => {}, gain => { Q => 1 } }
    BON4 => { cost => {}, gain => { TERRAFORM => 1 },
              subaction => { terraform => 1, 'build' => 1 } },
    BON5 => { cost => {}, gain => { RANGE => 3 },
              subaction => { 'build' => 1 } },
    TECH6 => { cost => {}, gain => { PW => 4 } },
    TECH22 => { cost => {}, gain => { O => 3 } },
    TECH23 => { cost => {}, gain => { K => 3 } },
    TECH24 => { cost => {}, gain => { Q => 1, C => 5 } },
);
       
sub init_tiles {
    my %tiles = @_;

    for my $tile_name (keys %tiles) {
        my $tile = $tiles{$tile_name};
        if ($tile_name =~ /^SCORE/) {
            my $currency = (keys %{$tile->{income}})[0];
            $tile->{income_display} =
                sprintf("%d %s -> %d %s", $tile->{req}, $tile->{income}{$currency}, $currency);
        }
        if (exists $actions{$tile_name}) {
            $tile->{action} = $actions{$tile_name};
        }
    }

    %tiles;
}

Readonly our %tiles => init_tiles (
    BON1 => { income => { O => 1, K => 1 } },
    BON2 => { income => { C => 2, Q => 1 } },
    BON3 => { income => { PT => 2, O => 1 } },
    BON4 => { income => { C => 2 } },
    BON5 => { income => { PW => 2 } },
    BON6 => { income => { O => 1 },
              pass_vp => { M => [ map { $_ } 0..8 ] } },
    BON7 => { income => { K => 1 },
              pass_vp => { RL => [ map { $_ * 3 } 0..3 ] } },
    BON8 => { income => { O => 1 },
              pass_vp => { TS => [ map { $_ * 2 } 0..4 ] } },
    BON9 => { income => { PW => 4 },
              pass_vp => { SA => [0, 4, 8], SH => [0, 4] } },
    BON10 => { income => { C => 4 },
               pass_vp => { GAIA => [ map { $_ } 0..19 ] },

    TECH1 => { gain => { VP => 7 }, income => {}, type => 'standard'},
    TECH2 => { gain => { O => 1, Q => 1 }, income => {}, type => 'standard'},
    TECH3 => { gain => { K => { PLANET_TYPES => [ map { $_  * 1 } 0..9 ] } }, income => {}, type => 'standard' },
    TECH4 => { gain => { PI_AC_SIZE => 1 }, income => {}, type => 'standard'},
    TECH5 => { income => {}, vp => { GAIA => 3 }, type => 'standard' },
    TECH6 => { income => {}, type => 'standard' },
    TECH7 => { income => { W => 1, PW => 1}, type => 'standard' },
    TECH8 => { income => { C => 4}, type => 'standard' },
    TECH9 => { income => { C => 1, K => 1 }, type => 'standard' },
	
    TECH10 => { gain => { VP => { FED => [ map { $_ * 5 } 0..18 ] } }, income => {}, type => 'advanced' },
    TECH11 => { gain => { VP => { M => [ map { $_  * 2 } 0..8 ] } }, income => {}, type => 'advanced' },
    TECH12 => { gain => { VP => { TS => [ map { $_ * 4 } 0..4 ] } }, income => {}, type => 'advanced' },
    TECH13 => { gain => { VP => { GAIA => [ map { $_ * 2 } 0..19 ] } }, income => {}, type => 'advanced' },
    TECH14 => { gain => { VP => { SECTOR => [ map { $_ * 2 } 0..10 ] } }, income => {}, type => 'advanced' },
    TECH15 => { gain => { O => { SECTOR => [ map { $_ * 2 } 0..10 ] } }, income => {}, type => 'advanced' },
    TECH16 => { vp => { M => 3 }, income => {}, type => 'advanced' },
    TECH17 => { vp => { TS => 3 }, income => {}, type => 'advanced' },
    TECH18 => { vp => { RESEARCH => 2 }, income => {}, type => 'advanced' },
    TECH19 => { pass_vp => { PLANET_TYPES => [ map { $_ } 0..9 ] }, income => {}, type => 'advanced' },
    TECH20 => { pass_vp => { RL => [ map { $_ * 3 } 0..3 ] }, income => {}, type => 'advanced' },
    TECH21 => { pass_vp => { FED => [ map { $_ * 3 } 0..18 ] }, income => {}, type => 'advanced' },
    TECH22 => { income => {}, type => 'advanced' },
    TECH23 => { income => {}, type => 'advanced' },
    TECH24 => { income => {}, type => 'advanced' },
    
    SCORE1 => { vp => { TERRAFORM => 2 },
                vp_display => 'TERRAFORM >> 2',
                vp_mode => 'gain' },
    SCORE2 => { vp => { map(("FED$_", 5), 1..18) },
                vp_display => 'FEDERATION >> 5',
                vp_mode => 'gain' },
    SCORE3 => { vp => { M => 2 },
                vp_display => 'M >> 2',
                vp_mode => 'build' },
	SCORE4 => { vp => { M => 3 },
                vp_display => 'M >> 3',
                vp_mode => 'build' },    
    SCORE5 => { vp => { PI => 5, AC_K => 5, AC_Q => 5 },
                vp_display => 'PI/AC >> 5',
                vp_mode => 'build' },
	SCORE6 => { vp => { PI => 5, AC_K => 5, AC_Q => 5 },
                vp_display => 'PI/AC >> 5',
                vp_mode => 'build' },    
    SCORE7 => { vp => { TS => 3 },
                vp_display => 'TS >> 3',
                vp_mode => 'build' },    
    SCORE8 => { vp => { TS => 4 },
                vp_display => 'TS >> 4',
                vp_mode => 'build' },    
    SCORE9 => { vp => { GAIA => 3 },
                vp_display => 'GAIA >> 3',
                vp_mode => 'build' },    
    SCORE10 => { vp => { GAIA => 4 },
                vp_display => 'TP >> 4',
                vp_mode => 'build' },    
    SCORE11 => { vp => { RESEARCH => 2 },
                vp_display => 'RESEARCH >> 2',
                vp_mode => 'gain' },    

    FED1 => { gain => { KEY => 1, VP => 6, K => 2 } },
    FED2 => { gain => { KEY => 1, VP => 7, O => 2 } },
    FED3 => { gain => { KEY => 1, VP => 7, C => 6 } },
    FED4 => { gain => { KEY => 1, VP => 8, PT => 2 } },
    FED5 => { gain => { KEY => 1, VP => 8, Q => 1 } },
    FED6 => { gain => { KEY => 1, VP => 12 } },
);

## Initial game board

Readonly our @base_map =>
    qw(brown gray green blue yellow red brown black red green blue red black E
       yellow x x brown black x x yellow black x x yellow E
       x x black x gray x green x green x gray x x E
       green blue yellow x x red blue x red x red brown E
       black brown red blue black brown gray yellow x x green black blue E
       gray green x x yellow green x x x brown gray brown E
       x x x gray x red x green x yellow black blue yellow E
       yellow blue brown x x x blue black x gray brown gray E
       red black gray blue red green yellow brown gray x blue green red E);

# The terraforming color wheel.
Readonly our @colors => qw(yellow brown grey white blue red orange);
Readonly our %colors => map { ($colors[$_], $_) } 0..$#colors;

## Faction definitions

use Game::Factions::Ambas;
use Game::Factions::BalTaks;
use Game::Factions::Bescods;
use Game::Factions::Firaks;
use Game::Factions::Geodens;
use Game::Factions::Gleens;
use Game::Factions::HadschHallas;
use Game::Factions::Itars;
use Game::Factions::Ivits;
use Game::Factions::Lantids;
use Game::Factions::Nevlas;
use Game::Factions::Taklons;
use Game::Factions::Terrans;
use Game::Factions::Xenos;

Readonly our %faction_setups => (
    ambas => $Game::Factions::Ambas::ambas,
    baltaks => $Game::Factions::BalTaks::baltaks,
    bescods => $Game::Factions::Bescods::bescods,
    firaks => $Game::Factions::Firaks::firaks,
    geodens => $Game::Factions::Geodens::geodens,
    gleens => $Game::Factions::Gleens::gleens,
    hadschhallas => $Game::Factions::HadschHallas::hadschhallas,
    itars => $Game::Factions::Itars::itars,
    ivits => $Game::Factions::Ivits::ivits,
    lantids => $Game::Factions::Lantids::lantids,
    nevlas => $Game::Factions::Nevlas::nevlas,
    taklons => $Game::Factions::Taklons::taklons,
    terrans => $Game::Factions::Terrans::terrans,
    xenos => $Game::Factions::Xenos::xenos,
);

Readonly our %final_scoring => (
    structures => {
        description => "Largest number of structures.",
        points => [18, 12, 6],
        label => "structures",
    },
    'federated-structures' => {
        description => "Largest number of structures in federations.",
        points => [18, 12, 6],
        label => 'federated-structures',
    },
    'satellites' => {
        description => "Largest number of satellites",
        points => [18, 12, 6],
        label => 'satellites',
    },
    'sectors' => {
        description => "Most sectors with at least one structure ",
        points => [18, 12, 6],
        label => 'sectors',
    },
    'gaia-planets' => {
        description => "Largest number of Gaia planets.",
        points => [18, 12, 6],
        label => 'gaia-planets',
    },
	'planet-types' => {
        description => "Largest number of different planet types.",
        points => [18, 12, 6],
        label => 'planet-types',
    },
    'research-areas' => {
        description => "Position on each cult",
        points => [ 12, 8, 4 ]
		label => 'research-areas',
    }
);

1;

