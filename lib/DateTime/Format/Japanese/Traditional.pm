package DateTime::Format::Japanese::Traditional;
use strict;
use DateTime::Calendar::Japanese;
use DateTime::Format::Japanese::Common qw(:constants);
use DateTime::Format::Japanese::Era;
use Exporter;
use Params::Validate qw(validate validate_pos SCALAR BOOLEAN);
use constant FORMAT_NUMERIC_MONTH => 'FORMAT_NUMERIC_MONTH';
use constant FORMAT_WAREKI_MONTH => 'FORMAT_WAREKI_MONTH';
use vars qw(@ISA $VERSION %EXPORT_TAGS);
BEGIN
{
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    %EXPORT_TAGS = (
        constants => [ qw(
            FORMAT_KANJI_WITH_UNIT FORMAT_KANJI FORMAT_ZENKAKU
            FORMAT_ROMAN FORMAT_NUMERIC_MONTH FORMAT_WAREKI_MONTH) ]
    );
    Exporter::export_ok_tags('constants');
}
# Got to call these after we define constants


use vars qw(
    @WAREKI_MONTHS @ZODIAC_HOURS %WAREKI2MONTH %ZODIAC2HOUR
    $HOUR_NO_QUARTER_MARKER
    $HOUR_WITH_QUARTER_MARKER
    $RE_WAREKI_MONTH
    $RE_HOUR_NO_QUARTER_MARKER
    $RE_HOUR_WITH_QUARTER_MARKER
    $RE_ZODIAC_HOUR
);

{
    @WAREKI_MONTHS = map {
        DateTime::Format::Japanese::Common::euc2utf8($_)
    } qw(ËÓ·î Ç¡·î ÌïÀ¸ ±¬·î »©·î ¿åÌµ·î Ê¸·î ÍÕ·î Ä¹·î ¿ÀÌµ·î Áú·î »ÕÁö);
    %WAREKI2MONTH = map { ($WAREKI_MONTHS[$_] => $_ + 1) } 0 .. $#WAREKI_MONTHS;

    @ZODIAC_HOURS = map {
        DateTime::Format::Japanese::Common::euc2utf8($_)
    } qw(±¬ Ã¤ Ì¦ ¸á Ì¤ ¿½ ÆÓ Øü °ç »Ò ±¯ ÆÒ);
    %ZODIAC2HOUR = map { ($ZODIAC_HOURS[$_] => $_ + 1) } 0 .. $#ZODIAC_HOURS;

    $HOUR_NO_QUARTER_MARKER = 
        DateTime::Format::Japanese::Common::euc2utf8('¤Î¹ï');
    $HOUR_WITH_QUARTER_MARKER =
        DateTime::Format::Japanese::Common::euc2utf8('¤Ä¹ï');

    $RE_WAREKI_MONTH = DateTime::Format::Japanese::Common::make_re(join( "|",
        map { DateTime::Format::Japanese::Common::make_utf8_re_str($_) }
        @WAREKI_MONTHS ));
    $RE_HOUR_NO_QUARTER_MARKER =
        DateTime::Format::Japanese::Common::make_utf8_re(
            $HOUR_NO_QUARTER_MARKER);
    $RE_HOUR_WITH_QUARTER_MARKER =
        DateTime::Format::Japanese::Common::make_utf8_re(
            $HOUR_WITH_QUARTER_MARKER);
    $RE_ZODIAC_HOUR = DateTime::Format::Japanese::Common::make_re( join( '|', map {
        DateTime::Format::Japanese::Common::make_utf8_re_str($_) } @ZODIAC_HOURS) );
}

my %NewValidate = (
    number_format => { 
        type    => SCALAR,
        default => FORMAT_KANJI
    },
    month_format => {
        type => SCALAR,
        default => FORMAT_NUMERIC_MONTH
    },
    with_traditional_marker => {
        type => BOOLEAN,
        default => 1
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

sub month_format
{
    my $self    = shift;
    my $current = $self->{month_format};
    if (@_) {
        my($val) = validate_pos(@_, {
            type => SCALAR,
            callbacks => {
                'is valid month_format' => sub {
                    $_[0] eq FORMAT_NUMERIC_MONTH ||
                    $_[0] eq FORMAT_WAREKI_MONTH
                }
            }
        });
        $self->{month_format} = $val;
    }
    return $current;
}

sub with_traditional_marker
{
    my $self    = shift;
    my $current = $self->{with_traditional_marker};
    if (@_) {
        my($val) = validate_pos(@_, { type => BOOLEAN });
        $self->{with_traditional_marker} = $val;
    }
    return $current;
}

my @FmtBasicValidate = (
    { isa => 'DateTime::Calendar::Japanese' },
);

sub format_datetime
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return $self->format_ymd($dt) .
        $self->format_time($dt);
}

sub format_year
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    my $era_name = 
        DateTime::Format::Japanese::Era::lookup_name_by_id($dt->era->id);

    my $rv = '';
    if ($self->with_traditional_marker) {
        $rv .= $DateTime::Format::Japanese::Common::TRADITIONAL_MARKER;
    }
    $rv .= $era_name .
        DateTime::Format::Japanese::Common::format_number(
            $dt->era_year, $self->number_format) . 
        $DateTime::Format::Japanese::Common::YEAR_MARKER;
    return $rv;
}

sub format_month
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    if ($self->month_format eq FORMAT_WAREKI_MONTH) {
        return $WAREKI_MONTHS[ $dt->month - 1 ];
    } else {
        return
            DateTime::Format::Japanese::Common::format_common_with_marker(
                $DateTime::Format::Japanese::Common::MONTH_MARKER,
                $dt->month,
                $self->number_format);
    }
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

sub format_ymd
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    return $self->format_year($dt) .
        $self->format_month($dt) .
        $self->format_day($dt);

}

sub format_time
{
    my $self = shift;
    my ($dt) = validate_pos(@_, @FmtBasicValidate);

    if ($dt->hour_quarter > 1) {
       return
            $ZODIAC_HOURS[ $dt->hour - 1 ] .
            DateTime::Format::Japanese::Common::format_number(
                $dt->hour_quarter, $self->number_format) .
            $HOUR_WITH_QUARTER_MARKER;
    } else {
        return $ZODIAC_HOURS[ $dt->hour - 1 ] .
            $HOUR_NO_QUARTER_MARKER;
    }
}

sub fix_era_name
{
    my %args = @_;
    my $era = 
        DateTime::Format::Japanese::Era::lookup_by_name($args{parsed}->{era_name});

    if (!$era) {
        return 0;
    }

    $args{parsed}->{era_name} = $era->id;
}

sub fix_wareki_month
{
    my %args = @_;
    my $w_m = delete $args{parsed}->{wareki_month};
    if (defined($w_m)) {
        return $args{parsed}->{month} = $WAREKI2MONTH{ $w_m };
    }
    1;
}
    

sub fix_zodiac_hour
{
    my %args = @_;

    if (exists $args{parsed}->{zodiac_hour} ) {
        my $zh = delete $args{parsed}->{zodiac_hour};
        if (defined($zh)) {
            return $args{parsed}->{hour} = $ZODIAC2HOUR{ $zh };
        }
    }
    1;
}

sub fix_hour_quarter
{
    my %args = @_;
    if (exists $args{parsed}->{hour_quarter} && $args{parsed}->{hour_quarter} !~ /^[0-9]$/) {
        my $h_q = delete $args{parsed}->{hour_quarter} ;
        return $args{parsed}->{hour_quarter} =
            $DateTime::Format::Japanese::Common::JP2ASCII{ $h_q };
    }

    1;
}

my $parse_standard = {
    regex => qr<
        ^
        $DateTime::Format::Japanese::Common::RE_TRADITIONAL_MARKER?
        ($DateTime::Format::Japanese::Common::RE_ERA_NAME)
        ($DateTime::Format::Japanese::Common::RE_ERA_YEAR)
        $DateTime::Format::Japanese::Common::RE_YEAR_MARKER
        (?:
            (?:
                ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
                $DateTime::Format::Japanese::Common::RE_MONTH_MARKER
            )
            |
            ($RE_WAREKI_MONTH)
        )
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_DAY_MARKER
        (?:($RE_ZODIAC_HOUR)
        $RE_HOUR_NO_QUARTER_MARKER)?
        $
    >x,
    constructor => [ 'DateTime::Calendar::Japanese', 'new' ],
    params      => [ qw(era_name era_year month wareki_month day zodiac_hour) ],
    preprocess  => [
        \&DateTime::Format::Japanese::Common::normalize_utf8, ],
    postprocess => [
        \&fix_era_name,
        \&DateTime::Format::Japanese::Common::fix_era_year,
        \&DateTime::Format::Japanese::Common::normalize_numbers,
        \&fix_wareki_month,
        \&fix_zodiac_hour,
        ]
};

my $parse_standard_with_quarter = {
    regex => qr<
        ^
        $DateTime::Format::Japanese::Common::RE_TRADITIONAL_MARKER?
        ($DateTime::Format::Japanese::Common::RE_ERA_NAME)
        ($DateTime::Format::Japanese::Common::RE_ERA_YEAR)
        $DateTime::Format::Japanese::Common::RE_YEAR_MARKER
        (?:
            (?:
                ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
                $DateTime::Format::Japanese::Common::RE_MONTH_MARKER
            )
            |
            ($RE_WAREKI_MONTH)
        )
        ($DateTime::Format::Japanese::Common::RE_TWO_DIGITS)
        $DateTime::Format::Japanese::Common::RE_DAY_MARKER
        (?:
            ($RE_ZODIAC_HOUR)
            ($DateTime::Format::Japanese::Common::RE_JP_OR_ASCII_NUM)
            $RE_HOUR_WITH_QUARTER_MARKER
        )?
        $
    >x,
    constructor => [ 'DateTime::Calendar::Japanese', 'new' ],
    params      => [ qw(era_name era_year month wareki_month day zodiac_hour hour_quarter) ],
    preprocess  => [
        \&DateTime::Format::Japanese::Common::normalize_utf8, ],
    postprocess => [
        \&fix_era_name,
        \&DateTime::Format::Japanese::Common::fix_era_year,
        \&DateTime::Format::Japanese::Common::normalize_numbers,
        \&fix_wareki_month,
        \&fix_zodiac_hour,
        \&fix_hour_quarter,
        ]
};

require DateTime::Format::Builder;
DateTime::Format::Builder->create_class(
    parsers => {
        parse_datetime => [
            $parse_standard,
            $parse_standard_with_quarter
        ]
    }
);

1;

__END__

=head1 NAME

DateTime::Format::Japanese::Traditional - A Japanese DateTime Formatter For Traditional Japanese Calendar

=head1 SYNOPSIS

  use DateTime::Format::Japanese::Traditional;
  my $fmt = DateTime::Format::Japanese::Traditional->new();

  # or if you want to set options,
  my $fmt = DateTime::Format::Japanese::Traditional->new(
    number_format           => FORMAT_KANJI,
    month_format            => FORMAT_WAREKI_MONTH,
    with_traditional_marker => 1
  );

  my $str = $fmt->format_datetime($dt);
  my $dt  = $fmt->parse_datetime("Ê¿À®£±£¶Ç¯£±·î£²£·Æü¸áÁ°£µ»þ£³£°Ê¬");

=head1 DESCRIPTION

This module implements a DateTime::Format module that can read tradtional
Japanese date notations and create a DateTime::Calendar::Japanese object,
and vice versa.

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

  number_format           - how to format numbers (default: FORMAT_KANJI)
  month_format            - how to format months (default: FORMAT_NUMERIC_MONTH)
  with_traditional_marker - use traditional calendar marker (default: 0)

Please note that all of the above parameters only take effect for
I<formatting>, and not I<parsing>. Parsing is done in a way such
that it accepts any of the known formats that this module can produce.

=head2 $fmt-E<gt>parse_datetime($string)

This function will parse a traditional Japanese date/time string and convert
it to a DateTime::Calendar::Japanese object. If the parsing is unsuccessful
 it will croak.

This method can be called as a class function as well.

  my $dt = DateTime::Format::Japanese::Traditional->parse_datetime($string);
  # or
  my $fmt = DateTime::Format::Japanese::Traditional->new();
  my $fmt->parse_daettime($string);

=head1 FORMATTING METHODS

All of the following methods accept a single parameter, a
DateTime::Calendar::Japanese object, and return the appropriate string
representation.

  my $dt  = DateTime->now();
  my $fmt = DateTime::Format::Japanese::Traditional->new(...);
  my $str = $fmt->format_datetime($dt);

=head2 $fmt-E<gt>format_datetime($dt)

Create a complete string representation of a DateTime::Calendar::Japanese object in Japanese

=head2 $fmt-E<gt>format_ymd($dt)

Create a string representation of year, month, and date of a  DateTime
object in Japanese

=head2 $fmt-E<gt>format_year($dt)

Create a string representation of the year of a DateTime::Calendar::Japanese object in Japanese

=head2 $fmt-E<gt>format_month($dt)

Create a string representation of the month of a DateTime::Calendar::Japanese object in Japanese

=head2 $fmt-E<gt>format_day($dt)

Create a string representation of the day (day of month) of a DateTime::Calendar::Japanese object
in Japanese

=head2 $fmt-E<gt>format_time($dt)

Create a string representation of the time (hour, minute, second) of a DateTime::Calendar::Japanese object in Japanese

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

=head2 month_format()

Get/Set the month formatting option. Possible values are:

=over 4

=item FORMAT_NUMERIC_MONTH

Formats the month using numerals.

=item FORMAT_WAREKI_MONTH

Formtas the month using traditional Japanese month names.

=back

=head2 with_traditional_marker()

Get/Set the option to include a marker that declares the date as
a traditional Japanese date.

=head1 AUTHOR

Daisuke Maki E<lt>daisuke@cpan.orgE<gt>

=cut
