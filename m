From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Linux client network performance
Date: Wed, 25 Jun 2003 10:39:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127E5A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>, "Matthias Kittner" <kittner@vrcom.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VEG4-0002rM-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 10:40:36 -0700
To: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
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

hi valery-

> what's the "IP fragmentation bug" ?

the Linux IP layer sends packet fragments on the wire
as it fragments each datagram.  it can run out of socket
buffer space in the middle of fragmenting a datagram.
the bug is that if it runs out of buffer space, it
stops fragmenting and drops the packet.  =20

this leaves the receiving end with a bunch of fragments
it can't assemble into a whole datagram.  this becomes
a problem when the sending end is perpetually running
out of socket space.  this fills the receiving end's
reassembly queue with fragments that can't be used,
preventing all UDP traffic from getting to the server.

the fix is to have it continue fragmenting this datagram
even though the socket buffer is "full."

> what are the symptoms of this bug ?

you're using NFS/UDP with largish r/wsize.  your
network features links of different speed (100Mb
mixed with GbE) between client and server, or is
routed rather than only switched.

you see lots of IP fragments on your network from
one or two NFS clients.  you have periods of very slow
server and network performance, followed by periods of
normal performance. =20

> > -----Original Message-----
> > From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> > Sent: Wednesday, June 25, 2003 4:30 PM
> > To: Matthias Kittner
> > Cc: nfs@lists.sourceforge.net
> > Subject: RE: [NFS] Linux client network performance
> >=20
> >=20
> > hi matthias-
> >=20
> > it sounds like you've hit the IP fragmentation bug.
> > you should use NFS/TCP (the "tcp" mount option).
> >=20
> > probably it's your 2.4.19-based client that is
> > causing this problem.
> >=20
> > > -----Original Message-----
> > > From: Matthias Kittner [mailto:kittner@vrcom.de]
> > > Sent: Wednesday, June 25, 2003 4:57 AM
> > > To: nfs@lists.sourceforge.net
> > > Subject: [NFS] Linux client network performance
> > >=20
> > >=20
> > > [I am not a subscriber, please CC to my eMail!]
> > >=20
> > > Hello,
> > >=20
> > > we have the following problem:
> > >=20
> > > - 2 linux clients:
> > > 	2.4.19-16mdk
> > > 	2.4.20
> > > - Solaris NFS-Server (nfs.server 1.21)
> > > 	SunOS 5.7
> > >=20
> > > If we compile on one of the linux machines sometimes in=20
> > this compile=20
> > > process the whole network hangs resp. is so slow that one=20
> can wait=20
> > > between 10s or 2min to finish a "ls".
> > >=20
> > > "snoop" at the nfs-server machine show very/very much "UDP=20
> > > continuation"=20
> > > traffic between the linux client and the solaris server.=20
> > Killing the=20
> > > compile process stops this messages.
> > >=20
> > > Can anyone help us? Is this a configuration problem or a bug?
> > >=20
> > > Regards,
> > > Matthias
> > >=20
> > >=20
> > >=20
> > > -------------------------------------------------------
> > > This SF.Net email is sponsored by: INetU
> > > Attention Web Developers & Consultants: Become An INetU=20
> > > Hosting Partner.
> > > Refer Dedicated Servers. We Manage Them. You Get 10% Monthly=20
> > > Commission!
> > > INetU Dedicated Managed Hosting=20
> http://www.inetu.net/partner/index.php
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU=20
> Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly=20
> Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
