From: Mike Frysinger <vapier@gentoo.org>
Subject: [patch] see also exports(5) in nfsd(8)
Date: Sat, 10 Jun 2006 11:30:05 -0400
Message-ID: <200606101130.06312.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_+VuiEEOHkXdPTug"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fp5Ld-0004HG-Hv
	for nfs@lists.sourceforge.net; Sat, 10 Jun 2006 08:26:01 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fp5Ld-0007YW-Ax
	for nfs@lists.sourceforge.net; Sat, 10 Jun 2006 08:26:01 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 6EC1164B0A
	for <nfs@lists.sourceforge.net>; Sat, 10 Jun 2006 15:26:00 +0000 (UTC)
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

--Boundary-00=_+VuiEEOHkXdPTug
Content-Type: multipart/signed; boundary="nextPart1837312.2h1bUD9dTK";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1837312.2h1bUD9dTK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

simple patch to add exports(5) to the SEE ALSO list in the nfsd(8) man page
-mike

--nextPart1837312.2h1bUD9dTK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iQIVAwUARIrlfkFjO5/oN/WBAQIWDhAAofHIMFcKcACC9YDfLLjdaVpyqc+WWszX
68bPr7Y/UZIZrzOnRn9IIro96BZBVz4tGp9BsVQx6wZcy53gMlSYcNYJpMSBrSaL
0eJI3fBvAC4YUyLAH+5x1MQllhxizDq9PB9CbdFgGahtm3nsGtiUrIGTbdln6Y/K
OdAsu28NQhr6d34d7Y17emanXct36/q8rYeZuxvADyX7lNibAGRblMdvOmLccikh
3qcPWg3JNytTIYBHRwls/zTLoiqUySnn9B1qmcRTQQogTv2dpowympwpP4QDk4pt
yiol/fqYN3mgIctYVwuq/uRQAfhHgD4XqPpc4eZ3BTV1zXnTjFhu2cPMXlriaNRG
VGNdDLii0F7xgg0HrX/ss8F9yGOqbFWHW/0cYGs9eY3Ql0o98iQe2IlaTvgsSRCg
S5mpQ+A0xtwHm03siwTEB5zMMmJDMkFpg81zXpHZoTnCL/1LT9LASlUSJNw34rKG
NI4ruWvQMFrBZzX2ocTJl3TGoYpsEF1uZomSL3FQ5uT+WkhzOQI1Xui/1K1YBSCr
ge6OMO4KunGdIBeqk7rEuXzUAhEwtf0VGBftqm4EL38D0hSZAewZ6664Uywxf8pV
kNWlrjBT1OWs4UqH0hjvz0WOJSSiq1xffdXeLeanjJu2fjliQqB+9JXRmH30hgec
bW48B7Wfnvo=
=0YAC
-----END PGP SIGNATURE-----

--nextPart1837312.2h1bUD9dTK--

--Boundary-00=_+VuiEEOHkXdPTug
Content-Type: text/x-diff; charset="us-ascii";
	name="nfsd-man-see-also-exports.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="nfsd-man-see-also-exports.patch"

--- utils/nfsd/nfsd.man
+++ utils/nfsd/nfsd.man
@@ -38,6 +38,7 @@ the
 program.
 .SH SEE ALSO
 .BR rpc.mountd (8),
+.BR exports (5),
 .BR exportfs (8),
 .BR rpc.rquotad (8),
 .BR nfsstat (8).

--Boundary-00=_+VuiEEOHkXdPTug
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--Boundary-00=_+VuiEEOHkXdPTug
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_+VuiEEOHkXdPTug--
