From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Chuck's iostat patch
Date: Mon, 8 Mar 2004 10:03:33 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07BB5@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0PEi-0003WA-C3
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 10:12:20 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0OjA-0008Et-O8
	for nfs@lists.sourceforge.net; Mon, 08 Mar 2004 09:39:44 -0800
To: "Olaf Kirch" <okir@suse.de>
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

hi olaf-

> I took Chuck's iostat patch and played with it a little. Attached
> you can find the results of this playing around.
>=20
> This patch changes Chuck's work in two ways - one, all iostat sampling
> happens in the RPC layer now, rather than having to add=20
> "nfs_count_call"
> to every NFS function. This changes some things, e.g. the way in/out
> bytes are counted. Chuck's patch counts the payload bytes of=20
> a read/write
> request only, while my approach includes the RPC overhead.
>=20
> Second, I ported it to 2.6, and made it use a seqfile for reading the
> proc file.

trond has already ported my 2.4 patch up to 2.6.  i'm still
waiting to see his work, as he has defined the metrics API
the way he likes it, and i'd like to build on that.

it sounds like you may have an old version of that patch
anyway, i've already made similar changes to the 2.4
version of this patch.

> There is still the open question whether the proc file interface to
> retrieving and zapping the iostat counters is appropriate. It's
> probably not too hard to extend this stuff to have a timer printk
> the iostat values every second or so - the question is do we really
> want this, or isn't the procfs approach sufficient?

we are planning to use sysfs instead of proc.  zapping the counters
is an important feature, and that is planned for inclusion.

i don't like the "timer printk" approach.  think of multiple
performance sampling tools running at the same time:  iostat,
and say, sar.  these need to have the absolute counters available
to them, and they can compute the averages based on time-period
samples.  that's all done in user space.

did i misunderstand you?


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
