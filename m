From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
Subject: Function `xmalloc' implicitly converted to pointer at
	mountpoint.c:25
Date: Tue, 11 Jul 2006 09:14:50 +1000
Message-ID: <20060710231450.GB11009@debianrules.debiancolombia.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0837102381=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G050W-0004hU-U8
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 16:17:44 -0700
Received: from cpe-60-224-176-117.vic.bigpond.net.au ([60.224.176.117]
	helo=elida.v7w.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1G050V-0003nB-U3
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 16:17:41 -0700
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


--===============0837102381==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="24zk1gE8NUlDmwG9"
Content-Disposition: inline


--24zk1gE8NUlDmwG9
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I have received debian bug report #377724 [0]. It is about "a
problem that will cause your package to segfault on architectures
where the size of a pointer is greater than the size of an integer,
such as ia64 and amd64". =20

The message is:

Function `xmalloc' implicitly converted to pointer at mountpoint.c:25

[0] http://bugs.debian.org/377724

Best Regards,

An=EDbal Monsalve Salazar
--=20
http://v7w.com/anibal

--24zk1gE8NUlDmwG9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD4DBQFEst9qiKF4f8PxWcoRAggaAJ0XIw7iq00mg0NS87LxOn3+a+rYxgCY2pb5
b0DfZ/zYBE1tw7OvezI0TA==
=WBRu
-----END PGP SIGNATURE-----

--24zk1gE8NUlDmwG9--


--===============0837102381==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============0837102381==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0837102381==--
