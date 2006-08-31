From: Mike Frysinger <vapier@gentoo.org>
Subject: linking librpcsecgss against libgssapi
Date: Thu, 31 Aug 2006 19:56:16 -0400
Message-ID: <200608311956.17014.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1919444606=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GIwO7-0007ft-Rn
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 16:55:59 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GIwO7-0006zO-Ft
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 16:56:00 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 4A8AC64345
	for <nfs@lists.sourceforge.net>; Thu, 31 Aug 2006 23:55:58 +0000 (UTC)
To: nfs@lists.sourceforge.net
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

--===============1919444606==
Content-Type: multipart/signed; boundary="nextPart14837343.bRZMJvvpMa";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart14837343.bRZMJvvpMa
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

is there a reason librpcsecgss is not linked against libgssapi ?  the simpl=
e=20
fix here would be to add a line like:
LDADD =3D $(GSSAPI_LIBS)
to the librcpsecgss/src/Makefile.am file

problem being that librpcsecgss uses symbols from libgssapi but never actua=
lly=20
links against it so doing something simple like:
echo 'int main(){}' > test.c
gcc -lrpcsecgss test.c
fails miserably unless you add -lgssapi
=2Dmike

--nextPart14837343.bRZMJvvpMa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iQIVAwUARPd3IEFjO5/oN/WBAQLKvhAA3IMFH0u7j4A27hw98RPG0+3HXp/15L0T
DMlCwbUIb+E+E0WZgqKpoHrNzSFIw+Mc9pllqZo3/8Cl43zKYgx5+QvOYp0hF5K2
1Mfpf16RUzgS/lyNBcv0SAI9FvbB+VqcyTcPrF1iisDfYXHA2Jr99+XHZoCV6u6Q
YRKVS5CP3L4hXPfxyDlLQ8HK1SglsRC2Rq/OSWTAUwe0zbrIIXueL/Tf5+ck70e2
eYRiJ2dyaBwk3nxDFCT1gxpccuBTExF98h/sjt0GU6HCWGyKAnz5oNAR9PrHEt+t
Kw0Uq9pStHTCe89tkqhtnM8HGL8sdUdh8YePN5hTKn2xXtIS+KkJVsMez32ljzQv
w9Z8nTPKc97PS1HT6zVD6D2iTCkoPKnRB+QIbNGHjMAqeMmZDrb2mc85Cw2pkVmu
xda1jT/UKKSy9YZAo1iXK9lmHWt4D0+0TVoJb10c9P7Q/GkcHT3YSh+PFIH00sTQ
DQxEah+HjmqLuSOXpUsomcKXM6/LinfUCAfNLZ3dSAXrpjScPb72Y2b+XdxPj2y+
BoYv3yT4Hn0DfQ3WxXSzNjl0l8eI3QCXY04GLzwBOWiHXdau4GRsqDqhd5M3BI9r
I7eIS6c+DWAv0EbUZCl3O+xPW+B9ajJ6LmPemZuXmL8vA/ZIgX8n/3aNCoR2qCR1
5FZugXBwfDI=
=+w8o
-----END PGP SIGNATURE-----

--nextPart14837343.bRZMJvvpMa--


--===============1919444606==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1919444606==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1919444606==--
