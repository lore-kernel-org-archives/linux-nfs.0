From: "Matt Heaton" <admin@0catch.com>
Subject: Re: nfs performance problem
Date: Tue, 5 Nov 2002 13:46:04 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <09b001c2850c$5eeb0ec0$e2a446a6@user1i6avc9gfx>
References: <005b01c284f5$ae1d6090$640a010a@winda> <20021105201758.I23227@vestdata.no> <007901c28505$51e9c240$640a010a@winda> <098d01c28509$0df86e20$e2a446a6@user1i6avc9gfx> <20021105153948.G3934@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mgr2.xmission.com ([198.60.22.202])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189AfO-0006U3-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 12:51:18 -0800
To: "Benjamin LaHaise" <bcrl@redhat.com>,
	<nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Cachefs will help quite a lot in my opinion because it doesn't just store
the files in RAM,
it uses the hard drive.  So if you have an NFS client with an extra 5 gig
that you can
designate as cache then reads to the NFS server will go down DRAMATICALLY as
it will hit local cache on the NFS clients drive.

I agree raid 1+0 should be much faster for writes and a little for read, but
RAID 5 still
reads from all drives simultaneously (Has to read parity in too I know), but
can read
all 7 drives at once instead of only 4 drives at once in a raid 1+0
configuration with 8 drives
in the array.  I have never used 1+0 so I am only talking about physical
drive layout rather
than any personal experience.  Are my assumptions correct that raid 5 does
in fact read
from all drives at the same time?  If so, reading might be a LITTLE faster
on raid 1+0 than
raid 5, but it shouldn't be HUGE.  When I contacted 3ware, they basically
said the same thing.
I do agree that writes are MUCH faster on 1+0 than raid 5.

Any thoughts?

L8r...

Matt


> On Tue, Nov 05, 2002 at 01:22:25PM -0700, Matt Heaton wrote:
> > each NFS server.  So even though our throughput of only 1.5 MB isn't
high.
> > The number of files per second is
> > actually quite high, and causes things to slow down because of seek time
> > issues.  PLEASE GIVE US CACHEFS SOMEONE??
>
> How is cachefs going to help?  The kernel is already trying to cache data
> as much as possible.  Once you're trying to serve more data than you have
> RAM, this are naturally going to degreate quite significantly as the
system
> becomes seek bound.
>
> > Does anyone have experience with IDE Raid arrays that get over 250 tps
in
> > iostat that work fine?  I would
> > be VERY VERY VERY interested to find out.
>
> Use raid1+0 and you'll be much happier, as read requests will be balanced
> over multiple drives (mirroring means the same data can be read from all
> of the mirrors).  Additionally, you'll have much lower CPU utilization
> and writes won't cause all disks in the array to seek for strip updates.
> Read the archives for the past couple of weeks for another example of the
> performance increase when going from raid5 to raid1+0.
>
> -ben
>
>




-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
