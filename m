From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: async vs. sync
Date: Mon, 22 Nov 2004 17:09:50 -0800
Message-ID: <1101172190.24828.23.camel@soot.ess.uci.edu>
References: <482A3FA0050D21419C269D13989C61130435EBD5@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-X1oYNezx6Dx2bTwwdHib"
Cc: strombrg@dcs.nac.uci.edu,
	jehan procaccia <jehan.procaccia@int-evry.fr>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWPBw-0006OW-VQ
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 17:10:00 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWPBt-0006oh-Rr
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 17:10:00 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EBD5@lavender-fe.eng.netapp.com>
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


--=-X1oYNezx6Dx2bTwwdHib
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2004-11-22 at 13:50, Lever, Charles wrote:
> > [root@arvouin tmp]# mount cobra3:/p2v5f1 -o=20
> > async,wsize=3D32768,rsize=3D32768,soft /mnt/cobra3
>=20
> um.  you're not using NFS version 3?
>=20
> not to mention "soft" mounts are also truly the spawn of satan.

Unless your filesystem is also readonly...

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

--=-X1oYNezx6Dx2bTwwdHib
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBoo3eo0feVm00f/8RAsMZAJ9O8wXc2cFQDzerStpzNChdTvdSngCfWz7m
WnGgoyZyWPI7pN2h9cAVKO8=
=zvzW
-----END PGP SIGNATURE-----

--=-X1oYNezx6Dx2bTwwdHib--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
