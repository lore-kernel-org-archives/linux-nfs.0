From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: FC3 <-> Solaris 10, NFSv4 interop?
Date: Thu, 24 Feb 2005 17:57:09 -0800
Message-ID: <1109296629.5897.574.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-smKac6faoOMaVrSiYcAx"
Cc: strombrg@dcs.nac.uci.edu
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4UjP-0003MU-Qy
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 17:57:27 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4Uj9-0000wB-8E
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 17:57:27 -0800
To: nfs@lists.sourceforge.net
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


--=-smKac6faoOMaVrSiYcAx
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Has anyone got NFSv4 working from an FC3 NFS server to a Solaris 10 NFS
client?

foobar-root /) mount seki.nac.uci.edu:/sdb1 /mnt
nfs mount: mount: /mnt: Not owner
foobar-root /) mount -o vers=3D3 seki.nac.uci.edu:/sdb1 /mnt
foobar-root /)=20

Thanks!


--=-smKac6faoOMaVrSiYcAx
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQBCHoX1o0feVm00f/8RAkksAJ9DI36ZhKiSm0TOlWlfeGJuyKcelACdHbia
eE3XT26CPlkr7UpE7ip1dbc=
=Cf6S
-----END PGP SIGNATURE-----

--=-smKac6faoOMaVrSiYcAx--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
