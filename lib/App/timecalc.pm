package App::timecalc;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter 'import';
our @EXPORT_OK = qw(eval_time_expr);

sub eval_time_expr {
    my $str = shift;

    my ($h, $m, $s) = (0, 0, 0);

    $str =~ s{
                 \s*
                 (?:
                     (?<h1_colon>\d\d?):(?<m1_colon>\d\d?)(?: :(?<s1_colon>\d\d?))? |
                     (?<h1_nocolon>\d\d?)(?<m1_nocolon>\d\d)(?<s1_nocolon>\d\d)?
                 )
                 \s*-\s*
                 (?:
                     (?<h2_colon>\d\d?):(?<m2_colon>\d\d?)(?: :(?<s2_colon>\d\d?))? \s* |
                     (?<h2_nocolon>\d\d?)(?<m2_nocolon>\d\d)(?<s2_nocolon>\d\d)?
                 )
             |
                 \s*\+
                 (?:
                     (?<hplus_colon>\d\d?):(?<mplus_colon>\d\d?)(?: :(?<splus_colon>\d\d?))? |
                     (?<hplus_nocolon>\d\d?)(?<mplus_nocolon>\d\d)(?<splus_nocolon>\d\d)?
                 )
                 \s*
             |
                 \s*\-
                 (?:
                     (?<hminus_colon>\d\d?):(?<mminus_colon>\d\d?)(?: :(?<sminus_colon>\d\d?))? \s* |
                     (?<hminus_nocolon>\d\d?)(?<mminus_nocolon>\d\d)(?<sminus_nocolon>\d\d)?
                 )
                 \s*
         }{

             if (defined $+{h1_colon} || defined $+{h1_nocolon}) {
                 my ($h1, $m1, $s1) = defined $+{h1_colon} ?
                     ($+{h1_colon}  , $+{m1_colon}  , $+{s1_colon}   // 0) :
                     ($+{h1_nocolon}, $+{m1_nocolon}, $+{s1_nocolon} // 0);
                 my ($h2, $m2, $s2) = defined $+{h2_colon} ?
                     ($+{h2_colon}  , $+{m2_colon}  , $+{s2_colon}   // 0) :
                     ($+{h2_nocolon}, $+{m2_nocolon}, $+{s2_nocolon} // 0);
                 if ($h1 > 24) { die "Hour cannot exceed 24: $h1" }
                 if ($h2 > 24) { die "Hour cannot exceed 24: $h2" }
                 if ($h2 < $h1 || $h2 <= $h1 && $m2 <= $m1) { $h2 += 24 }
                 $h += ($h2-$h1);
                 $m += ($m2-$m1);
                 $s += ($s2-$s1);
             } elsif (defined $+{hplus_colon} || defined $+{hplus_nocolon}) {
                 if (defined $+{hplus_colon}) {
                     $h += $+{hplus_colon};
                     $m += $+{mplus_colon};
                     $s += $+{splus_colon} // 0;
                 } else {
                     $h += $+{hplus_nocolon};
                     $m += $+{mplus_nocolon};
                     $s += $+{splus_nocolon} // 0;
                 }
             } elsif (defined $+{hminus_colon} || defined $+{hminus_nocolon}) {
                 if (defined $+{hminus_colon}) {
                     $h -= $+{hminus_colon};
                     $m -= $+{mminus_colon};
                     $s -= $+{sminus_colon} // 0;
                 } else {
                     $h -= $+{hminus_nocolon};
                     $m -= $+{mminus_nocolon};
                     $s -= $+{sminus_nocolon} // 0;
                 }
             }

             "";
         }egsx;

    die "Unexpected string near '$str'" if length $str;

    while ($s < 0) {
        $m--;
        $s += 60;
    }
    while ($s >= 60) {
        $m++;
        $s -= 60;
    }
    while ($m < 0) {
        $h--;
        $m += 60;
    }
    while ($m >= 60) {
        $h++;
        $m -= 60;
    }

    sprintf "+%02d:%02d:%02d", $h, $m, $s;
}

1;
#ABSTRACT: Time calculator

=head1 SYNOPSIS

See included script L<timecalc>.


=head1 DESCRIPTION


=head1 FUNCTIONS

=head2 eval_time_expr


=head1 SEE ALSO

L<datecalc> from L<App::datecalc>. datecalc might be modified to include
L<timecalc>'s features.
