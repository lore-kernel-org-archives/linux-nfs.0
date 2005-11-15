From: Neil Brown <neilb@suse.de>
Subject: Re: Odd errors and bad performance -- NFS/MD/centOS 4
Date: Wed, 16 Nov 2005 10:24:00 +1100
Message-ID: <17274.28176.342907.560389@cse.unsw.edu.au>
References: <Pine.LNX.4.62.0511151326270.806@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcA9r-00084l-T5
	for nfs@lists.sourceforge.net; Tue, 15 Nov 2005 15:24:11 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcA9q-0002tQ-8b
	for nfs@lists.sourceforge.net; Tue, 15 Nov 2005 15:24:11 -0800
To: Joshua Baker-LePain <jlb17@duke.edu>
In-Reply-To: message from Joshua Baker-LePain on Tuesday November 15
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tuesday November 15, jlb17@duke.edu wrote:
> I recently upgraded 2 of my older, 2TB file servers from RH7.3(!!) to 
> centos-4.  The servers each have 2 3ware 7500-8 boards and 16 drives.  In 
> 7.3, I ran the 3wares in hardware RAID5 mode (with a hot spare), and a 
> software RAID0 across the 2 arrays.  I used XFS, and saw local write 
> speeds of 150MB/s and reads of 300MB/s.
> 
> Given RH's absurd attitude toward XFS, I decided it was time to bite the 
> bullet and transition to ext3.  So I took a snapshot backup, reinstalled, 
> and tried to run in the same setup.  Performance with ext3 was a joke. 
> Despite days of tweaking (all detailed on nahant-list), ext3 topped out at 
> about 34 MB/s writing.

Sounds like the 3WARE driver is busted in recent kernels...

> 
> So I replicated my setup in software RAID -- 2 RAID5s and a RAID0 of those 
> (I stayed away from 1 big RAID5 so as not to lose any redundancy compared 
> to the original setup, and RAID6 in centos 4 seems to have a bad resync 
> bug).  Local performance was just fine -- 120MB/s writes and 180MB/s reads 
> (as measured by bonnie++ -- tiobench gave good numbers as well).  Yay, say 
> I, now I can finally start restoring the data.
> 
> However, the NFS performance of these beasts is bad with the added fun of 
> odd quirks.  Directory listings of even small directories can hang for 
> long (10+ min) periods of times on one client while instantaneously 
> returning on another.  At random times, users report that they get "No 
> such file or directory" when trying to 'ls' dirs they know are there, or 
> get "Stale NFS file handle" when 'cd'ing into said directories.  These 
> tend to be accompanied by the following in the client logs:

What kernel version, and in particular, what is the timestamp in
'uname -a'.  There was a bug that was fixed around April (?) which
affected NFS service of EXT3 filesystems with hash-directories
enabled.  This particularly hit redhat as they turn on
hash-directories, and so probably affects CentOS too.  You can try
using tune2fs to turn off hash-directories and see what happens.
That could explain the 'No such file or directory' and 'Stale' errors,
but I don't think it explains the slow directory listing.

> 
> In terms of performance, a remote bonnie++ run via a gigabit connected 
> client gives these numbers:
> 
> Version  1.03       ------Sequential Output------ --Sequential Input-  --Random-
>                      -Per Chr- --Block-- -Rewrite- -Per Chr- --Block--  --Seeks--
> Machine        Size K/sec %CP K/sec %CP K/sec %CP K/sec %CP K/sec %CP   /sec %CP
> $HOST            4G           11392   2  8153   4           50265  13  250.2   0
>                      ------Sequential Create------ --------Random  Create--------
>                      -Create-- --Read--- -Delete-- -Create-- --Read---  -Delete--
>                files  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP   /sec %CP
>                   16    71   0  7031  10    76   0    70   0  8070   9     75   0
> harry.egr.duke.edu,4G,,,11392,2,8153,4,,,50265,13,250.2,0,16,71,0,7031,10,76,0,70,0,8070,9,75,0
> 
> The write speed and the creation and deletion speeds seem awfully slow to 
> me.  In addition, the load on the server goes *very* high despite little 
> actual CPU usage (see <http://www.duke.edu/~jlb17/md.html> for ganglia 
> generated graphs during the bonnie run).  I've tried pinning the IRQs for 
> the network interfaces and 3wares to separate CPUs, but that had little to 
> no effect on performance.

Writing to NFS usually is slow as the server has to commit everything
to disk before returning.  You can try 'data=journal' as a mount
option.  It sometimes makes NFS writes faster, but it might make local
writes slower.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
