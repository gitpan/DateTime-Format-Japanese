#!perl
use strict;
use Test::More (tests => 55);
BEGIN
{
    use_ok("DateTime::Format::Japanese::Traditional", ':constants');
}
use Encode;

my @params = (
    [
        DateTime::Calendar::Japanese->new(
            era_name => DateTime::Calendar::Japanese::Era::HEISEI(),
            era_year => 15,
            month    => 6,
            day      => 14,
            hour     => 3,
            hour_quarter => 2
        ),
        {
            "ʿ�����ǯϻ������̦��Ĺ�" =>
                [ FORMAT_KANJI, FORMAT_NUMERIC_MONTH, 0 ],
            "ʿ������ǯϻ�����̦��Ĺ�" =>
                [ FORMAT_KANJI_WITH_UNIT, FORMAT_NUMERIC_MONTH, 0 ],
            "ʿ������ǯ�������̦���Ĺ�" =>
                [ FORMAT_ZENKAKU, FORMAT_NUMERIC_MONTH, 0 ],
            "ʿ��15ǯ6��14��̦2�Ĺ�" =>
                [ FORMAT_ROMAN, FORMAT_NUMERIC_MONTH, 0 ],
            "ʿ�����ǯ��̵������̦��Ĺ�" =>
                [ FORMAT_KANJI, FORMAT_WAREKI_MONTH, 0 ],
            "����ʿ�����ǯ��̵������̦��Ĺ�" =>
                [ FORMAT_KANJI, FORMAT_WAREKI_MONTH, 1 ],

#            "ʿ����ϻǯ�������������Ͷ�ʬ������" =>
#                [ FORMAT_KANJI, FORMAT_ERA, 0, 0, 0 ],
#            "ʿ����ϻǯ����󽽶���������ͽ���ʬ��������" =>
#                [ FORMAT_KANJI_WITH_UNIT, FORMAT_ERA, 0, 0, 0 ],
#            "ʿ������ǯ�����������������ʬ������" =>
#                [ FORMAT_ZENKAKU, FORMAT_ERA, 0, 0, 0 ],
#            "ʿ��16ǯ1��29��11��49ʬ34��" =>
#                [ FORMAT_ROMAN, FORMAT_ERA, 0, 0, 0 ],
#            "ʿ������ǯ�����������������ʬ������������" =>
#                [ FORMAT_ZENKAKU, FORMAT_ERA, 0, 0, 0, 1 ],
#            "ʿ��16ǯ1��29��11��49ʬ34��" =>
#                [ FORMAT_ROMAN, FORMAT_ERA, 0, 0, 0 ],
#            "2004ǯ1��29��11��49ʬ34��" =>
#                [ FORMAT_ROMAN, FORMAT_GREGORIAN, 0, 0, 0 ],
#            "����2004ǯ1��29��11��49ʬ34��" =>
#                [ FORMAT_ROMAN, FORMAT_GREGORIAN, 1, 0, 0 ],
#            "����2004ǯ1��29������11��49ʬ34��" =>
#                [ FORMAT_ROMAN, FORMAT_GREGORIAN, 1, 0, 1 ],
#            "�����󡻡���ǯ�������������Ͷ�ʬ������" =>
#                [ FORMAT_KANJI, FORMAT_GREGORIAN, 1, 0, 0 ],
#            "�󡻡���ǯ����󽽶���������ͽ���ʬ��������" =>
#                [ FORMAT_KANJI_WITH_UNIT, FORMAT_GREGORIAN, 0, 0, 0 ],
        }
    ],
#    [
#        DateTime->new(year => -2004, month => 1, day => 29, hour => 11, minute => 49, second => 34),
#        {
#            "-�󡻡���ǯ�������������Ͷ�ʬ������" =>
#                [ FORMAT_KANJI, FORMAT_GREGORIAN, 0, 0, 0 ],
#            "����-�󡻡���ǯ�������������Ͷ�ʬ������" =>
#                [ FORMAT_KANJI, FORMAT_GREGORIAN, 1, 0, 0 ],
#            "�����������󡻡���ǯ�������������Ͷ�ʬ������" =>
#                [ FORMAT_KANJI, FORMAT_GREGORIAN, 1, 1, 0 ],
#        }
#    ]
            
);

my($dt, $str, $fmt);
foreach my $param (@params) {
    $fmt = DateTime::Format::Japanese::Traditional->new();
    
    while (my($expected, $args) = each %{$param->[1]}) {
        $fmt->number_format($args->[0]);
        $fmt->month_format($args->[1]);
        $fmt->with_traditional_marker($args->[2]);
        $str = $fmt->format_datetime($param->[0]);

        is(encode('euc-jp', $str), $expected, "Test $expected");

        $dt = $fmt->parse_datetime($str);

        is($param->[0]->cycle, $dt->cycle);
        is($param->[0]->cycle_year, $dt->cycle_year);
        is($param->[0]->era->id, $dt->era->id);
        is($param->[0]->era_year, $dt->era_year);
        is($param->[0]->month, $dt->month);
        is($param->[0]->day, $dt->day);
        is($param->[0]->hour, $dt->hour);
        is($param->[0]->hour_quarter, $dt->hour_quarter);
    }
}

