From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: rsize, wsize > 32Kb : how?
Date: Thu, 09 Dec 2004 15:52:23 -0800
Message-ID: <1102636343.3784.27.camel@tesuji.nac.uci.edu>
References: <BAY21-F16DEBCC035FC2844261BF6E4B70@phx.gbl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UKJ8JEMc6D97D1aDPudw"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcY5Q-0003ES-4c
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 15:52:40 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CcY5O-00025c-Ux
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 15:52:39 -0800
To: Jocky Wilson <jocky_wilson@hotmail.com>
In-Reply-To: <BAY21-F16DEBCC035FC2844261BF6E4B70@phx.gbl>
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


--=-UKJ8JEMc6D97D1aDPudw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Is it safe to assume you've enabled jumbo frames?

Without jumbo frames, a huge packet size isn't necessarily going to make
things faster...

On Thu, 2004-12-09 at 23:48 +0000, Jocky Wilson wrote:
> Hi,
>=20
> I compiled NFS utils 1.0.6 for my Asus WL-HDD NAS device and I compiled t=
he=20
> 2.4.27 kernel with support for up to 64Kb values (const.h: NFSSVC_MAXBLKS=
IZE=20
> 65536). It all works pretty good, but unfortunately if I try mounting wit=
h=20
> rsize/wsize >32Kb the mount is always rsize=3Dwsize=3D32Kb. I'm quite kee=
n to=20
> mount with larger wsize/rsize values as I expect better performance. How =
can=20
> I accomplish larger rsize/wsize values?
>=20
> Cheers,
> JockyW
>=20
> PS: for mounting I use mount from busybox 1.0.0
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.=20
> http://productguide.itmanagersjournal.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20

--=-UKJ8JEMc6D97D1aDPudw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBBuOU3o0feVm00f/8RAuMlAJ9w1FUj+0uvGBSf492K3JIBG1BJYQCeLajO
clG9droJmaGlC3Ah/KrKbp8=
=nZ/p
-----END PGP SIGNATURE-----

--=-UKJ8JEMc6D97D1aDPudw--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
