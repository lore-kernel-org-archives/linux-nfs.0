From: Garrick Staples <garrick@usc.edu>
Subject: Re: 2.6.6 lockupy
Date: Wed, 26 May 2004 14:44:36 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040526214435.GK6931@polop.usc.edu>
References: <20040526211115.GI6931@polop.usc.edu> <20040526213732.GG2827@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGtad4bun3m+J/4B"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BT6CS-0004i8-Qm
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:44:36 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BT6CS-0008VL-Fp
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:44:36 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i4QLiaGf016935
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 14:44:36 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i4QLiaW2016933
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 14:44:36 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040526213732.GG2827@fieldses.org>
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


--ZGtad4bun3m+J/4B
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 26, 2004 at 05:37:32PM -0400, J. Bruce Fields alleged:
> On Wed, May 26, 2004 at 02:11:16PM -0700, Garrick Staples wrote:
> > I tried Trond's 2.6.6 patches at his website, but those brokes things
> > considerably.  Since I don't have any actual Oops messages, anyone have=
 any
> > experimental deadlock-fixing patches they want me to test? :)
>=20
> Note that Trond's patches are client-side only, so shouldn't affect your
> servers one way or another (unless I'm misunderstanding what your
> setup).--b.

You didn't misunderstand... but I was at a complete loss with production
machines suddenly dropping like flies.  I'm now at the stage where I just t=
ry
random things =3DP


--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--ZGtad4bun3m+J/4B
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAtQ/D0SBUxJbm9HMRAkHMAJ92V1fhB8a7+38yyc6YTY4IN5kLfACdG7Ta
q6TfDK+vffBYP7v6fHlAWFE=
=9LHy
-----END PGP SIGNATURE-----

--ZGtad4bun3m+J/4B--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
