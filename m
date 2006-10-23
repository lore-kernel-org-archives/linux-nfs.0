From: Mike Frysinger <vapier@gentoo.org>
Subject: getkversion fails with newer linux headers
Date: Mon, 23 Oct 2006 18:26:04 -0400
Message-ID: <200610231826.05026.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1729839511=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gc8Ec-0002q6-Dh
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 15:25:37 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gc8Ec-0002lH-6J
	for nfs@lists.sourceforge.net; Mon, 23 Oct 2006 15:25:31 -0700
Received: from home.wh0rd.org (localhost [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.gentoo.org (Postfix) with ESMTP id 5C29A6450E
	for <nfs@lists.sourceforge.net>; Mon, 23 Oct 2006 22:25:27 +0000 (UTC)
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

--===============1729839511==
Content-Type: multipart/signed; boundary="nextPart2174435.WPQtChM85j";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2174435.WPQtChM85j
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

with the latest linux kernel, version.h no longer defines UTS_RELEASE nor d=
oes=20
it install a generated utsrelease.h ... that means the simple getkversion=20
util fails to build ...
=2Dmike

--nextPart2174435.WPQtChM85j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iQIVAwUART1BfEFjO5/oN/WBAQLFTBAAoVTtdiq8/1YnqFj15X0+yWPcTnoxl6Qr
WNvRJdxJPt1u7IXprRnyLyaEp49dR7iR7eKKg56sZaiePn5Cjsb9Vvx/phhSZLX8
rQzOktgKgP16xSSFTi+h7FWLqaplua7Enpg7TiisqoYCShDdzzBbk30QtvCAVpn9
BZzB61u9++bzr7TlE5iXQxb4S+ALVnE3F2L2HqDvSX/X/8UYPj82yfAENz2DirwE
RNIR2bVGBZsaJYJMemLCBs1XagyEXq+PVNbH0ZtYbgnDkxssdmVi2hwAjPh1lc0P
s3L9J8M6H3qBe54I4pKNApQrj02FJoVl+zL+RyOqD1wQ9cY1VExo5owQUoBl/Nsu
RNxIZlZYhqa7bLjje/9YH5NULswVdaXcJl1qpQopq6EqGCFHRv+QRLk1iUMngBCt
nfyS1KvUecL4wH44jE5gBQSNgB2Kzz8dVMfxXvVIQF/I0ExLbrATGFdsL7kn4B32
pbqFhMYtFnBaMdkXWmQvI+Ruo3dNsRjyy5p6ki4tN2pgo2xRGth1WoW5VbbZQ9+3
InPtzoPERITAF6Qv+BsrXCOmvIJotEa6VXMxYy1Nv1WgA36zVBypE5oiDs0cjMZr
+/Wt/65xTTCU7/gA2h+o/teCUJuZMM4zv1fGcPIvrh/5bM49iTSVdzkfnFjDIupl
GBtMShb7FCk=
=o5zs
-----END PGP SIGNATURE-----

--nextPart2174435.WPQtChM85j--


--===============1729839511==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1729839511==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1729839511==--
