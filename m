From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS : open is failing too slowly...
Date: Fri, 23 Jan 2004 06:58:25 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B3F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak2lc-0002Vd-94
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 06:58:40 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ak2lb-0006QU-9O
	for nfs@lists.sourceforge.net; Fri, 23 Jan 2004 06:58:39 -0800
To: "Perceval Anichini" <perceval.anichini@laposte.net>
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

> 	I have an application which job is to record an ip stream on a
> NFS server. If the write () fails, the application continue to record
> on a local disk.
>=20
> 	When the application is recording to the local disk, it stills
> have to check wether or not the main filesystem is back. To perform
> that operation, I try to open () a file on the main filesystem
> regularly.
>=20
>   My problem is that open () is taking far too much time to fail
> (~0.3s) which lead the application to loose datas.
>=20
> So my question is : Is their a fast way to know (ioctl, or=20
> whatever) if
> a nfs server is available or in timeout mode ?

in general there is no way for a client to indicate to an application
that it is no longer in touch with a server.

> For infos : I am running redhat 9.0 with a kernel 2.6.1 compiled
> 	   "by hand"
> 	The filesystem is mounted with options nfsvers=3D3 soft=20
> timeo=3D1 retrans=3D1
>=20
> 	(Soft mode because I don't want my process to hang when the
> server is stuck, and timeo,retrans =3D 1 in order to reduce the =
timeout
> as much as possible. Tell me if i'm wrong...)

if you are using UDP, then you don't need the timeo=3D option at all.
the read and write retransmit timeout is set by the RPC client, and
usually is much faster than a tenth of a second.

if you are using TCP, then timeo=3D1 is also not advisable.  this will
cause the RPC and TCP layers to generate competing retransmissions,
which wastes resources.

retrans=3D1 with soft is an open invitation for silent data corruption.
i highly encourage you not to do this.

you really don't want soft either.  rather, using "hard" instead will
guarantee that the client will continue to retry your writes until the
server is back up.  no data will be lost unless the client crashes.
if you write() but don't flush() the file, your application should not
hang during a normal write() until the client has filled its memory.

if your file server is so unreliable that this is even an issue, then
you have a problem with your server, and not in your application.  if
you are concerned about the application becoming unresponsive, then
you should consider using threads or nonblocking I/O.


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
