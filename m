From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS suport block sharing
Date: Wed, 18 Feb 2004 12:17:41 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020ACC04@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Olaf Kirch" <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtYDl-0005Rr-VA
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 12:23:01 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtY1X-0007oY-EX
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 12:10:23 -0800
To: <nfs@lists.sourceforge.net>
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

i've also seen this rather puzzling behavior on 2.6.
it certainly doesn't behave as we have come to expect.

"me too"

the idea of the patch makes sense, but you also need
to check for some other flags like intr/nointr, noac,
tcp/udp, and sync, for example.

> -----Original Message-----
> From: Olaf Kirch [mailto:okir@suse.de]=20
> Sent: Wednesday, February 18, 2004 11:37 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS suport block sharing
>=20
>=20
> Hi,
>=20
> yesterday, I ran into something that puzzled me quite a bit.  I had an
> NFS file system (my home directory) mounted in its normal=20
> location. For
> testing purposes, I wanted to mount it a second time, but=20
> with a different
> set of options (hard instead of soft, etc).
>=20
> To my surprise, the second mount continued to act like the original
> mount, as if it had been mounted with -o soft. /etc/mtab showed the
> options I had specified, but /proc/mounts showed that it indeed used
> soft retransmits.
>=20
> To make a long story short, I think _if_ we do NFS super block
> sharing, we should make sure we use don't reuse an existing
> sb if it has different options. Attached is a patch that implements
> this, at least for the most common set of options.
>=20
> Comments?
>=20
> Olaf
> --=20
> Olaf Kirch     |  Stop wasting entropy - start using predictable
> okir@suse.de   |  tempfile names today!
> ---------------+=20
>=20


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
