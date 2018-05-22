package terra_mystica;

use strict;
use Readonly;

use Game::Constants;

use scoring;
use federations;

sub maybe_setup_pool() {
    return if $game{pool};
    setup_pool();
}

sub setup_pool {
    $game{pool} = {
        # Resources
        C => 1000,
        O => 1000,
        K => 1000,
        Q => 1000,
        PT => 1000,
        VP => 1000,

        # Power
        P1 => 10000,
        P2 => 10000,
        P3 => 10000,

        # Cult tracks
        TERRAFORMING => 100,
        NAVIGATION => 100,
        ARTIFICIAL_INTELLIGENCE => 100,
        GAIA_PROJECT => 100,
        ECONOMY => 100,
        SCIENCE => 100,
        KEY => 100,

        # Temporary pseudo-resources for tracking activation effects
        TERRAFORM => 10000,
        FREE_TF => 10000,
        FREE_TS => 10000,
        FREE_M => 10000,
        TELEPORT_NO_TF => 10000,
        TF_NEED_HEX_ADJACENCY => 10000,
        RESEARCH => 10000,
        LOSE_RESEARCH => 10000,
        GAIN_TECH => 10000,
        GAIN_SHIP => 10000,
        GAIN_FED => 10000,
        GAIN_ACTION => 10000,
        PICK_COLOR => 10000,
        FED_SIZE => 10000,
        LOSE_PT => 10000,
        CULTS_ON_SAME_TRACK => 10000,
        GAIN_P3_FOR_VP => 10000,
    };

    $game{pool}{"ACT$_"}++ for 1..6;

    for (keys %tiles) {
        my $option = $tiles{$_}{option};
        if (defined $option and not defined $game{options}{$option}) {
            next;
        }
        if (/^BON/) {
            $game{pool}{$_}++;
        } elsif (/^TECH/) {
            $game{pool}{$_} += $tiles{$_}{count} || 4;
        } elsif (/^FED/) {
            $game{pool}{$_} += $tiles{$_}{count} || 3;
        } elsif (/^SCORE/) {
            $game{score_pool}{$_}++;
        }
    }
}

sub adjust_resource;

Readonly my %resource_aliases => (
    KNOWLEDGE => 'K',
    POWER => 'PW',
    'POWER TOKEN' => 'PT',
    ORE => 'O',
    COIN => 'C',
    COINS => 'C',
    QIC => 'Q',
);

sub alias_resource {
    my $type = shift;
    return $resource_aliases{$type} // $type;
}

sub pay {
    my ($faction, $cost, $discount) = @_;

    for my $currency (keys %{$cost}) {
        my $amount = $cost->{$currency};
        if (defined $discount and $discount->{$currency}) {
            $amount -= $discount->{$currency};
        }
        adjust_resource $faction, $currency, -$amount;
    }
}

sub gain {
    my ($faction, $cost, $source) = @_;

    my @c = sort { $b eq 'KEY' } keys %{$cost};
    for my $currency (@c) {
        my $amount = $cost->{$currency};
        if (ref $amount) {
            die "Internal error: tried to gain a reference multiple times\n" if $faction->{$currency};
            $faction->{$currency} = clone $amount;
        } else {
            adjust_resource $faction, $currency, $amount, $source;
        }
    }
}

sub warn_if_cant_gain {
    my ($faction, $gain, $source) = @_;
    return if !$game{in_preview};
    for my $resource (keys %{$gain}) {
        my $amount = $gain->{$resource};
        my $current = $faction->{"$resource"} // 0;
        my $max = exists $faction->{"MAX_$resource"} ? $faction->{"MAX_$resource"} : undef;
        my $pretty_max = $max;
        my $current_pretty = $current;
        if ($resource eq 'PW') {
            $current = $faction->{P2} + $faction->{P3} * 2;
            $max = ($faction->{P1} + $faction->{P2} + $faction->{P3}) * 2;
            $pretty_max = "0/0/".($max / 2);
            $current_pretty = "$faction->{P1}/$faction->{P2}/$faction->{P3}";
        }
        if (defined $max and
            $amount > $max - $current) {
            preview_warn("Currently at $current_pretty $resource, can't gain $amount more from $source (max $pretty_max)");
        }
    }
}

sub maybe_gain_faction_special {
    my ($faction, $type, $mode) = @_;

    return 0 if !exists $faction->{special}{mode};
    return 0 if $faction->{special}{mode} ne $mode;

    my $enable_if = $faction->{special}{enable_if};
    if ($enable_if) {
        for my $building (keys %{$enable_if}) {
            return if $faction->{buildings}{$building}{level} != $enable_if->{$building};
        }
    }

    my $record = $faction->{special}{$type};

    return 0 if !$record;

    gain $faction, $record, 'faction';

    1;
}

sub gain_power {
    my ($faction, $count) = @_;

    for (1..$count) {
        if ($faction->{P1}) {
            $faction->{P1}--;
            $faction->{P2}++;
        } elsif ($faction->{P2}) {
            $faction->{P2}--;
            $faction->{P3}++;
        } else {
            return $_ - 1;
        }
    }

    return $count;
}

sub maybe_gain_power_from_cult {
    my ($faction, $cult, $old_value, $new_value) = @_;

    if ($old_value <= 2 && $new_value > 3) {
        adjust_resource $faction, 'PW', 3;
    }
    if ($old_value <= 4 && $new_value > 5) {
        if ($faction->{KEY} < 1) {
            $faction->{$cult} = 4;
            if (!$game{options}{'manual-fav5'}) {
                $faction->{cult_blocked}{$cult} = 1;
            }
            return;
        }

        if ($game{acting}->should_wait_for_cultists($cult) and
            $faction->{name} ne 'cultists') {
            die "Must wait for cultist decision before advancing to level 5 in $cult. (Use the \"wait\" command).\n";
        }
        
        adjust_resource $faction, 'KEY', -1;
        # Block others from this space
        for my $other_faction ($game{acting}->factions_in_order()) {
            if ($other_faction != $faction) {
                $other_faction->{"MAX_$cult"} = 4;
            }
        }
    }
    if ($old_value == 5 && $new_value < 5) {
        adjust_resource $faction, 'KEY', 1;
        for my $other_faction ($game{acting}->factions_in_order()) {
            $other_faction->{"MAX_$cult"} = 5;
        }
    }
}

sub advance_track {
    my ($faction, $track_name, $track, $free) = @_;

    if (!$free) {
        pay $faction, $track->{advance_cost};
    }
    
    if ($track->{advance_gain}) {
        my $gain = $track->{advance_gain}[$track->{level}];
        gain $faction, $gain, "advance_$track_name";
    }

    if (++$track->{level} > $track->{max_level}) {
        die "Can't advance $track_name from level $track->{level}\n"; 
    }
}

sub adjust_resource {
    my ($faction, $type, $delta, $source) = @_;

    $type = alias_resource $type;

    if ($delta eq 'PLAYER_COUNT' or $delta eq 'OPPONENT_COUNT') {
        my $count = scalar grep {
            !$_->{dummy}
        } $game{acting}->factions_in_order();

        if ($delta eq 'OPPONENT_COUNT') {
            $delta = $count - 1;
        } else {
            $delta = $count;
        }
    }

    if ($type eq 'VP') {
        $faction->{vp_source}{$source || 'unknown'} += $delta;
        $game{events}->faction_event($faction, "vp", $delta);
    }

    if ($type eq 'PT' and $delta < 0) {
        $type = 'LOSE_PT';
        $delta = -$delta;
    }

    if ($type =~ 'GAIN_(TELEPORT|SHIP)') {
        my $track_name = lc $1;
        for (1..$delta) {
            my $track = $faction->{$track_name};
            my $gain = $track->{advance_gain}[$track->{level}];
            if ($track->{level}  < $track->{max_level}) {
                gain $faction, $gain, "advance_$track_name";
                $track->{level}++
            }
        }
        $type = '';
    } elsif ($type eq 'GAIN_ACTION') {
        $faction->{allowed_actions} += $delta;
        return;
    } elsif ($type eq 'LOSE_PT') {
        for (1..abs $delta) {
            if ($faction->{P1}) {
                $faction->{P1}--;
            } elsif ($faction->{P2}) {
                $faction->{P2}--;
            } elsif ($faction->{P3}) {
                $faction->{P3}--;
            } else {
                die "Don't have $delta power tokens to spend\n"
            }
        }
        return;
    } elsif ($type eq 'PW') {
        if ($delta > 0) {
            gain_power $faction, $delta;
            $type = '';
        } else {
            $faction->{P1} -= $delta;
            $faction->{P3} += $delta;
            $type = 'P3';
        }
    } else {
        my $orig_value = $faction->{$type};

        my $replaced = 0;

        for (1..$delta) {
            $replaced |= maybe_gain_faction_special $faction, $type, 'replace'
        }

        return if $replaced;

        # Pseudo-resources not in the pool, but revealed by removing
        # buildings.
        if ($type !~ /^ACT[A-Z]+\d?$/) {
            if (!defined $game{pool}{$type} or $game{pool}{$type} < $delta) {
                die "Not enough '$type' in pool\n";
            }
            $game{pool}{$type} -= $delta;
        }

        $faction->{$type} += $delta;

        if (exists $faction->{"MAX_$type"}) {
            my $max = $faction->{"MAX_$type"};
            if ($faction->{$type} > $max) {
                $faction->{$type} = $max;
            }
        }

        if ($type =~ /^TECH/) {
            if ($faction->{$type} > 1) {
                die "Can't take two copies of $type\n";
            }
            
            $faction->{stats}{$type}{round} = "$game{round}";
            $faction->{stats}{$type}{order} = scalar grep {/^TECH/} keys %{$faction};

            gain $faction, $tiles{$type}{gain}, $type;

            # Hack
            if ($type eq 'FAV5') {
                my $tw_count = 0;
                for my $loc (@{$faction->{locations}}) {
                    $tw_count += detect_towns_from $faction, $loc;
                }
            }

            $game{events}->faction_event($faction, "favor:$type", 1);
            $game{events}->faction_event($faction, "favor:any", 1);
        }

        if ($type =~ /^FED/) {
            for (1..$delta) {
                warn_if_cant_gain $faction, $tiles{$type}{gain}, $type;
                gain $faction, $tiles{$type}{gain}, 'FED',
            }

            $game{events}->faction_event($faction, "federation:$type", 1);
            $game{events}->faction_event($faction, "federation:any", 1);
        }

        if ($type eq 'KEY') {
            if ($faction->{cult_blocked} and
                $faction->{KEY} >= keys %{$faction->{cult_blocked}}) {
                for my $cult (keys %{$faction->{cult_blocked}}) {
                    gain $faction, { $cult => 1 };
                }
                delete $faction->{cult_blocked};
            }
        }

        if (grep { $_ eq $type } @cults) {
            my $new_value = $faction->{$type};
            maybe_gain_power_from_cult $faction, $type, $orig_value, $new_value;
        }

        for (1..$delta) {
            maybe_score_current_score_tile $faction, $type, 'gain';
            maybe_gain_faction_special $faction, $type, 'gain';
        }
    }

    if ($type =~ /^BON/) {
        $faction->{C} += $game{bonus_coins}{$type}{C};
        $game{bonus_coins}{$type}{C} = 0;
    }

    if ($type and $faction->{$type} < 0) {
        die "Not enough '$type' in ".($faction->{name})."\n";
    }
}

# Record any possible leech events from a build by a faction int the given
# hex. 
sub note_leech {
    my ($from_faction, $where) = @_;
    my %this_leech = compute_leech @_;
    my $leech_id = ++$game{leech_id};

    # Note -- the exact turn order matters when the cultists are in play.
    for my $faction ($game{acting}->factions_in_order_from($from_faction, 1)) {
        my $color = $faction->{color}; 
        
        next if !$this_leech{$color};
        my $amount = $this_leech{$color};
        my $actual = min $this_leech{$color}, $faction->{P1} * 2 + $faction->{P2};
        if ($faction->{dropped}) {
            $actual = 0;
        }

        $game{acting}->require_action($faction,
                                      {
                                          type => 'leech',
                                          from_faction => $from_faction->{name},
                                          amount => $amount,
                                          actual => $actual,
                                          leech_id => $leech_id
                                      });
        if ($actual) {
            $from_faction->{leech_not_rejected}{$leech_id}++;
            $from_faction->{leech_rejected}{$leech_id} = 0;
        }
    }

    for (keys %this_leech) {
	$game{ledger}->report_leech($_, $this_leech{$_});
    }

    return %this_leech;
}

sub pretty_resource_delta {
    for my $x (@_) {
        $x->{PW} = $x->{P2} + 2 * $x->{P3};
        $x->{CULT} += $x->{$_} for @cults;
    }

    my (%old_data) = %{+shift};
    my (%new_data) = %{+shift};

    my @fields = keys %old_data;
    my %delta = map { $_, $new_data{$_} - $old_data{$_} } @fields;

    my %pretty_delta = map { $_, { delta => $delta{$_},
                                   value => $new_data{$_} } } @fields;
    $pretty_delta{PW}{value} = sprintf "%d/%d/%d", @new_data{'P1','P2','P3'};
    $pretty_delta{CULT}{value} = sprintf "%d/%d/%d/%d", @new_data{@cults};

    %pretty_delta;
}

1;
