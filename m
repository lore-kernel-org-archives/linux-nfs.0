From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Re: Random UDP port assignment for rpc.statd
Date: Mon, 28 Feb 2005 15:53:23 -0800
Message-ID: <1109634803.31821.67.camel@seki.nac.uci.edu>
References: <20050220111312.GA3974@s>  <cvu2u9$k7a$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-2DuhVveE3W8vZDkmzu7W"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D5uhb-0005LM-W7
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 15:53:27 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D5uha-0006gU-Ht
	for nfs@lists.sourceforge.net; Mon, 28 Feb 2005 15:53:27 -0800
To: Sven =?ISO-8859-1?Q?K=F6hler?= <skoehler@upb.de>
In-Reply-To: <cvu2u9$k7a$1@sea.gmane.org>
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


--=-2DuhVveE3W8vZDkmzu7W
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable


Do linux' NFS daemons use a dynamically linked (libc?) library function
or functions to get their port numbers mapped to something more or less
random?

If so, it might be possible (and interesting) to create an
LD_PRELOAD'able teensy .so that would replace this/these function(s)
with something that knows how to hardcode a port from a table under /etc
or something, and falls back on the traditional method of port
allocation otherwise.

On Mon, 2005-02-28 at 04:32 +0100, Sven K=F6hler wrote:
> > Why isn't it possible to specify all of statd's listening ports
> > using the -p flag?  It works for the TCP port and one of the
> > UDP ports, but there is always one more listening UDP port that
> > is randomly assigned.  I googled around for information on this
> > problem, and came up with this Debian bug report:
> >=20
> >   http://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1198=
5.html
> >=20
> > The thread ends with "I think we may have a real bug", but this
> > was reported in 1.0.6, and the problem still persists in 1.0.7,
> > so I was wondering if this isn't a bug after all.
> >=20
> > Btw, there's also a similar problem with nfsd:  In addition to
> > the standard listening port at 2049, it always opens a random
> > port in the high port range (32000-32768 or something like that).
> >=20
> > In case it matters:  I'm using Linux 2.6.10 and Slackware 10.1.
>=20
> All that matters is "rpcinfo -p". As you can see, i managed to get=20
> everything on a specifig port:
>=20
> # rpcinfo -p
>     Program Vers Proto   Port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100024    1   udp  30002  status
>      100024    1   tcp  30002  status
>      100003    2   udp   2049  nfs
>      100003    3   udp   2049  nfs
>      100021    1   udp  30004  nlockmgr
>      100021    3   udp  30004  nlockmgr
>      100021    4   udp  30004  nlockmgr
>      100005    1   udp  30001  mountd
>      100005    1   tcp  30001  mountd
>      100005    2   udp  30001  mountd
>      100005    2   tcp  30001  mountd
>      100005    3   udp  30001  mountd
>      100005    3   tcp  30001  mountd
>=20
> You can ok any other port in your firewall.
>=20
> You may want to have those two lines in your /etc/sysctl.conf:
>    fs.nfs.nlm_udpport=3D30004
>    fs.nfs.nlm_tcpport=3D30004
>=20
> I still have problems with rquotad though. It doesn't to be possible to=20
> set that on a static port.
>=20
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-2DuhVveE3W8vZDkmzu7W
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCI67zo0feVm00f/8RAlxsAJ4m6ddJ/4cVdLiLVc+EXAL9xkKcggCdEeBk
PihIhAalNaMft4zRPYVRXsA=
=ualL
-----END PGP SIGNATURE-----

--=-2DuhVveE3W8vZDkmzu7W--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
