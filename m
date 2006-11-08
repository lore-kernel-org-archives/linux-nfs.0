From: Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Subject: Re: PROBLEM: can't mkdir() in 2.6.19-rc3 / 2.6.19-rc5
Date: Thu, 9 Nov 2006 00:00:41 +0100
Message-ID: <20061108230041.GA31610@schwan.zoo>
References: <20061101021647.GA4203@schwan.zoo>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2047937308=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhwPk-0005Kw-Jz
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 15:01:01 -0800
Received: from mx.stud.uni-hannover.de
	([130.75.176.3] helo=studserv.stud.uni-hannover.de ident=root)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhwPi-0008Kg-9H
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 15:01:01 -0800
Received: from schwan (ingo@localhost [127.0.0.1])
	by studserv.stud.uni-hannover.de (8.13.8/8.13.8) with ESMTP id
	kA8N0i4H024424
	for <nfs@lists.sourceforge.net>; Thu, 9 Nov 2006 00:00:44 +0100 (MET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061101021647.GA4203@schwan.zoo>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--===============2047937308==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Content-Disposition: inline


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 01, 2006 at 03:16:47AM +0100, Ingo Saitz wrote:
> [1.] One line summary of the problem:   =20
>=20
> Can't call mkdir() on 2.6.19-r3 nfsd

This is still present in 2.6.19-rc5 (-rc4 was completely broken, see
<20061101024519.GA4426@schwan.zoo>), same host.

    Ingo

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD4DBQFFUmGZ4XrXtQkN2NURArk5AJiec/O7bc4+TGq10TN8j9ag7x/9AKC8ZyC2
0iXvCbJK1T5lU2TWUEfmKQ==
=IAC2
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--


--===============2047937308==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============2047937308==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2047937308==--
