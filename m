From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 11:56:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085511385.11596.21.camel@tesuji.nac.uci.edu>
References: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
	 <20040525123425.GO21886@suse.de>
	 <1085503328.13681.4.camel@tesla.mmt.bellhowell.com>
	 <1085507226.3872.132.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-EeOFft83nvH0OCyvUKpO"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>,
        Jeffrey Layton <jtlayton@poochiereds.net>, Olaf Kirch <okir@suse.de>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSh6O-0008Mw-I7
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 11:56:40 -0700
Received: from tesuji.nac.uci.edu ([128.200.34.35])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BSh6O-0005IV-9P
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 11:56:40 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085507226.3872.132.camel@lade.trondhjem.org>
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


--=-EeOFft83nvH0OCyvUKpO
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Tue, 2004-05-25 at 10:47, Trond Myklebust wrote:
> P=E5 ty , 25/05/2004 klokka 12:42, skreiv Jeffrey Layton:
>=20
> > Perhaps Solaris does some sort of BSD-POSIX lock translation which make=
s
> > flock() work there?
>=20
> The convention for local filesystems under Linux is that BSD and POSIX
> locks are not allowed to see each other. That rules out using the above
> trick for NFS.
>=20
> Cheers,
>    Trond

Actually, wouldn't you be OK if you had a flock that was just a wrapper
around fcntl?

>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the market... Oracle 10g.=20
> Take an Oracle 10g class now, and we'll give you the exam FREE.
> http://ads.osdn.com/?ad_id149&alloc_id=8166&op=CCk
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-EeOFft83nvH0OCyvUKpO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQBAs5bZo0feVm00f/8RAmdUAJ9yMa3/TPmk7oEpQyVOWz8M9EtbygCffy6A
s5sLvdGNgS5YX3MgiJ/6CmE=
=qxrD
-----END PGP SIGNATURE-----

--=-EeOFft83nvH0OCyvUKpO--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
