package DateTime::Format::Japanese;
use strict;
use Params::Validate qw( validate validate_pos SCALAR BOOLEAN );
use Exporter;
use vars qw(@ISA $VERSION %EXPORT_TAGS);
use DateTime::Format::Japanese::Common qw(:constants);
use DateTime::Format::Japanese::Era;
BEGIN
{
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    %EXPORT_TAGS = (
        constants => [ qw(
            FORMAT_KANJI_WITH_UNIT FORMAT_KANJI FORMAT_ZENKAKU
            FORMAT_ROMAN FORMAT_ERA FORMAT_GREGORIAN) ]
    );
    Exporter::export_ok_tags('constants');
}
# Got to call these after we define constants

# XXX - OBJECT DEFINITION

my %NewValidate = (
    number_format => { 
        type    => SCALAR,
        default => FORMAT_KANJI
    },
    year_format   => {
        type    => SCALAR,
        default => FORMAT_ERA
    },
    with_gregorian_marker => {
        type    => BOOLEAN,
        default => 0
    },
    with_bc_marker => {
        type    => BOOLEAN,
        default => 0
    },
    with_ampm_marker => {
        type    => BOOLEAN,
        default => 0
    },
    with_day_of_week => {
        type    => BOOLEAN,
        default => 0
    }
);

sub new
{
    my $class = shift;
    my %hash  = validate(@_, \%NewValidate);
    my $self  = bless \%hash, $class;
}

sub number_format
{
    my $self    = shift;
    my $current = $self->{number_format};
    if (@_) {
        my($val) = validate_pos(@_, {
            type => SCALAR,
            callbacks => {
                'is valid number_format' => \&DateTime::Format::Japanese::Common::valid_number_format
            }
        });
        $self->{number_format} = $val;
    }
    return $current;
}

sub year_format
{
    my $self    = shift;
    my $current = $self->{year_format};
    if (@_) {
        my($val) = validate_pos(@_, {
            type => SCALAR,
            callbacks => {
                'is valid year_format' => \&DateTime::Format::Japanese::Common::valid_year_format
            }
        });
        $self->{year_format} = $val;
    }
    return $current;
}

sub with_gregorian_marker
{
    my $self    = shift;
    my $current = $self->{with_gregorian_marker};
    if (@_) {
        my($val) = validate_pos(@_, { type => BOOLEAN });
        $self->{with_gregorian_marker} = $val;
    }
    return $current;
}

sub with_bc_marker
{
    my $self    = shift;
    my $current = $self->{with_bc_marker};
    if (@_) {
        my($val) = validate_pos(@_, { type => BOOLEAN });
        $self->{with_bc_marker} = $val;
    }
    return $current;
}

sub with_ampm_marker
{
    my $self    = shift;
    my $current = $self->{with_ampm_marker};
    if (@_) {
        my($val) = validate_pos(@_, { type => BOOLEAN });
        $self->{with_ampm_marker} = $val;
    }
    return $current;
}

sub with_day_of_week
{
    my $self    = shift;
    my $current = $self->{with_day_of_week};
    if (@_) {
        my($val) = validate_pos(@_, { type => BOOLEAN });
        $self->{with_day_of_week} = $val;
    }
    return $current;
}

# XXX - FORMATTING RELATED STUFF

my @FmtBasicValidate = (
    { isa => 'DateTime' },
);

sub format_year
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    my $year_section = '';

    if ($self->year_format eq DateTime::Format::Japanese::FORMAT_ERA()) {
        $year_section = 
            DateTime::Format::Japanese::Common::format_era($dt, $self->number_format);
    } else {
        my $year = $dt->year;
        if ($year < 0 && $self->with_bc_marker) {
            $year *= -1;
            $year_section .= $DateTime::Format::Japanese::Common::BC_MARKER;
        }

        if ($self->with_gregorian_marker) {
            $year_section .= $DateTime::Format::Japanese::Common::GREGORIAN_MARKER;
        }

        my $restore = undef;
        if ($self->number_format eq FORMAT_KANJI_WITH_UNIT) {
            $restore = $self->number_format(FORMAT_KANJI);
        }

        $year_section .=
            DateTime::Format::Japanese::Common::format_number($year, $self->number_format);
        $year_section .= $DateTime::Format::Japanese::Common::YEAR_MARKER;

        if ($restore) {
            $self->number_format($restore);
        }
    }

    return $year_section;
}

sub format_month
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        DateTime::Format::Japanese::Common::format_common_with_marker(
            $DateTime::Format::Japanese::Common::MONTH_MARKER,
            $dt->month,
            $self->number_format);
}

sub format_day
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        DateTime::Format::Japanese::Common::format_common_with_marker(
            $DateTime::Format::Japanese::Common::DAY_MARKER,
            $dt->day,
            $self->number_format);
}

sub format_hour
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    my $hour = $dt->hour;
    my $ampm = '';

    if ($self->with_ampm_marker) {
        $hour = $dt->hour <= 12 ? $dt->hour : $dt->hour - 12;
        $ampm = $dt->hour <  12 ? 
            $DateTime::Format::Japanese::Common::AM_MARKER :
            $DateTime::Format::Japanese::Common::PM_MARKER;
    }

    return
        $ampm . 
        DateTime::Format::Japanese::Common::format_common_with_marker(
            $DateTime::Format::Japanese::Common::HOUR_MARKER,
            $hour,
            $self->number_format);
}

sub format_minute
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        DateTime::Format::Japanese::Common::format_common_with_marker(
            $DateTime::Format::Japanese::Common::MINUTE_MARKER,
            $dt->minute,
            $self->number_format);
}

sub format_second
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        DateTime::Format::Japanese::Common::format_common_with_marker(
            $DateTime::Format::Japanese::Common::SECOND_MARKER,
            $dt->second,
            $self->number_format);
}

sub format_ymd
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        $self->format_year($dt) .
        $self->format_month($dt) .
        $self->format_day($dt);
}

sub format_time
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        $self->format_hour($dt) .
        $self->format_minute($dt) .
        $self->format_second($dt);
}

sub format_day_of_week
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return
        @DateTime::Format::Japanese::Common::DAY_OF_WEEKS[ $dt->day_of_week - 1 ] .
        $DateTime::Format::Japanese::Common::DAY_OF_WEEK_MARKER;
}

sub format_datetime
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    my $rv = $self->format_ymd($dt) .
        $self->format_time($dt);
    if ($self->with_day_of_week) {
        $rv .= $self->format_day_of_week($dt);
    }
    return $rv;
}

# XXX - PARSING RELATED STUFF

my $RE_MODERN_TIME_COMPONENTS = qr(
    (?:
        ($DateTime::Format::Japanese::Common::RE_AM_PM_MARKER)
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_HOUR_MARKER
        (?:
            ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
            $DateTime::Format::Japanese::Common::RE_MINUTE_MARKER
            (?:
                ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
                $DateTime::Format::Japanese::Common::RE_SECOND_MARKER
            )?
        )?
    )?
)x;
    

my $parse_gregorian = {
    regex       => qr<
        ^
        $DateTime::Format::Japanese::Common::RE_GREGORIAN_MARKER?
        ($DateTime::Format::Japanese::Common::RE_GREGORIAN_YEAR)
        $DateTime::Format::Japanese::Common::RE_YEAR_MARKER
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_MONTH_MARKER
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_DAY_MARKER
        $RE_MODERN_TIME_COMPONENTS
        $DateTime::Format::Japanese::Common::RE_DAY_OF_WEEKS?
        $
    >x,
    params      => [ qw(year month day am_pm hour minute second) ],
    preprocess  => [
        \&DateTime::Format::Japanese::Common::normalize_utf8, ],
    postprocess => [
        \&DateTime::Format::Japanese::Common::normalize_numbers,
        \&DateTime::Format::Japanese::Common::fix_am_pm,
        \&fix_year ]
};

my $parse_gregorian_bc = {
    regex       => qr<
        ^
        ($DateTime::Format::Japanese::Common::RE_BC_MARKER|\-)
        $DateTime::Format::Japanese::Common::RE_GREGORIAN_MARKER?
        ($DateTime::Format::Japanese::Common::RE_GREGORIAN_YEAR)
        $DateTime::Format::Japanese::Common::RE_YEAR_MARKER
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_MONTH_MARKER
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_DAY_MARKER
        $RE_MODERN_TIME_COMPONENTS
        $DateTime::Format::Japanese::Common::RE_DAY_OF_WEEKS?
        $
    >x,
    params      => [ qw(is_bc year month day am_pm hour minute second) ],
    preprocess  => [
        \&DateTime::Format::Japanese::Common::normalize_utf8, ],
    postprocess => [
        \&DateTime::Format::Japanese::Common::normalize_numbers,
        \&DateTime::Format::Japanese::Common::fix_am_pm,
        \&fix_year ]
};

my $parse_with_era  = {
    regex       => qr|^
        ($DateTime::Format::Japanese::Common::RE_ERA_NAME)
        ($DateTime::Format::Japanese::Common::RE_ERA_YEAR)
        $DateTime::Format::Japanese::Common::RE_YEAR_MARKER
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_MONTH_MARKER
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_DAY_MARKER
        $RE_MODERN_TIME_COMPONENTS
        $DateTime::Format::Japanese::Common::RE_DAY_OF_WEEKS?
        $
    |x,
    params      => [ qw(era_name era_year month day am_pm hour minute second) ],
    preprocess  => [
        \&DateTime::Format::Japanese::Common::normalize_utf8, ],
    postprocess => [
        \&DateTime::Format::Japanese::Common::fix_era_year,
        \&DateTime::Format::Japanese::Common::normalize_numbers,
        \&DateTime::Format::Japanese::Common::fix_am_pm,
        \&era2year_modern ]
};

sub fix_year
{
    my %args = @_;
    if (delete $args{parsed}->{is_bc}) {
        $args{parsed}->{year} *= -1;
    }
    1;
}

sub era2year_modern
{
    my %args = @_;

    my $era_name = delete $args{parsed}->{era_name} ||
        return 0;
    my $era_year = delete $args{parsed}->{era_year};
    if ($era_year <= 0) {
        return 0;
    }

    my $era = DateTime::Format::Japanese::Era::lookup_by_name($era_name);

    my $g_year = $era->start->year + $era_year - 1;

    if ($g_year == 1) {
        if ($era->start->month > $args{parsed}->{month}) {
            Carp::croak("Invalid input format: Month " .
                $era->id .
                " is before the beginning of era '$era_name'");
        } elsif ($era->start->day > $args{parsed}->{day}) {
            Carp::croak("Invalid input format: Day " .
                $era->id .
                " is before the beginning of era '$era_name'");
        }
    }

    if ($era->end->is_finite() && $era->end->year < $g_year) {
        Carp::croak("Invalid input format: Year $g_year is after the end of era " . $era->id);
    } elsif ($g_year == $era->end->year) {
        if ($era->start->month < $args{parsed}->{month}) {
            Carp::croak("Invalid input format: Month " .
                $era->id .
                " is after the end of era '$era_name'");
        } elsif ($era->start->day >= $args{parsed}->{day}) {
            Carp::croak("Invalid input format: Day " .
                $era->id .
                " is after the end of era '$era_name'");
        }
    }

    $args{parsed}->{year} = $g_year;

    1;
}

require DateTime::Format::Builder;
DateTime::Format::Builder->create_class(
    parsers => {
        parse_datetime => [ 
            $parse_with_era, $parse_gregorian, $parse_gregorian_bc
        ]
    }
);

1;

__END__

=head1 NAME

DateTime::Format::Japanese - A Japanese DateTime Formatter

=head1 SYNOPSIS

  use DateTime::Format::Japanese;
  my $fmt = DateTime::Format::Japanese->new();

  # or if you want to set options,
  my $fmt = DateTime::Format::Japanese->new(
    number_format         => FORMAT_KANJI,
    year_format           => FORMAT_ERA,
    with_gregorian_marker => 1,
    with_bc_marker        => 1,
    with_ampm_marker      => 1,
    with_day_of_week      => 1
  );

  my $str = $fmt->format_datetime($dt);
  my $dt  = $fmt->parse_datetime("Ê¿À®£±£¶Ç¯£±·î£²£·Æü¸áÁ°£µ»þ£³£°Ê¬");
    
=head1 DESCRIPTION

This module implements a DateTime::Format module that can read Japanese
date notations and create a DateTime object, and vice versa.

  XXX WARNING WARNING WARNING XXX

  Currently DateTime::Format::Japanese only supports Perl 5.7 and up.
  This is because I'm ignorant in the ways of making robust regular
  expressions in Perls <= 5.6.x with Jcode. If anybody can contribute to
  this, I would much appreciate it

  XXX WARNING WARNING WARNING XXX

=head1 METHODS

=head2 new()

This constructor will create a DateTime::Format::Japanese object.
You may optionally pass any of the following parameters:

  number_format         - how to format numbers (default: FORMAT_KANJI)
  year_format           - how to format years (default: FORMAT_ERA)
  with_day_of_week      - include day of week (default: 0)
  with_gregorian_marker - use gregorian marker (default: 0)
  with_bc_marker        - use B.C. marker (default: 0)
  with_am_marker        - use A.M/P.M marker (default: 0)

Please note that all of the above parameters only take effect for
I<formatting>, and not I<parsing>. Parsing is done in a way such
that it accepts any of the known formats that this module can produce.

=head2 $fmt-E<gt>parse_datetime($string)

This function will parse a Japanese date/time string and convert it to a
DateTime object. If the parsing is unsuccessful, it will croak.

This method can be called as a class function as well.

  my $dt = DateTime::Format::Japanese->parse_datetime($string);
  # or
  my $fmt = DateTime::Format::Japanese->new();
  my $fmt->parse_daettime($string);

=head1 FORMATTING METHODS

All of the following methods accept a single parameter, a DateTime object,
and return the appropriate string representation.

  my $dt  = DateTime->now();
  my $fmt = DateTime::Format::Japanese->new(...);
  my $str = $fmt->format_datetime($dt);

=head2 $fmt-E<gt>format_datetime($dt)

Create a complete string representation of a DateTime object in Japanese

=head2 $fmt-E<gt>format_ymd($dt)

Create a string representation of year, month, and date of a  DateTime
object in Japanese

=head2 $fmt-E<gt>format_year($dt)

Create a string representation of the year of a DateTime object in Japanese

=head2 $fmt-E<gt>format_month($dt)

Create a string representation of the month of a DateTime object in Japanese

=head2 $fmt-E<gt>format_day($dt)

Create a string representation of the day (day of month) of a DateTime object
in Japanese

=head2 $fmt-E<gt>format_day_of_week($dt)

Create a string representation of the day of week of a DateTime object in
Japanese

=head2 $fmt-E<gt>format_time($dt)

Create a string representation of the time (hour, minute, second) of a DateTime object in Japanese

=head2 $fmt-E<gt>format_hour($dt)

Create a string representation of the hour of a DateTime object in Japanese

=head2 $fmt-E<gt>format_minute($dt)

Create a string representation of the minute of a DateTime object in Japanese

=head2 $fmt-E<gt>format_second($dt)

Create a string representation of the second of a DateTime object in Japanese

=head1 OPTIONS

=head2 number_format()

Get/Set the number formatting option. Possible values are:

=over 4

=item FORMAT_ROMAN

Formats the numbers in plain ascii roman numerals.

=item FORMAT_KANJI

Formats numbers in kanji numerals without any unit specifiers.

=item FORMAT_ZENKAKU

Formats numbers in zenkaku numerals (double-byte equivalent of roman numerals)

=item FORMAT_KANJI_WITH_UNIT

Formats numbers in kanji numerals, with unit specifiers.

=back

=head2 year_format()

Get/Set the year formatting option. Possible values are:

=over 4

=item FORMAT_ERA

Formats the year using the Japanese era notation.

=item FORMAT_GREGORIAN

Formats the year using the Gregorian notation

=back

=head2 with_gregorian_marker()

Get/Set the option to include the gregorian calendar marker ("À¾Îñ")

=head2 with_bc_marker()

Get/Set the option to include the "B.C." marker instead of a negative year.

=head2 with_ampm_marker()

Get/Set the option to include the AM/PM marker. Implies that the hour
notation is swictched to 1-12 from 1-23

=head2 with_day_of_week

Get/Set the option to include day of week.

=head1 CAVEATS

=head2 Day Of Week

Day Of Weeks are accepted in the parsing, but is not used for generating
DateTime objects. Only the actual date components are passed to the creation of
DateTime object.

=head2 Kanji Dates With Units

Kanji notations have the following limitations, which were :

Gregorian years may only expressed like this: 'Æó¡»¡»»Í', not 'ÆóÀé»Í'

All other fields may be expressed as either '½½»Í' or '°ì»Í'. However,
it will only understand up to the 10s, not anything higher. This is because
of the limit in the range of the fields. 

=head1 AUTHOR

Daisuke Maki E<lt>daisuke@cpan.orgE<gt>

=cut
