From: Erik Walthinsen <omega@pdxcolo.net>
Subject: NAS server avalanche overload
Date: Wed, 03 Mar 2004 00:31:59 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078302718.825.67.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyRsa-0002pj-Gy
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 00:37:24 -0800
Received: from mail.pdxcolo.net ([64.146.134.17] helo=palantir.pdxcolo.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AyRUi-0005m9-K2
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 00:12:44 -0800
Received: from omegacs.net ([216.99.212.251] helo=omicron.omegacs.net)
	by palantir.pdxcolo.net with asmtp (Exim 3.35 #1 (Debian))
	id 1AyRnN-0006Sf-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Mar 2004 00:32:01 -0800
To: nfs@lists.sourceforge.net
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

We have a NAS server currently running a basically stock 2.4.22 kernel,
on a single 2.4GHz Xeon HT with 512MB RAM and 4 SATA 200GB disks on a
3ware 8506-12 in RAID-5.

It serves two machines via switched gigabit (1500 mtu, no switch
support) which each run large numbers of User-mode Linux processes. 
Each kernel (there are ~60 total) has one or more open files at all
times, backing the normal ext3 filesystems for these virtual machines. 
They use copy-on-write such that the main distro files are on local
disks and only the differences against this are stored, per machine, on
the NAS.  /home filesystems and such are flat, sparse files.  No attempt
is made at this point to turn atime off (but I can patch the kernel to
change the default if necessary).

The problem we're having is that every once in a while the entire system
grinds to a screeching halt with the load average on the NAS box spiking
to 17-18 (with 16 nfsd processes, this means every last one is wedged),
which quickly causes the load on the two client machines to spike as
requests they're making get stuck.  This eventually clears up, but can
last anywhere from 15 seconds to 15+ minutes.  In the meantime, however,
any disk-based operation inside the virtual machines can take a minute
or more to complete.

I've been trying for a long time to track this down with no luck, so now
it's time to see if anyone here has any ideas.

First major datapoint: early in the debugging cycle a large-ish number
of RRD datasets were kept on the NAS box, being updated regularly in an
attempt to spot the culprit.  This instead made the problem
significantly more frequent.  Moving the archives to another machine and
off NFS entirely immediately trimmed 100-200 I/O's per second average
off the NAS box, and the problem eased greatly.

Second: the whole process can easily be replicated by running bonnie++
on any of the machines (the NAS, the client, or a virtual machine), and
it appears clearly related to the I/O's per second, but only in cases
where I/O's are not linear.  *Reading* a huge file either locally or
over NFS will cause a very mild form of the overload, but *writing* can
cause it almost instantaneously.

I've tried playing around with bdflush parameters, but without a
dramatically clearer mental picture of how that whole subsystem works, I
have no real chance of coming up with the best direction to move.  A
gradual search isn't really feasible because the spikes are
unpredictable, and artificially generated loads (writing huge files) are
*too* stressful to see any differences.

I've graphed this thing utterly to death, and anyone interested in
checking it out can see tonight's fiasco at:

http://narsil.pdxcolo.net/graphs/?start=200403022200&duration=1hr

The aforementioned switch away from NAS-based RRD archives can be seen
quite easily at:

http://narsil.pdxcolo.net/graphs/?start=20040208&duration=1week

The graph pages are designed for a full 1600x1200 screen (mine), so it
may be hard to see everything clearly on smaller screens.  Try adding
&width=100&height=50 maybe.  The most relevant link is the NAS debug
page (nasdebug.php?...), which shows more information than the main
graphs page.

What I'd like to know is if anyone has any idea what's really going on
here, or suggestions as to what other data I might gather that would
help diagnose the problem.  Easy solutions (add RAM, tweak a sysctl,
etc.) would be *greatly* appreciated ;-)
-- 
- Omega
  aka Erik Walthinsen
  omega@pdxcolo.net



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
