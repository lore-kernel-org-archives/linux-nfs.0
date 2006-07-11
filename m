From: =?iso-8859-1?Q?An=EDbal?= Monsalve Salazar <anibal@debian.org>
Subject: Re: nfs-utils-1.0.9 compilation failed!
Date: Tue, 11 Jul 2006 10:06:48 +1000
Message-ID: <20060711000648.GE11009@debianrules.debiancolombia.org>
References: <4d569c330607101604u62a240edo6116c589ac4dc780@mail.gmail.com>
	<OF985C22F0.D508648E-ON882571A7.00808418-882571A7.00839C72@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0106984382=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G05mC-0000LC-5a
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:07:03 -0700
Received: from cpe-60-224-176-117.vic.bigpond.net.au ([60.224.176.117]
	helo=elida.v7w.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1G05mB-0006kt-4d
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 17:06:56 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <OF985C22F0.D508648E-ON882571A7.00808418-882571A7.00839C72@us.ibm.com>
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


--===============0106984382==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9l24NVCWtSuIVIod"
Content-Disposition: inline


--9l24NVCWtSuIVIod
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 10, 2006 at 04:57:30PM -0700, Usha Ketineni wrote:
>nfs-bounces@lists.sourceforge.net wrote on 07/10/2006 04:04:46 PM:
>
>>write_oid() should be defined in utils/gssd/write_bytes.h as an=20
>>inline function.
>
>hmm...I don't see it defined in write_bytes.h in the nfs-utils-1.0.9=20
>source and hence the compilation error.
>Just added it as inline function myself from the previous release and it=
=20
>compiled just fine.=20
>I guess the nfs-utils-1.0.9 package is broken then.

It has been compiled successfully twice on 12 different arches. See:

http://buildd.debian.org/build.php?pkg=3Dnfs-utils

>Thanks
>Usha

An=EDbal Monsalve Salazar
--=20
http://v7w.com/anibal

--9l24NVCWtSuIVIod
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEsuuYiKF4f8PxWcoRArFCAJ9jsNKpv/TTlpGKgNKTCSw04vJqHwCfaFne
TwHTTxeMgSQxrXNvlEyHFqM=
=pi/z
-----END PGP SIGNATURE-----

--9l24NVCWtSuIVIod--


--===============0106984382==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============0106984382==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0106984382==--
