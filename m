From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs unlink perf !
Date: Mon, 12 Aug 2002 08:48:13 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D1DC@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eHQh-0005Yp-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 08:48:41 -0700
To: =?iso-8859-1?Q?=27Brasseur_Val=E9ry=27?=
	 <Valery.Brasseur@atosorigin.com>,
   nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

link RPCs can be very large (much larger than wsize, for instance).
if you use UDP and your network drops lots of packets, large link
requests will probably require several retransmissions to complete.

enlarge your transport socket buffer size on the client (see FAQ)
and/or try NFS over TCP.  also examine your network to see if it
is clean, and is working optimally.  if your client is attached
via a more slow link than your server, that can be the source of
bursty packet loss.

> -----Original Message-----
> From: Brasseur Val=E9ry [mailto:Valery.Brasseur@atosorigin.com]
> Sent: Monday, August 12, 2002 8:09 AM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] nfs unlink perf !
>=20
>=20
> I am testing an application which to a lot of link/unlink
>=20
> server is a NetApp filer, client is linux 2.4.19+nfs patches.
>=20
> under load it seems that the unlink call is very long when=20
> all over calls
> response time seems to be OK.
> is there any problems with the unlink code ?
>=20
> thanks
>=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
