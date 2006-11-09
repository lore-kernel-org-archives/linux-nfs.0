From: Ingo Saitz <Ingo.Saitz@stud.uni-hannover.de>
Subject: Re: PROBLEM: can't mkdir() in 2.6.19-rc3
Date: Thu, 9 Nov 2006 02:35:22 +0100
Message-ID: <20061109013521.GA1330@schwan.zoo>
References: <20061101021647.GA4203@schwan.zoo>
	<20061108234515.GD16390@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2110941628=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GhypL-0002b3-RV
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 17:35:35 -0800
Received: from mx.stud.uni-hannover.de
	([130.75.176.3] helo=studserv.stud.uni-hannover.de ident=root)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GhypK-0007AF-Im
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 17:35:37 -0800
Received: from schwan (ingo@localhost [127.0.0.1])
	by studserv.stud.uni-hannover.de (8.13.8/8.13.8) with ESMTP id
	kA91ZNME027603
	for <nfs@lists.sourceforge.net>; Thu, 9 Nov 2006 02:35:24 +0100 (MET)
To: nfs@lists.sourceforge.net
In-Reply-To: <20061108234515.GD16390@fieldses.org>
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


--===============2110941628==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Content-Disposition: inline


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 08, 2006 at 06:45:15PM -0500, J. Bruce Fields wrote:
> Do you have the "async" option set on this export?  (What does
>=20
> 	exportfs -v
>=20
> say?)

Yes, i do use async as optin. exportfs -v says:

/DATA/media 10.4.0.225(rw,async,wdelay,root_squash,anonuid=3D65534,anongid=
=3D65534)

Also, your patch in <20061109004909.GA30367@fieldses.org> fixes this
problem. Thanks.

    Ingo

--=20
Man hat schon Igel nach Westen kotzen sehen!
(alte indianische Weisheit)

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFUoXZ4XrXtQkN2NURAjDJAJ0fLKBwCI5t11cM9UqVQqBiM0ArOgCdG40Q
q3zn6xv1doNw30//C7nunZo=
=ZmPX
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--


--===============2110941628==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============2110941628==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2110941628==--
