#!perl
use strict;
use Test::More (tests => 121);
use Encode;
BEGIN
{
    use_ok("DateTime::Format::Japanese");
}

my @params = (
    [
        "ʿ������ǯ�����",
        DateTime->new(year => 2004, month => 1, day => 3)
    ],
    [
        "ʿ������ǯ�������������",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5)
    ],
    [
        "ʿ������ǯ�����������������ʬ",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5, minute => 30)
    ],
    [
        "ʿ������ǯ�����������������ʬ������",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5, minute => 30, second => 29)
    ],
    [
        "ʿ������ǯ�������壵������ʬ������",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 17, minute => 30, second => 29)
    ],
    [
        "ʿ������ǯ�������壵������ʬ������������",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 17, minute => 30, second => 29)
    ],
    [
        "ʿ����ϻǯ����",
        DateTime->new(year => 2004, month => 1, day => 3)
    ],
    [
        "ʿ����ϻǯ���������޻�",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5)
    ],
    [
        "ʿ����ϻǯ���������޻�����ʬ",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5, minute => 30)
    ],
    [
        "ʿ����ϻǯ���������޻�����ʬ�����",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5, minute => 30, second => 29)
    ],
    [
        "ʿ����ϻǯ�������޻�����ʬ�����",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 17, minute => 30, second => 29)
    ],
    [
        "ʿ��16ǯ1��3��",
        DateTime->new(year => 2004, month => 1, day => 3)
    ],
    [
        "ʿ��16ǯ1��3������5��",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5)
    ],
    [
        "ʿ��16ǯ1��3������5��30ʬ",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5, minute => 30)
    ],
    [
        "ʿ��16ǯ1��3������5��30ʬ29��",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 5, minute => 30, second => 29)
    ],
    [
        "ʿ��16ǯ1��3�����5��30ʬ29��",
        DateTime->new(year => 2004, month => 1, day => 3, hour => 17, minute => 30, second => 29)
    ],
    [
        "1989ǯ3��7��",
        DateTime->new(year => 1989, month => 3, day => 7)
    ],
    [
        "1989ǯ3��7��13��",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13)
    ],
    [
        "1989ǯ3��7��13��37ʬ",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13, minute => 37)
    ],
    [
        "1989ǯ3��7��13��37ʬ18��",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13, minute => 37, second => 18)
    ],
    [
        "���Ȭ��ǯ�����",
        DateTime->new(year => 1989, month => 3, day => 7)
    ],
    [
        "���Ȭ��ǯ������컰��",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13)
    ],
    [
        "���Ȭ��ǯ������컰��������ʬ",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13, minute => 37)
    ],
    [
        "���Ȭ��ǯ������컰��������ʬ��Ȭ��",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13, minute => 37, second => 18)
    ],
    [
        "����1989ǯ3��7��13��37ʬ18��",
        DateTime->new(year => 1989, month => 3, day => 7, hour => 13, minute => 37, second => 18)
    ],
    [
        "������1989ǯ3��7��",
        DateTime->new(year => -1989, month => 3, day => 7)
    ],
    [
        "������1989ǯ3��7��13��",
        DateTime->new(year => -1989, month => 3, day => 7, hour => 13)
    ],
    [
        "������1989ǯ3��7��13��37ʬ",
        DateTime->new(year => -1989, month => 3, day => 7, hour => 13, minute => 37)
    ],
    [
        "������1989ǯ3��7��13��37ʬ18��",
        DateTime->new(year => -1989, month => 3, day => 7, hour => 13, minute => 37, second => 18)
    ],
    [
        "����������1989ǯ3��7��13��37ʬ18��",
        DateTime->new(year => -1989, month => 3, day => 7, hour => 13, minute => 37, second => 18)
    ],
);

my $dt;
my $format = DateTime::Format::Japanese->new(input_encoding => 'euc-jp');
foreach my $param (@params) {
    $dt = eval { $format->parse_datetime($param->[0]) };
    ok($dt);
    SKIP:{
        skip("parse_datetime raised exception or didn't return a DateTime object: $@", 1) if !$dt;
        is( $dt->compare($param->[1]), 0, "Test parse_datetime($param->[0]) = " . $param->[1]->datetime);
    }
}

$format->input_encoding('shiftjis');
foreach my $param (@params) {
	$param->[0] = Encode::encode('shiftjis', Encode::decode('euc-jp', $param->[0]));
    $dt = eval { $format->parse_datetime($param->[0]) };
    ok($dt);
    SKIP:{
        skip("parse_datetime raised exception or didn't return a DateTime object: $@", 1) if !$dt;
        is( $dt->compare($param->[1]), 0, "Test parse_datetime($dt) = " . $param->[1]->datetime);
    }
}


