From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: Re: [NFS] mount.nfs4 issue
Date: Fri, 29 Feb 2008 17:48:28 +0100
Message-ID: <200802291748.30887.toralf.foerster@gmx.de>
References: <200802281506.05177.toralf.foerster@gmx.de>
	<1204225211.7825.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1367837775=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45415 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752901AbYB2Qta (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Feb 2008 11:49:30 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JV8QJ-0005tk-Tw
	for linux-nfs@vger.kernel.org; Sat, 01 Mar 2008 03:49:27 +1100
In-Reply-To: <1204225211.7825.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1367837775==
Content-Type: multipart/signed; boundary="nextPart1329328.V5NgPLh16L";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1329328.V5NgPLh16L
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

At Thursday 28 February 2008 Trond Myklebust wrote :

>=20
> That's because you need to mount '/' instead of '/tmp'.

Argh - my fault, NFSv4 differs much more from NFSv3 than expected.

And why does the mount command checks for the existance of the directory
/root/<hostname> ?


=2D-=20
MfG/Sincerely

Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3

--nextPart1329328.V5NgPLh16L
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.7 (GNU/Linux)

iD8DBQBHyDdehyrlCH22naMRAml1AKCp9omWB0rDkRbpTtt5P/r+JQIqkACguN+i
70XAEajeWlLGLILPHS62ZLo=
=wZ73
-----END PGP SIGNATURE-----

--nextPart1329328.V5NgPLh16L--


--===============1367837775==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1367837775==
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

--===============1367837775==--


