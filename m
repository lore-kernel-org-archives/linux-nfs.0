From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: clnt_max_conns ?
Date: Wed, 12 May 2004 13:31:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E027@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BO0O2-0006mr-MU
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 13:31:30 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BO0O2-00048x-Fa
	for nfs@lists.sourceforge.net; Wed, 12 May 2004 13:31:30 -0700
To: "Peter Astrand" <peter@cendio.se>
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

for NFSv2 and NFSv3, one socket is opened per mount point.

for NFSv4, i think trond has made some kind of sharing arrangement, =
where mounts of exports on the same server get to share a socket.

we're thinking hard about allowing multiple sockets per mount point, or =
even multiple sockets per client-server pair.  probably the break-even =
is having a socket per client CPU per client-server pair to maximize =
socket buffer availability and minimize lock contention while not =
chewing up too much of the port number space.

> -----Original Message-----
> From: Peter Astrand [mailto:peter@cendio.se]=20
> Sent: Wednesday, May 12, 2004 4:12 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] clnt_max_conns ?
>=20
>=20
>=20
> How many TCP connections are initiated by the Linux NFS=20
> client when using=20
> TCP? Solaris, for example, seems to have a parameter called=20
> "clnt_max_conns" that controls this. Is there anything=20
> similiar for Linux?=20
> Does the number of TCP connections depend on the number of mounts?
>=20
>=20
> --=20
> Peter =C5strand		Chief Developer
> Cendio			www.thinlinc.com
> Teknikringen 3		www.cendio.se
> 583 30 Link=F6ping        Phone: +46-13-21 46 00
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by Sleepycat Software
> Learn developer strategies Cisco, Motorola, Ericsson & Lucent=20
> use to deliver
> higher performing products faster, at low TCO.
> http://www.sleepycat.com/telcomwpreg.php?From=3Dosdnemail3
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
