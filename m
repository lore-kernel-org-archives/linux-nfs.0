From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] What's slated for inclusion in 2.6.24-rc1 from the NFS client git tree...
Date: Mon, 8 Oct 2007 18:36:16 +1000
Message-ID: <20071008083616.GA30931@sgi.com>
References: <1191454876.6726.32.camel@heimdal.trondhjem.org> <20071004085206.0a8e37b5@poseidon.drzeus.cx> <1191506450.6685.17.camel@heimdal.trondhjem.org> <30494.1191605410@turing-police.cc.vt.edu> <20071005140037.1309a8d3.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Cc: Valdis.Kletnieks@vt.edu, Peter Staubach <staubach@redhat.com>,
	Andrew@sc8-sf-spam2-b.sourceforge.net, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Pierre Ossman <drzeus-list@drzeus.cx>,
	Morton <akpm@linux-foundation.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754497AbXJHI3P@vger.kernel.org>
In-Reply-To: <20071005140037.1309a8d3.jlayton@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Oct 05, 2007 at 02:00:37PM -0400, Jeff Layton wrote:
> On Fri, 05 Oct 2007 13:30:10 -0400
> Valdis.Kletnieks@vt.edu wrote:
> >
> > How does Joe Sysadmin tell if he has an affected legacy app or not?
> > 
> > (The obvious "try it and see what breaks" is a non-starter for many places,
> > because you too easily end up in a loop of "enable it, find 4-5 show stoppers,
> > turn it off, fix them, lather rinse repease".  Been there, done that, got
> > the tshirt - a project I got dragged into involves a large storage array that
> > appears to insist on exporting 64-bit stuff, and a large farm of clients that
> > are very 64-bit unclean....)
> > 
> 
> In addition to Trond's suggestion, you might be able to use "nm" or
> something like it and see if there are references to non-LFS (f)stat
> calls in your binaries. For instance, if you see references to stat()
> (and not stat64()), then the app is probably not built with 64-bit file
> offsets.

Attached is a Perl script I wrote a while back to scan directories
looking for old stat calls in binaries.  Here's the output from
my laptop:

# ./summarise-stat64.pl /usr/bin
    775 26.8% are scripts (shell, perl, whatever)
   1404 48.5% don't use any stat() family calls at all
    428 14.8% use 32-bit stat() family interfaces only
    278  9.6% use 64-bit stat64() family interfaces only
     11  0.4% use both 32-bit and 64-bit stat() family interfaces

# ./summarise-stat64.pl /usr/sbin
    164 35.7% are scripts (shell, perl, whatever)
    170 37.0% don't use any stat() family calls at all
     78 17.0% use 32-bit stat() family interfaces only
     46 10.0% use 64-bit stat64() family interfaces only
      1  0.2% use both 32-bit and 64-bit stat() family interfaces

# ./summarise-stat64.pl -v /usr/bin
...
/usr/bin/vi use 32-bit stat() family interfaces only
/usr/bin/view use 32-bit stat() family interfaces only
/usr/bin/vim use 32-bit stat() family interfaces only
...
/usr/bin/Mail use 32-bit stat() family interfaces only
/usr/bin/mail use 32-bit stat() family interfaces only
/usr/bin/mailx use 32-bit stat() family interfaces only
...
/usr/bin/gdb use 32-bit stat() family interfaces only
/usr/bin/gdbtui use 32-bit stat() family interfaces only
/usr/bin/rpcgen use 32-bit stat() family interfaces only
...
/usr/bin/cc use 32-bit stat() family interfaces only
/usr/bin/gcc use 32-bit stat() family interfaces only
/usr/bin/gcov use 32-bit stat() family interfaces only
/usr/bin/unprotoize use 32-bit stat() family interfaces only
...
/usr/bin/git use 32-bit stat() family interfaces only
/usr/bin/git-check-ref-format use 32-bit stat() family interfaces only
/usr/bin/git-cat-file use 32-bit stat() family interfaces only
/usr/bin/git-checkout-index use 32-bit stat() family interfaces only
/usr/bin/git-clone-pack use 32-bit stat() family interfaces only
/usr/bin/git-commit-tree use 32-bit stat() family interfaces only
/usr/bin/git-convert-objects use 32-bit stat() family interfaces only
/usr/bin/git-daemon use 32-bit stat() family interfaces only
/usr/bin/git-describe use 32-bit stat() family interfaces only
...

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="summarise-stat64.pl"

#!/usr/bin/perl
#
# A Perl script for evaluating and summarising which executables in
# the given directories depend on the old 32-bit stat() family APIs.
#
# Usage: summariese-stat64.pl directory [...]
#
# Copyright (c) 2007 Silicon Graphics, Inc.  All Rights Reserved.
# By Greg Banks <gnb@melbourne.sgi.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

use strict;
use warnings;

my @pathnames;		# file and directories to read, from the commandline
my @results;		# array of { path, used32, used64, not_exe, no_perm } hashes
my $verbose = 0;

sub usage
{
    print STDERR "Usage: summarise-stat64 [--verbose] file_or_directory...\n";
    exit 1;
}

# Parse arguments
foreach my $a (@ARGV)
{
    if ($a eq '--verbose' || $a eq '-v')
    {
	$verbose++;
    }
    elsif ($a =~ m/^-/)
    {
	usage;
    }
    else
    {
	push(@pathnames,$a);
    }
}
usage unless scalar(@pathnames);

# Function to scan a file
sub scan_file
{
	my ($path) = @_;
	my $fh;

	my %res =
	(
		path => $path,
		used32 => 0,
		used64 => 0,
		not_exe => 0,
		no_perm => 0,
	);

	open $fh,'-|', "nm -uD \"$path\" 2>&1"
		or return;
	while (<$fh>)
	{
		chomp;

		if (m/File format not recognized/)
		{
			$res{not_exe} = 1;
		}
		elsif (m/Permission denied/)
		{
			$res{no_perm} = 1;
		}
		elsif (m/^\s+U __(|l|f)xstat$/)
		{
			$res{used32}++;
		}
		elsif (m/^\s+U __(|l|f)xstat64$/)
		{
			$res{used64}++;
		}
	}
	close $fh;
	push(@results, \%res);
}

# Function to scan a directory
sub scan_directory
{
	my ($path) = @_;
	my $dh;
	return unless opendir($dh,$path);
	while (my $d = readdir $dh)
	{
		next if ($d =~ m/^\./);
		print "$path/$d\n" if $verbose > 2;
		scan_path("$path/$d");
	}
	closedir $dh;
}

# Function to scan something that might be a file or a directory
sub scan_path
{
	my ($path) = @_;
	print "scan_path($path)\n" if $verbose > 2;
	if ( -d $path )
	{
		scan_directory($path);
	}
	elsif ( -e $path )
	{
		scan_file($path);
	}
}

# Scan files and directories specified in the commandline
foreach my $path (@pathnames)
{
	scan_path($path);
}

my @status_strings =
(
	"cannot be read (permission denied)",
	"are scripts (shell, perl, whatever)",
	"don't use any stat() family calls at all",
	"use 32-bit stat() family interfaces only",
	"use 64-bit stat64() family interfaces only",
	"use both 32-bit and 64-bit stat() family interfaces",
);

sub STATUS_UNCLEAN { return 3 };
sub STATUS_MIXED { return 5 };
sub STATUS_MAX { return 5 };
sub status
{
	my ($r) = @_;
	return 0 if ($r->{no_perm});
	return 1 if ($r->{not_exe});
	return 2 + ($r->{used64} ? 2 : 0) + ($r->{used32} ? 1 : 0);
}

# Function to generate a summary
sub emit_summary
{
	my @summ;
	my $total = 0;

	foreach my $r (@results)
	{
		my $s = status($r);
		$summ[$s] = 0 unless defined $summ[$s];
		$summ[$s]++;
		$total++;
		printf "%s %s\n", $r->{path}, $status_strings[$s]
		    if ($verbose && ($s == STATUS_UNCLEAN || $s == STATUS_MIXED));
	}

	foreach my $s (0..STATUS_MAX)
	{
		next unless defined $summ[$s];
		printf "%7d %4.1f%% %s\n",
			$summ[$s], (100.0 * $summ[$s] / $total), $status_strings[$s];
	}
}

# Function to dump raw data
sub emit_raw
{
	foreach my $r (@results)
	{
		print "$r->{used32} $r->{used64} $r->{not_exe} $r->{no_perm} $r->{path}\n";
	}
}

emit_raw if $verbose > 1;
emit_summary;

--gBBFr7Ir9EOA20Yy--
