From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: async vs. sync
Date: Tue, 23 Nov 2004 08:33:03 -0800
Message-ID: <1101227582.13960.1.camel@soot.ess.uci.edu>
References: <482A3FA0050D21419C269D13989C61130435EBD8@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-wm4jlTjJXRmFgg0FYzZB"
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWdbG-0006Wh-F9
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 08:33:06 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWdbF-0006rj-5z
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 08:33:05 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EBD8@lavender-fe.eng.netapp.com>
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


--=-wm4jlTjJXRmFgg0FYzZB
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2004-11-22 at 19:53, Lever, Charles wrote:
> > > not to mention "soft" mounts are also truly the spawn of satan.
> >=20
> > Unless your filesystem is also readonly...
>=20
> unfortunately that is a myth.  even a readonly file system can fall
> victim to the evils of soft mounts, i'm told.

Ummmm...  How?

About all that can happen, is you lose the mount.  You pretty much
-can't- toast any data.

> the cached version of the file on the client can become corrupted if the
> file is changing remotely and one or more cache-refresh reads times out.

In which case it wasn't truly read only....


--=-wm4jlTjJXRmFgg0FYzZB
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBo2Y+o0feVm00f/8RApZ7AJ4qcsUlCrywK4TykQ0n9rISujUu7QCgov90
5HLeDs6svHrL0D517TU7GBg=
=9kdT
-----END PGP SIGNATURE-----

--=-wm4jlTjJXRmFgg0FYzZB--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
