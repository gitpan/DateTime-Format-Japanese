#!perl
use strict;
use Test::More (tests => 57);
BEGIN
{
    use_ok("DateTime::Format::Japanese::Traditional");
}

my @params = (
    [
        "Ê¿À®½½Ï»Ç¯ËÓ·î»°Æü",
        [ 78, 20, 1, 3, 1, 1 ],
    ],
    [
        "Ê¿À®½½Ï»Ç¯ËÓ·î»°Æü»Ò¤Î¹ï",
        [ 78, 20, 1, 3, 10, 1 ],
    ],
    [
        "Ê¿À®½½Ï»Ç¯ËÓ·î»°Æü»Ò»°¤Ä¹ï",
        [ 78, 20, 1, 3, 10, 3 ],
    ],
    [
        "Ê¿À®16Ç¯1·î3Æü±¬¤Î¹ï",
        [ 78, 20, 1, 3, 1, 1 ],
    ],
    [
        "Ê¿À®16Ç¯1·î3Æü±¬3¤Ä¹ï",
        [ 78, 20, 1, 3, 1, 3 ],
    ],
    [
        "µìÎñÊ¿À®16Ç¯1·î3Æü±¬3¤Ä¹ï",
        [ 78, 20, 1, 3, 1, 3 ],
    ],
    [
        "µìÎñÊ¿À®£±£¶Ç¯£±·î£³Æü±¬¤Î¹ï",
        [ 78, 20, 1, 3, 1, 1 ],
    ],
    [
        "µìÎñÊ¿À®£±£¶Ç¯ËÓ·î£³Æü»Ò¤Î¹ï",
        [ 78, 20, 1, 3, 10, 1 ],
    ]
);

my $dt;
foreach my $param (@params) {
    $dt = eval { DateTime::Format::Japanese::Traditional->parse_datetime($param->[0]) };
    ok($dt);

    SKIP:{
        skip("parse_datetime raised exception or didn't return a DateTime object: $@", 1) if !$dt;
        is($dt->cycle,        $param->[1]->[0], $param->[0] . " cycle");
        is($dt->cycle_year,   $param->[1]->[1], $param->[0] . " cycle_year");
        is($dt->month,        $param->[1]->[2], $param->[0] . " month");
        is($dt->day,          $param->[1]->[3], $param->[0] . " day");
        is($dt->hour,         $param->[1]->[4], $param->[0] . " hour");
        is($dt->hour_quarter, $param->[1]->[5], $param->[0] . " hour_quarter");
    }
}




