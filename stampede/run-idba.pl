#!/usr/bin/env perl

use strict;
use warnings;
use feature 'say';
use autodie;
use Cwd 'cwd';
use Data::Dump 'dump';
use FindBin '$Bin';
use File::Basename 'basename';
use File::Spec::Functions qw'catdir catfile';
use File::Path 'remove_tree';
use File::Find::Rule;
use Getopt::Long;
use Pod::Usage;
use Readonly;

my $DEBUG = 0;

main();

# --------------------------------------------------
sub main {
    my %args = get_args();

    if ($args{'help'} || $args{'man_page'}) {
        pod2usage({
            -exitval => 0,
            -verbose => $args{'man_page'} ? 2 : 1
        });
    }; 

    debug("args = ", dump(\%args));
    my $in_dir = $args{'dir'}      or pod2usage('No input --dir');
    my $out_dir = $args{'out_dir'} or pod2usage('No --out_dir');

    my @files;
    if (-f $in_dir) {
        debug("Directory arg '$in_dir' is actually a file");
        push @files, $in_dir;
    }
    else {
        debug("Looking for files in '$in_dir'");
        @files = File::Find::Rule->file()->in($in_dir);
    }

    printf "Found %s files\n", scalar(@files);

    if (@files < 1) {
        pod2usage('No input data');
    }

    my @inputs;
    for my $file (@files) {
        my $basename = basename($file);
        my $type     = '-r';

        if ($basename =~ /[_.-]long[_.-]/) {
            $type = '-l';
        }
        elsif ($basename =~ /([2-5])/) {
            $type = '--read_level_' . $1;
        }

        push @inputs, "$type $file";
    }   

    unless (@inputs) {
        pod2usage("Found no usable inputs");
    } 

    debug("inputs =", dump(\@inputs));

    my $idba = $args{'idba'};

    unless (-x $idba) {
        pod2usage("Missing IDBA binary ($idba)");
    }

    my @options;
    for my $opt (
        qw[mink maxk step prefix min_count min_support seed_kmer similar 
           max_mismatch min_pairs]
    ) {
        if (my $val = $args{ $opt }) {
            push @options, sprintf "--%s %s", $opt, $val;
        }
    }

    for my $flag (qw[no_coverage no_correct pre_correction]) {
        if ($args{ $flag }) {
            push @options, "--$flag";
        }
    }

    execute(join(' ',
        $idba,
        '-o', $args{'out_dir'}, 
        @options,
        @inputs
    ));


    printf("Finished, see results in '%s'\n", $args{'out_dir'});
}

# --------------------------------------------------
sub debug {
    say @_ if $DEBUG;
}

# --------------------------------------------------
sub execute {
    my @cmd = @_ or return;
    debug("\n\n>>>>>>\n\n", join(' ', @cmd), "\n\n<<<<<<\n\n");

    unless (system(@cmd) == 0) {
        die sprintf(
            "FATAL ERROR! Could not execute command:\n%s\n",
            join(' ', @cmd)
        );
    }
}

# --------------------------------------------------
sub get_args {
    my %args = (
        'debug'          => 0,
        'dir'            => '',
        'max_mismatch'   => 3,
        'maxk'           => 50,
        'min_contig'     => 200,
        'min_count'      => 2,
        'min_pairs'      => 3,
        'min_support'    => 1,
        'no_coverage'    => 0,
        'no_correct'     => 0,
        'pre_correction' => 0,
        'mink'           => 20,
        'out_dir'        => catdir(cwd(), 'idba-out'),
        'prefix'         => 3,
        'seed_kmer'      => 30,
        'similar'        => 0.95,
        'step'           => 10,
        'idba'           => catfile($Bin, 'bin', 'idba'),
    );

    GetOptions(
        \%args,
        'debug',
        'dir|d=s',
        'help',
        'idba:s',
        'man',
        'max_mismatch:i',
        'maxk:i',
        'min_contig:i',
        'min_count:i',
        'min_pairs:i',
        'min_support:i',
        'mink:i',
        'no_coverage',
        'no_correct',
        'pre_correction',
        'prefix:i',
        'seed_kmer:i',
        'similar:f',
        'step:i',
    ) or pod2usage(2);

    $DEBUG = $args{'debug'};

    if (-d $args{'out_dir'}) {
        remove_tree($args{'out_dir'});
    }

    return %args;
}

__END__

# --------------------------------------------------

=pod

=head1 NAME

run-idba.pl - runs IDBA

=head1 SYNOPSIS

  run-idba.pl -d /path/to/data

Required Arguments:

  -d|--dir   Input directory

Options (defaults in parentheses):

  --mink arg (=20)         minimum k value (<=124)
  --maxk arg (=50)         maximum k value (<=124)
  --step arg (=10)         increment of k-mer of each iteration
  --prefix arg (=3)        prefix length used to build sub k-mer table
  --min_count arg (=2)     minimum multiplicity for filtering k-mer when 
                           building the graph
  --min_support arg (=1)   minimum supoort in each iteration
  --num_threads arg (=0)   number of threads
  --seed_kmer arg (=30)    seed kmer size for alignment
  --min_contig arg (=200)  minimum size of contig
  --similar arg (=0.95)    similarity for alignment
  --max_mismatch arg (=3)  max mismatch of error correction
  --min_pairs arg (=3)     minimum number of pairs
  --no_coverage            do not iterate on coverage
  --no_correct             do not do correction
  --pre_correction         perform pre-correction before assembly

  --help                   Show brief help and exit
  --man                    Show full documentation

=head1 DESCRIPTION

Runs IDBA.

=head1 SEE ALSO

IDBA.

=head1 AUTHOR

Ken Youens-Clark E<lt>kyclark@email.arizona.eduE<gt>.

=head1 COPYRIGHT

Copyright (c) 2016 Ken Youens-Clark

This module is free software; you can redistribute it and/or
modify it under the terms of the GPL (either version 1, or at
your option, any later version) or the Artistic License 2.0.
Refer to LICENSE for the full license text and to DISCLAIMER for
additional warranty disclaimers.

=cut
