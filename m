From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: nfs performance problem
Date: Wed, 6 Nov 2002 00:32:37 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021106003237.L23227@vestdata.no>
References: <005b01c284f5$ae1d6090$640a010a@winda> <20021105201758.I23227@vestdata.no> <007901c28505$51e9c240$640a010a@winda>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189DBe-0008Fx-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 15:32:46 -0800
To: "poczta.dotcom.pl" <myciel@dotcom.pl>
In-Reply-To: <007901c28505$51e9c240$640a010a@winda>; from myciel@dotcom.pl on Tue, Nov 05, 2002 at 08:55:41PM +0100
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

On Tue, Nov 05, 2002 at 08:55:41PM +0100, poczta.dotcom.pl wrote:
> > How is local performance?
>=20
> local read/writes are ok
>=20
> > What filesystem do you use?
>=20
> reiserfs on top of  lvm (to be able to get snapshots)

What reiserfs-version? 3.5 or 3.6?=20
What on-disk format? 3.5 or 3.6?
There should be an entry in the kernel-log from when the filesystem is
mounted.=20


Reiserfs-3.5 has some known performance-problems related to NFS - that
may be your problem.


> > What's the output from "iostat -x -d -k 60 3"?
> >
> below is output from 'iostat -d 60 3'  (- my iostat does not take '-k'
> option,
> and '-d' gives me empty output) - mayby this is enough?

And not -x either?
iostat fr=E5 sysstat-4.0.3-2 (from RedHat) includes a "-x" option for
extended output. Most importantly, it will tell how much of the time
each device is busy.

It's unclear from your posts if this is a io-related problem or not.
Unnless you're running reiserfs-3.5 my guess is that it is the
IO-performance that is the problem. 3ware 7500 controllers have rather=20
poor performance on RAID5 - especially for writes.=20

If that's correct, then switching to a different RAID-level or replacing
the 3ware-controller should solve the problem. SCSI- or FC- RAIDS are
easily 10 or 20 times faster than the 3ware RAID for some types of
operations, and if you want something cheaper there is also different
types of IDE-RAIDs.



--=20
Ragnar Kj=F8rstad
Big Storage


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
