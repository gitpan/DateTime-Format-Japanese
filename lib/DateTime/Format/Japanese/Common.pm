package DateTime::Format::Japanese::Common;
use strict;
use Exporter;
use vars qw(@ISA $VERSION %EXPORT_TAGS);
use constant FORMAT_KANJI_WITH_UNIT  => 'FORMAT_KANJI_WITH_UNIT';
use constant FORMAT_KANJI            => 'FORMAT_KANJI';
use constant FORMAT_ZENKAKU          => 'FORMAT_ZENKAKU';
use constant FORMAT_ROMAN            => 'FORMAT_ROMAN';
use constant FORMAT_ERA              => 'FORMAT_ERA';
use constant FORMAT_GREGORIAN        => 'FORMAT_GREGORIAN';
BEGIN
{
    $VERSION = '0.01';
    @ISA     = qw(Exporter);
    %EXPORT_TAGS = (
        constants => [ qw(
            FORMAT_KANJI_WITH_UNIT FORMAT_KANJI FORMAT_ZENKAKU
            FORMAT_ROMAN FORMAT_ERA FORMAT_GREGORIAN) ]
    );
    Exporter::export_ok_tags('constants');
}
use DateTime::Format::Japanese::Era;

BEGIN
{
    my($euc2utf8_sub, $normalize_utf8_sub);

    if ($] >= 5.007) {
        require Encode;
        require Encode::Guess;
        $euc2utf8_sub = sub {
            Encode::is_utf8($_[0]) ? $_[0] : Encode::decode('euc-jp', $_[0]);
        };
        $normalize_utf8_sub = sub
        {
            my %args = @_;
            if (Encode::is_utf8($args{input})) {
                return $args{input};
            } else {
                my $enc  = Encode::Guess::guess_encoding(
                    $args{input}, qw(euc-jp shiftjis 7bit-jis)) or
                die "Could not guess encoding for input!";
                return Encode::decode($enc->name, $args{input});
            }
        }
    } else {
        require Jcode;
        # Jcode does the guessing, so we just use the same sub for both
        $normalize_utf8_sub = sub {
            Jcode->new($_[0])->utf8;
        };
        $euc2utf8_sub = $normalize_utf8_sub;
    }

    {
        no strict 'refs';
        *euc2utf8       = $euc2utf8_sub;
        *normalize_utf8 = $normalize_utf8_sub;
    }
}

sub make_utf8_re_str
{
    my $euc_jp = shift;
    my $u = euc2utf8($euc_jp);
    my $l = length($u);
    return sprintf( '\x{%04X}' x $l, unpack('U ' x $l, $u));
}

sub make_utf8_re
{
    make_re(make_utf8_re_str(@_));
}

sub make_re
{
    my $re = shift;
    return qr($re);
}

# Declare a bunch of variables
use vars qw(
    @DAY_OF_WEEKS
    @ZENKAKU_NUMBERS @KANJI_NUMBERS %ZENKAKU2ASCII %KANJI2ASCII %JP2ASCII
    %AMPM
    $KANJI_TEN
    $KANJI_ZERO
    $BC_MARKER
    $GREGORIAN_MARKER
    $YEAR_MARKER
    $MONTH_MARKER
    $DAY_MARKER
    $DAY_MARKER
    $HOUR_MARKER
    $MINUTE_MARKER
    $SECOND_MARKER
    $AM_MARKER
    $PM_MARKER
    $DAY_OF_WEEK_SHORT_MARKER
    $DAY_OF_WEEK_MARKER
    $TRADITIONAL_MARKER
    $RE_KANJI_TEN
    $RE_KANJI_ZERO
    $RE_BC_MARKER
    $RE_GREGORIAN_MARKER
    $RE_YEAR_MARKER
    $RE_MONTH_MARKER
    $RE_DAY_MARKER
    $RE_DAY_MARKER
    $RE_HOUR_MARKER
    $RE_MINUTE_MARKER
    $RE_SECOND_MARKER
    $RE_AM_MARKER
    $RE_PM_MARKER
    $RE_TRADITIONAL_MARKER
    $RE_ZENKAKU_NUM
    $RE_KANJI_NUM
    $RE_ZENKAKU_NUM
    $RE_JP_OR_ASCII_NUM
    $RE_GREGORIAN_YEAR
    $RE_ERA_YEAR_SPECIAL
    $RE_ERA_YEAR
    $RE_ERA_NAME
    $RE_TWO_DIGITS
    $RE_AM_PM_MARKER
    $RE_DAY_OF_WEEKS
);

{ # XXX - eh, not need to put this in different scope, but makes this stand out
    $KANJI_TEN        = euc2utf8('½½');
    $KANJI_ZERO       = euc2utf8('Îí');
    $BC_MARKER        = euc2utf8('µª¸µÁ°');
    $GREGORIAN_MARKER = euc2utf8('À¾Îñ');
    $YEAR_MARKER      = euc2utf8('Ç¯');
    $MONTH_MARKER     = euc2utf8('·î');
    $DAY_MARKER       = euc2utf8('Æü');
    $HOUR_MARKER      = euc2utf8('»ş');
    $MINUTE_MARKER    = euc2utf8('Ê¬');
    $SECOND_MARKER    = euc2utf8('ÉÃ');
    $AM_MARKER        = euc2utf8('¸áÁ°');
    $PM_MARKER        = euc2utf8('¸á¸å');
    $TRADITIONAL_MARKER = euc2utf8('µìÎñ');
    $DAY_OF_WEEK_SHORT_MARKER = euc2utf8('ÍË');
    $DAY_OF_WEEK_MARKER = $DAY_OF_WEEK_SHORT_MARKER . $DAY_MARKER;

    @ZENKAKU_NUMBERS = map{ euc2utf8($_) } qw(£° £± £² £³ £´ £µ £¶ £· £¸ £¹);
    @KANJI_NUMBERS   = map{ euc2utf8($_) } qw(¡» °ì Æó »° »Í ¸Ş Ï» ¼· È¬ ¶å);
    %ZENKAKU2ASCII = map { ($ZENKAKU_NUMBERS[$_] => $_) } 0..$#ZENKAKU_NUMBERS;
    %KANJI2ASCII   = map { ($KANJI_NUMBERS[$_] => $_) } 0.. $#KANJI_NUMBERS;
    $KANJI2ASCII{ $KANJI_ZERO } = 0;
    %JP2ASCII = (%ZENKAKU2ASCII, %KANJI2ASCII);

    @DAY_OF_WEEKS = map { euc2utf8($_) } qw( ·î ²Ğ ¿å ÌÚ ¶â ÅÚ Æü );

    %AMPM = (
        $AM_MARKER =>  0,
        $PM_MARKER => 1
    );

    $RE_DAY_OF_WEEKS = make_re(
        '(?:' . join( '|', map { make_utf8_re_str($_) } @DAY_OF_WEEKS ) . ')' .
        make_utf8_re_str($DAY_OF_WEEK_SHORT_MARKER) . 
        '(?:' . make_utf8_re_str($DAY_MARKER) . ')?');

    $RE_ZENKAKU_NUM = make_re( sprintf( '[%s]',
        make_utf8_re_str( join('', @ZENKAKU_NUMBERS) ) ) );

    $RE_KANJI_NUM = make_re( sprintf( '[%s]',
        make_utf8_re_str( join('', @KANJI_NUMBERS) ) ) );
    $RE_ZENKAKU_NUM = make_re( sprintf( '[%s]',
        make_utf8_re_str( join('', @ZENKAKU_NUMBERS, @KANJI_NUMBERS) ) ) );
    $RE_JP_OR_ASCII_NUM    = qr([0-9]|$RE_ZENKAKU_NUM);
    $RE_BC_MARKER          = make_utf8_re($BC_MARKER);
    $RE_GREGORIAN_MARKER   = make_utf8_re($GREGORIAN_MARKER);
    $RE_TRADITIONAL_MARKER = make_utf8_re($TRADITIONAL_MARKER);
    $RE_AM_PM_MARKER       = make_re( join( '|',
        make_utf8_re_str($AM_MARKER), make_utf8_re_str($PM_MARKER), '') );
    $RE_YEAR_MARKER        = make_utf8_re($YEAR_MARKER);
    $RE_MONTH_MARKER       = make_utf8_re($MONTH_MARKER);
    $RE_DAY_MARKER         = make_utf8_re($DAY_MARKER);
    $RE_HOUR_MARKER        = make_utf8_re($HOUR_MARKER);
    $RE_MINUTE_MARKER      = make_utf8_re($MINUTE_MARKER);
    $RE_SECOND_MARKER      = make_utf8_re($SECOND_MARKER);
    $RE_KANJI_TEN          = make_utf8_re($KANJI_TEN);
    $RE_KANJI_ZERO         = make_utf8_re($KANJI_ZERO);

    $RE_TWO_DIGITS         = qr(
        ${RE_KANJI_NUM}?${RE_KANJI_TEN}?${RE_KANJI_NUM} |
        ${RE_ZENKAKU_NUM}?${RE_ZENKAKU_NUM}             | 
        [0-9]?[0-9]
    )x;
    
    $RE_GREGORIAN_YEAR     = qr(-?$RE_JP_OR_ASCII_NUM+);
    $RE_ERA_YEAR_SPECIAL   = make_utf8_re('¸µ');
    $RE_ERA_YEAR           = qr($RE_ERA_YEAR_SPECIAL|$RE_TWO_DIGITS);
    $RE_ERA_NAME           = make_re(join( "|",
        map { make_utf8_re_str($_)
    } keys %DateTime::Format::Japanese::Era::ERA_NAME2ID) );
}

my %valid_number_format = (
    FORMAT_KANJI_WITH_UNIT() => 1,
    FORMAT_KANJI()           => 1,
    FORMAT_ZENKAKU()         => 1,
    FORMAT_ROMAN()           => 1,
);

sub valid_number_format  { exists $valid_number_format{$_[0]} }

my %valid_year_format = (
    FORMAT_ERA()       => 1,
    FORMAT_GREGORIAN() => 1
);

sub valid_year_format { exists $valid_year_format{$_[0]} }

# Era year 1 can be written as "¸µÇ¯"
sub fix_era_year
{
    my %args = @_;
    if ($args{parsed}->{era_year} =~ /$RE_ERA_YEAR_SPECIAL/) {
        $args{parsed}->{era_year} = 1;
    }
    return 1;
}

sub normalize_numbers
{
    my %args = @_;
    foreach my $key qw(year month day era_year hour minute second) {
        if (defined $args{parsed}->{$key}) {
            $args{parsed}->{$key} =~ s/^$RE_KANJI_TEN/1/;
            $args{parsed}->{$key} =~ s/$RE_KANJI_TEN//;
        }

        # check for definedness here so that we don't get use uninitialized
        # ... warnings  in the substitution, plus so that DateTime doesn't
        # complain + it uses the appropriate default value
        if (!defined $args{parsed}->{$key}) {
            delete $args{parsed}->{$key};
        }

        if (exists $args{parsed}->{$key} && defined($args{parsed}->{$key})) {
            $args{parsed}->{$key} =~ s/($RE_KANJI_NUM|$RE_ZENKAKU_NUM)/$JP2ASCII{$1}/ge;
        }
    }

    return 1;
}

sub fix_am_pm
{
    my %args = @_;
    if (my $am_pm = delete $args{parsed}->{am_pm}) {
        if (!exists $AMPM{ $am_pm }) {
            return 0;
        }

        my $is_pm = $AMPM{ $am_pm };

        if (!$is_pm && $args{parsed}->{hour} >= 12) {
            return 0;
        }

        if ($is_pm && $args{parsed}->{hour} < 12) {
            $args{parsed}->{hour} += 12;
        }
    }
    return 1;
}

sub format_number
{
    my($number, $number_format) = @_;

    if($number_format eq FORMAT_KANJI_WITH_UNIT()) {
        if ($number > 99) {
            Carp::croak("format_number doesn't support formatting numbers that are greater than 99");
        }

        if ($number < 10) {
            $number = $KANJI_NUMBERS[$number];
        } else {
            my $tens = int($number / 10);
            my $ones = $number % 10;
            if ($tens > 1) {
                $number = $KANJI_NUMBERS[$tens] . $KANJI_TEN . $KANJI_NUMBERS[$ones];
            } else {
                $number = $KANJI_TEN . $KANJI_NUMBERS[$ones];
            }
        }
    } elsif ($number_format eq FORMAT_ZENKAKU()) {
        $number =~ s/(\d)/$ZENKAKU_NUMBERS[$1]/ge;
    } elsif ($number_format eq FORMAT_KANJI()) {
        $number =~ s/(\d)/$KANJI_NUMBERS[$1]/ge;
    }

    return $number;
}

sub format_era
{
    my($dt, $number_format) = @_;

    my $era = DateTime::Calendar::Japanese::Era->lookup_by_date(
        datetime => $dt);
    if (!$era) {
        Carp::croak("No era defined for specified date");
    }

    my $era_year = ($dt->year - $era->start->year) + 1; 
    my $era_name = DateTime::Format::Japanese::Era::lookup_name_by_id($era->id);

    return $era_name .
        format_number($era_year, $number_format) .
        $YEAR_MARKER;
}

sub format_common_with_marker
{
    my($marker, $number, $number_format) = @_;
    return format_number($number, $number_format) . $marker;
}

1;
