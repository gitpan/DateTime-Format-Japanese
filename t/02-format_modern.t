#!perl
use strict;
use Test::More (tests => 27);
BEGIN
{
    use_ok("DateTime::Format::Japanese", ':constants');
}
use Encode;

my @params = (
    [
        DateTime->new(year => 2004, month => 1, day => 29, hour => 11, minute => 49, second => 34),
        {
            "ʿ����ϻǯ�������������Ͷ�ʬ������" =>
                [ FORMAT_KANJI, FORMAT_ERA, 0, 0, 0 ],
            "ʿ����ϻǯ����󽽶���������ͽ���ʬ��������" =>
                [ FORMAT_KANJI_WITH_UNIT, FORMAT_ERA, 0, 0, 0 ],
            "ʿ������ǯ�����������������ʬ������" =>
                [ FORMAT_ZENKAKU, FORMAT_ERA, 0, 0, 0 ],
            "ʿ��16ǯ1��29��11��49ʬ34��" =>
                [ FORMAT_ROMAN, FORMAT_ERA, 0, 0, 0 ],
            "ʿ������ǯ�����������������ʬ������������" =>
                [ FORMAT_ZENKAKU, FORMAT_ERA, 0, 0, 0, 1 ],
            "ʿ��16ǯ1��29��11��49ʬ34��" =>
                [ FORMAT_ROMAN, FORMAT_ERA, 0, 0, 0 ],
            "2004ǯ1��29��11��49ʬ34��" =>
                [ FORMAT_ROMAN, FORMAT_GREGORIAN, 0, 0, 0 ],
            "����2004ǯ1��29��11��49ʬ34��" =>
                [ FORMAT_ROMAN, FORMAT_GREGORIAN, 1, 0, 0 ],
            "����2004ǯ1��29������11��49ʬ34��" =>
                [ FORMAT_ROMAN, FORMAT_GREGORIAN, 1, 0, 1 ],
            "�����󡻡���ǯ�������������Ͷ�ʬ������" =>
                [ FORMAT_KANJI, FORMAT_GREGORIAN, 1, 0, 0 ],
            "�󡻡���ǯ����󽽶���������ͽ���ʬ��������" =>
                [ FORMAT_KANJI_WITH_UNIT, FORMAT_GREGORIAN, 0, 0, 0 ],
        }
    ],
    [
        DateTime->new(year => -2004, month => 1, day => 29, hour => 11, minute => 49, second => 34),
        {
            "-�󡻡���ǯ�������������Ͷ�ʬ������" =>
                [ FORMAT_KANJI, FORMAT_GREGORIAN, 0, 0, 0 ],
            "����-�󡻡���ǯ�������������Ͷ�ʬ������" =>
                [ FORMAT_KANJI, FORMAT_GREGORIAN, 1, 0, 0 ],
            "�����������󡻡���ǯ�������������Ͷ�ʬ������" =>
                [ FORMAT_KANJI, FORMAT_GREGORIAN, 1, 1, 0 ],
        }
    ]
            
);

my($dt, $str, $fmt);
foreach my $param (@params) {
    $fmt = DateTime::Format::Japanese->new(input_encoding => 'euc-jp', output_encoding => 'euc-jp');
    
    while (my($expected, $args) = each %{$param->[1]}) {
        $fmt->number_format($args->[0]);
        $fmt->year_format($args->[1]);
        $fmt->with_gregorian_marker($args->[2]);
        $fmt->with_bc_marker($args->[3]);
        $fmt->with_ampm_marker($args->[4]);
        $fmt->with_day_of_week($args->[5]);
        $str = eval{ $fmt->format_datetime($param->[0]) };

        is($str, $expected, "Test " . $param->[0]->datetime . " = " . $expected . ($@ ? " $@" : ''));

        $dt = $fmt->parse_datetime($str);
        is($param->[0]->compare($dt), 0, "Test parsing back result");
    }
}

