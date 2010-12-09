#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;

#genome-250, genome-388
my ($rev1, $rev2) = @ARGV;
die "Whoops! Try: changelog.pl [REV1] [REV2]" if !$rev1 || !$rev2;
die "Error: rev1 and rev2 are both $rev1" if $rev1 eq $rev2;

my $git_repo = '/gscuser/jlolofie/dev/git/genome/lib/perl';
my $rev = join('..',$rev1, $rev2);
system("cd $git_repo && git fetch &> /dev/null");
my $c = qx[cd $git_repo && git log --pretty="format:JAGVILLSOVA%h	%ce	%s	%b " $rev];

my $now = localtime();

my @lines = split(/JAGVILLSOVA/,$c);
my $i;
for my $l (@lines) {

    next if $i++ == 0;
    my ($hash, $email, $subj, $body) = split(/\t/,$l);
    chomp($body);

    my $r = {
        hash  => $hash,
        email => $email,
        subj  => $subj,
        body  => $body,
    };

    my @log;
    if ($subj =~ /CHANGELOG:\s*(.*)/) {
        push @log, $1;
    }

    if ($body =~ /CHANGELOG:/) {

        if ($body =~ /CHANGELOG:(.*?)\n*^\s*$/ms) {
            push @log, $1; 
        } else {
            $body =~ /CHANGELOG:(.*)\n/ms;
            push @log, $1;
        }
    }

    if (@log > 0) {
        $r->{'log'} = \@log;
        print_log_entry($r);
    }
}

exit;


sub print_log_entry {

    my ($r) = @_;

    my $log = join('', @{$r->{'log'}});
    printf("%s\n%s (%s)\n\n", $log, $r->{'email'}, $r->{'hash'});
}

