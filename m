From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Re: Configuration for NFSv3 only?
Date: Tue, 26 Jul 2005 15:52:52 -0700 (PDT)
Message-ID: <20050726225252.48745.qmail@web33914.mail.mud.yahoo.com>
References: <1122391503.6894.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DxYIK-0000nJ-7A
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 15:53:04 -0700
Received: from web33914.mail.mud.yahoo.com ([66.163.178.78])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1DxYIJ-0001iI-3C
	for nfs@lists.sourceforge.net; Tue, 26 Jul 2005 15:53:04 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1122391503.6894.5.camel@lade.trondhjem.org>
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


--- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> m=E5 den 25.07.2005 Klokka 20:55 (-0700) skreiv Bill Johnstone:
> > However, now, when I run "umount", I get the message:
> >=20
> > Bad UMNT RPC: RPC: Program/version mismatch; low version =3D 3, high
> > version =3D 3
>=20
> That error can be ignored. Both client and server will continue to
> work
> fine even if the umount RPC call fails.
>=20
> The reason for the error is that the standard umount program
> incorrectly
> always uses mount version 2 (i.e. the NFSv2 mount protocol)
> since /etc/mtab doesn't record the mount version used. There is, btw,
> a
> fix for this in the mount program carried by Redhat/Fedora.

I will file a bug report with my distribution/vendor .  Is there any
point in filing a bug report with the maintainers of util-linux ?


	=09
____________________________________________________
Start your day with Yahoo! - make it your home page=20
http://www.yahoo.com/r/hs=20
=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
