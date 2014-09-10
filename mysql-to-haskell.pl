# Convert MySQL to Haskell structures

$db = "SIGPLAN-2014-09-04T17-20-27.mysql";
#$db = "X.mysql";
$field_re = '(\'(\\\\.|[^\'\\\\]+)*\'|null)';

# '

#print "$field_re\n"; exit(0);

open(F,$db);

sub process {
    my $entry = $_[0];
    my @res = ();
    while($entry =~ /^($field_re),?/) {
#	print "field = $1\n";
	my $field = $1;
	$entry = $'; # '
        # now decode the single field
        if ($field =~ /^\'(.*)\'/) {
	    $field = "\"$1\"";
        } elsif ($field =~ /^\-?\d+(.\d+)+$/) {
	    # okay, leave it alone
        } elsif ($field =~ /^null$/) {
	    $field = "\"null\"";
	} else {
	    die "Opps ($field)\n";
	}
        push(@res,"$field");
    }
    die "process: $entry\n" if ($entry ne "");

    return ("(" . join (",",@res) .")");
}



sub insert {
    my $table = $_[0];
    my $entries = $_[1];
#    print "($table)\n";
#    print "$entries\n\n";;
    $_ = $entries;
    while (/^,?\(($field_re(,$field_re)*)\)/) {
#	print "## $` $& [$1]\n";
	$entry = process($1);
	if (defined $tables{$table}) {
	    $tables{$table} .= "\n$entry";
	} else {
	    $tables{$table} = "$entry";
	}
	$_ = $'; # '
    }
    die "die insert: $_\n" if ($_ ne "");
}

foreach (<F>) {
    if (/^INSERT INTO `(\S+)` VALUES (.*);$/) { 
    next if (/watchdog/ || /cache/); # has funny unicode chars
#	next if ($1 ne "dr_node_revisions");
#	print "insert $1 $2\n";
	insert($1,$2);
#	exit (0);
    }
}
print "module X where\n";

foreach(keys %tables) {
#    print "(($_))\n";
    my $ch = '[';
    print "$_ =\n";
    foreach(reverse(split(/\n/,$tables{$_}))) {
	$_ =~ s/\t/\\t/g;
	print "  $ch $_\n";
	$ch = ",";
    }
    print "  ] -- end of $_\n";
    print "\n\n";
}
