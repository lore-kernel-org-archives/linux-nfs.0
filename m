From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: nfs performance problem
Date: Wed, 6 Nov 2002 11:16:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021106111628.Q23227@vestdata.no>
References: <005b01c284f5$ae1d6090$640a010a@winda> <20021105201758.I23227@vestdata.no> <007901c28505$51e9c240$640a010a@winda> <20021106003237.L23227@vestdata.no> <003201c28572$c04ea260$640a010a@winda>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189NEn-0001XO-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 02:16:41 -0800
To: myciel <myciel@dotcom.pl>
In-Reply-To: <003201c28572$c04ea260$640a010a@winda>; from myciel@dotcom.pl on Wed, Nov 06, 2002 at 09:59:01AM +0100
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

On Wed, Nov 06, 2002 at 09:59:01AM +0100, myciel wrote:
> > > > What filesystem do you use?
> > >
> > > reiserfs on top of  lvm (to be able to get snapshots)
> >
> > What reiserfs-version? 3.5 or 3.6?
> > What on-disk format? 3.5 or 3.6?
>=20
> 3.6.25

That's the reiserfs-version.
The on-disk format must be either "3.5" or "3.6".
There should be a message at mount-time telling you wich one, or you can
use "debugreiserfs <device>" to check it.

> > Unnless you're running reiserfs-3.5 my guess is that it is the
> > IO-performance that is the problem. 3ware 7500 controllers have rathe=
r
> > poor performance on RAID5 - especially for writes.
>=20
> reiserfs 3.6.25, raid 5,
> ok, I can understand raid 5 is not fast but getting below 2Mbytes/s
> is really poor :-(

Well, updating a single byte is a very very expensive operation on
raid5. I agree that 2MB/s is worse than one should expect though, so
there may be something else going on.

The fact that you say local writes are faster could indicate that the
problem is not only io-related.=20

Maybe there is some packet-loss? That kills performance on nfs.
Is there anything in the kernel-log on the clients to indicate the
problem?

> > If that's correct, then switching to a different RAID-level or replac=
ing
> > the 3ware-controller should solve the problem. SCSI- or FC- RAIDS are
> > easily 10 or 20 times faster than the 3ware RAID for some types of
> > operations, and if you want something cheaper there is also different
> > types of IDE-RAIDs.
>=20
> what kind of IDE-RAID would You suggest?

A BigStorage IDE-RAID of course :)
I'll get back to you off-list about that.

But it's still not clear if your problems are raid-related or
network-related. Possible a combination.



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
