From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Linux client network performance
Date: Wed, 25 Jun 2003 12:40:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127E5C@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>, "Matthias Kittner" <kittner@vrcom.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19VG8C-0004EV-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 12:40:36 -0700
To: "s o f i a" <sofiavalera@yahoo.com>
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

hi sofia-

> Can you please let me know:
> - are there any identified workarounds?

yes, there are several.

1.  use NFS/TCP

2.  if you can't use NFS/TCP, upgrade your clients
    to 2.4.20 or later

3.  if you can't upgrade your clients, ensure the
    default socket buffer size on your clients is
    large before mounting any NFS servers (see
    below).

> - are there any papers or writeups on
> various other symptoms of this issue?

  http://www.netapp/com/tech_library/3183.html

contains instructions for deploying workarounds
in the appendix, including the socket buffer
enlargement workaround.

the symptoms that i described to valery are
what you should look for.  other behaviors
could be the result of many different problems.

> At one site, the customer environment mentioned
> about having issues with Linux clients; they
> had to change NFS block size to 8k....=20

reducing r/wsize helps, but is not a guaranteed
workaround.

> Wondering if one can comment about this one case,=20
> I noticed even with the Linux client side
> mounted at 8k, at a certain point in time,
> with a certain application that is write intensive,
> to a Solaris NFS server, the client had to do
> (2) writes, before the NFS server replied ...
> (in looking at the snoop) ... i am not sure, but
> i think the application had the capability to
> write in even less the 8k blocksize, and it seems
> like this eliminated the problem of NFS-writes
> from the linux client...=20

that's not a very clear description of the problem.
it sounds like your client is retransmitting NFS
write operations, but there isn't enough in your
description to determine why that might occur.

> > Sent: Wednesday, June 25, 2003 10:40 AM
> > To: Brasseur Val=E9ry
> > Cc: nfs@lists.sourceforge.net; Matthias Kittner
> > Subject: RE: [NFS] Linux client network performance
> >=20
> >=20
> > hi valery-
> >=20
> > > what's the "IP fragmentation bug" ?
> >=20
> > the Linux IP layer sends packet fragments on the
> wire
> > as it fragments each datagram.  it can run out of
> socket
> > buffer space in the middle of fragmenting a
> datagram.
> > the bug is that if it runs out of buffer space, it
> > stops fragmenting and drops the packet.  =20
> >=20
> > this leaves the receiving end with a bunch of
> fragments
> > it can't assemble into a whole datagram.  this
> becomes
> > a problem when the sending end is perpetually
> running
> > out of socket space.  this fills the receiving end's
> > reassembly queue with fragments that can't be used,
> > preventing all UDP traffic from getting to the
> server.
> >=20
> > the fix is to have it continue fragmenting this
> datagram
> > even though the socket buffer is "full."
> >=20
> > > what are the symptoms of this bug ?
> >=20
> > you're using NFS/UDP with largish r/wsize.  your
> > network features links of different speed (100Mb
> > mixed with GbE) between client and server, or is
> > routed rather than only switched.
> >=20
> > you see lots of IP fragments on your network from
> > one or two NFS clients.  you have periods of very
> slow
> > server and network performance, followed by periods
> of
> > normal performance. =20
> >=20
> > > > -----Original Message-----
> > > > From: Lever, Charles
> [mailto:Charles.Lever@netapp.com]
> > > > Sent: Wednesday, June 25, 2003 4:30 PM
> > > > To: Matthias Kittner
> > > > Cc: nfs@lists.sourceforge.net
> > > > Subject: RE: [NFS] Linux client network
> performance
> > > >=20
> > > >=20
> > > > hi matthias-
> > > >=20
> > > > it sounds like you've hit the IP fragmentation
> bug.
> > > > you should use NFS/TCP (the "tcp" mount option).
> > > >=20
> > > > probably it's your 2.4.19-based client that is
> > > > causing this problem.
> > > >=20
> > > > > -----Original Message-----
> > > > > From: Matthias Kittner
> [mailto:kittner@vrcom.de]
> > > > > Sent: Wednesday, June 25, 2003 4:57 AM
> > > > > To: nfs@lists.sourceforge.net
> > > > > Subject: [NFS] Linux client network
> performance
> > > > >=20
> > > > >=20
> > > > > [I am not a subscriber, please CC to my
> eMail!]
> > > > >=20
> > > > > Hello,
> > > > >=20
> > > > > we have the following problem:
> > > > >=20
> > > > > - 2 linux clients:
> > > > > 	2.4.19-16mdk
> > > > > 	2.4.20
> > > > > - Solaris NFS-Server (nfs.server 1.21)
> > > > > 	SunOS 5.7
> > > > >=20
> > > > > If we compile on one of the linux machines
> sometimes in
> > > > this compile
> > > > > process the whole network hangs resp. is so
> slow that one
> > > can wait
> > > > > between 10s or 2min to finish a "ls".
> > > > >=20
> > > > > "snoop" at the nfs-server machine show
> very/very much "UDP
> > > > > continuation"=20
> > > > > traffic between the linux client and the
> solaris server.=20
> > > > Killing the
> > > > > compile process stops this messages.
> > > > >=20
> > > > > Can anyone help us? Is this a configuration
> problem or a bug?
> > > > >=20
> > > > > Regards,
> > > > > Matthias
> > > > >=20
> > > > >=20
> > > > >=20
> > > > >
> -------------------------------------------------------
> > > > > This SF.Net email is sponsored by: INetU
> > > > > Attention Web Developers & Consultants: Become
> An INetU
> > > > > Hosting Partner.
> > > > > Refer Dedicated Servers. We Manage Them. You
> Get 10% Monthly=20
> > > > > Commission!
> > > > > INetU Dedicated Managed Hosting=20
> > > http://www.inetu.net/partner/index.php
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net=20
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > >=20
> > >=20
> > >=20
> > >
> -------------------------------------------------------
> > > This SF.Net email is sponsored by: INetU
> > > Attention Web Developers & Consultants: Become An
> INetU
> > > Hosting Partner.
> > > Refer Dedicated Servers. We Manage Them. You Get
> 10% Monthly=20
> > > Commission!
> > > INetU Dedicated Managed Hosting=20
> > http://www.inetu.net/partner/index.php
>=20
>=20
> __________________________________
> Do you Yahoo!?
> SBC Yahoo! DSL - Now only $29.95 per month!
> http://sbc.yahoo.com
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
