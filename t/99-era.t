#!perl
use strict;
use Test::More (tests => 2);
BEGIN
{
    use_ok("DateTime::Format::Japanese::Era");
}

is(scalar(keys %DateTime::Format::Japanese::Era::ERA_NAME2ID), 237);
