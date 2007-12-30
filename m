From: Mike Frysinger <vapier@gentoo.org>
Subject: [NFS] exportfs -r: segfault with sec= option
Date: Sun, 30 Dec 2007 12:59:29 -0500
Message-ID: <200712301259.29484.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1107983184=="
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49820 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755787AbXLaAPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 30 Dec 2007 19:15:50 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J98Jl-00022R-7M
	for linux-nfs@vger.kernel.org; Mon, 31 Dec 2007 11:15:45 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1107983184==
Content-Type: multipart/signed; boundary="nextPart3781365.UoL4j1ekIS";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart3781365.UoL4j1ekIS
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

while testing other things, i was toying with /etc/exports and inserting bo=
gus=20
lines.  i found that this simple one makes exportfs segfault:
/mnt 192.168.0.0(sec=3D)
then just run `exportfs -r`

this version of nfs-utils has gss disabled ...
=2Dmike

--nextPart3781365.UoL4j1ekIS
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.8 (GNU/Linux)

iQIcBAABAgAGBQJHd9yBAAoJEEFjO5/oN/WBpOIQAMzncx1LSPCIjwk8cZF3xzrM
dC5aT2XtqKJcYjZGS4z/2qbse8DPi5xJWnYoBijO/FaFSwtFt3s47tyVQU1crri3
rwaBmm0JQql5MF4fF3t3iisRV/C7SzS2iSyJQTZiR7m7dI0EKHN2PDxF2hlhxBzm
rUzH8xwja/lpS+zMDr928Sv6XxpoSYhty4eP8c14OtHRklWJkC+eUAnRDChra3W5
pin2fwTNh0Zui6TwNp36UvNVfG1mTfkmDTzY6aImlbr/JLVPjaSjwCEvEOd2WWnL
cHkwgf0AD+8ttgnR4QxAx6VjDFkaSuiukVIHoijh6gDrzOfeKJcNwHi1lT3OGdDA
6kGjDtr9wbF4WFL1xof1uGYWBF13IAIkdyKFKtxeocey/a1GYY0y8lNx0+wlLY8q
QSkhQFCukCW4lRZDvFkfcPdsv3owwqyUgDjaN7CmtpuWsfhVRo6pdeKntDHEinQ4
l+MBOPBtQodjF1v6ftX0Nf2CTD7HkM/n4xBq/vZ2cDL7PZXekSDYWlCYSxoOChZ7
CelhG7QVYtxiwHdRfwdBi9fsA4crHPCspX4wQgRXPU9v374/sSjzk/eyD7SBnDJU
ZGQAqG9Fx5MgN8shpMYx2vdtMPZvA1V0wj4uZkg9M89IEP8GiO5CYfJu46g0nhOy
0z3ZfTChvSkGI6Byurar
=ybtz
-----END PGP SIGNATURE-----

--nextPart3781365.UoL4j1ekIS--


--===============1107983184==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1107983184==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1107983184==--


