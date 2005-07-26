From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Configuration for NFSv3 only?
Date: Tue, 26 Jul 2005 11:25:03 -0400
Message-ID: <1122391503.6894.5.camel@lade.trondhjem.org>
References: <20050726035544.72927.qmail@web33915.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxRJX-0006A3-Lr
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 08:25:51 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DxRJA-0005M1-Ja
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 08:25:51 -0700
To: Bill Johnstone <beejstone3@yahoo.com>
In-Reply-To: <20050726035544.72927.qmail@web33915.mail.mud.yahoo.com>
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

m=C3=A5 den 25.07.2005 Klokka 20:55 (-0700) skreiv Bill Johnstone:
> However, now, when I run "umount", I get the message:
>=20
> Bad UMNT RPC: RPC: Program/version mismatch; low version =3D 3, high
> version =3D 3

That error can be ignored. Both client and server will continue to work
fine even if the umount RPC call fails.

The reason for the error is that the standard umount program incorrectly
always uses mount version 2 (i.e. the NFSv2 mount protocol)
since /etc/mtab doesn't record the mount version used. There is, btw, a
fix for this in the mount program carried by Redhat/Fedora.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
