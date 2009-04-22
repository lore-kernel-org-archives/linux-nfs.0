From: Theodore Tso <tytso@mit.edu>
Subject: Re: Fw: 2.6.28.9: EXT3/NFS inodes corruption
Date: Wed, 22 Apr 2009 18:44:55 -0400
Message-ID: <20090422224455.GV15541@mit.edu>
References: <20090422142424.b4105f4c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	Sylvain Rochet <gradator@gradator.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <20090422142424.b4105f4c.akpm@linux-foundation.org>
Sender: linux-ext4-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 02:24:24PM -0700, Andrew Morton wrote:
> 
> Is it nfsd, or is it htree?

Well, I see evidence in the bug report of corrupted directory data
structures, so I don't think it's an NFS problem.  I would want to
rule out hardware flakiness, though.  This could easily be caused by a
hardware problem.

> The kernel log is not really nice with us, here on the NFS Server:
> 
> Mar 22 06:47:14 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Unrecognised inode hash code 52
> Mar 22 06:47:14 bazooka kernel: EXT3-fs warning (device md10): dx_probe: Corrupt dir inode 40420228, running e2fsck is recommended.

Evidence of a corrupted directory entry.  We would need to look at the
directory to see whether the directory just ad a few bits flipped, or
is pure garbage.  The ext3 htree code should do a better job printing
out diagnostics, and flagging the filesystem as corrupt here.

> Apr  2 22:19:02 bazooka kernel: EXT3-fs warning (device md10): ext3_unlink: Deleting nonexistent file (40491685), 0

More evidence of a corrupted directory.

> == Going deeper into the problem
> 
> Something like that is quite common:
> 
> root@bazooka:/data/...# ls -la
> total xxx
> drwxrwx--- 2 xx    xx        4096 2009-04-20 03:48 .
> drwxr-xr-x 7 root  root      4096 2007-01-21 13:15 ..
> -rw-r--r-- 1 root  root         0 2009-04-20 03:48 access.log
> -rw-r--r-- 1 root  root  70784145 2009-04-20 00:11 access.log.0
> -rw-r--r-- 1 root  root   6347007 2009-04-10 00:07 access.log.10.gz
> -rw-r--r-- 1 root  root   6866097 2009-04-09 00:08 access.log.11.gz
> -rw-r--r-- 1 root  root   6410119 2009-04-08 00:07 access.log.12.gz
> -rw-r--r-- 1 root  root   6488274 2009-04-07 00:08 access.log.13.gz
> ?--------- ?    ?     ?         ?                ? access.log.14.gz
> ?--------- ?    ?     ?         ?                ? access.log.15.gz
> ?--------- ?    ?     ?         ?                ? access.log.16.gz

This is on the client side; what happens when you look at the same
directory from the server side?

> 
> fsck.ext3 fixed the filesystem but didn't fix the problem.
> 

What do you mean by that?  That subsequently, you started seeing
filesystem corruptions again?  Can you send me the output of
fsck.ext3?  The sorts of filesystem corruption problems which are
fixed by e2fsck are important in figuring out what is going on.

What you if you run fsck.ext3 (aka e2fsck) twice.  Once after fixing
fixing all of the problems, and then a second time afterwards.  Do the
problems stay fixed?

Suppose you try mounting the filesystem read-only; are things stable
while it is mounted read-only.

> Let's check how inodes numbers are distributed:
> 
> # cat /root/inodesnumbers | perl -e 'use Data::Dumper; my @pof; while(<>){my ( $inode ) = ( $_ =~ /^(\d+)/ ); my $hop = int($inode/1000000); $pof[$hop]++; }; for (0 .. $#pof) { print $_." = ".($pof[$_]/10000)."%\n" }'
> [... lot of quite unused inodes groups]
> 53 = 3.0371%
> 54 = 26.679%     <= mailboxes
> 55 = 2.7026%
> [... lot of quite unused inodes groups]
> 58 = 1.3262%
> 59 = 27.3211%    <= mailing lists archives
> 60 = 5.5159%
> [... lot of quite unused inodes groups]
> 171 = 0.0631%
> 172 = 0.1063%
> 173 = 27.2895%   <=
> 174 = 44.0623%   <=
> 175 = 45.6783%   <= websites files
> 176 = 45.8247%   <=
> 177 = 36.9376%   <=
> 178 = 6.3294%
> 179 = 0.0442%

Yes, that's normal.  BTW, you can get this sort of information much
more easily simply by using the "dumpe2fs" program.

> We use to fix broken folders by moving them to a quarantine folder and 
> by restoring disappeared files from the backup.
> 
> So, let's check corrupted inodes number from the quarantine folder:
> 
> root@bazooka:/data/path/to/rep/of/quarantine/folders# find . -mindepth 1 -maxdepth 1 -printf '%i\n' | sort -n
> 174293418
> 174506030
> 174506056
> 174506073
> 174506081
> 174506733
> 174507694
> 174507708
> 174507888
> 174507985
> 174508077
> 174508083
> 176473056
> 176473062
> 176473064
> 
> Humm... those are quite near to each other 17450... 17647... and are of 
> course in the most used inodes "groups"...

When you say "corrupted inodes", how are they corrupted?  The errors
you showed on the server side looked like directory corruptions.  Were
these inodes directories or data files?


This really smells like a hardware problem to me; my recommendation
would be to run memory tests and also hard drive tests.  I'm going to
guess it's more likely the problem is with your hard drives as opposed
to memory --- that would be consistent with your observation that
trying to keep the inodes in memory seems to help.

						- Ted
