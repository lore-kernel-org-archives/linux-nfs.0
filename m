From: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: question about /etc/exports
Date: Fri, 1 Aug 2008 06:48:38 +1000
Message-ID: <20080731204838.GA27473@samad.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="G4iJoqBmSsgzjUCe"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out9.tpgi.com.au ([220.244.226.119]:33232 "EHLO
	mail9.tpgi.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752705AbYGaVKF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2008 17:10:05 -0400
Received: from sydrt01.samad.com.au (adsl.samad.com.au [60.241.248.86])
	by mail9.tpgi.com.au (envelope-from alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org) (8.14.3/8.14.3) with ESMTP id m6VKmchh005322
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 1 Aug 2008 06:48:40 +1000
Received: from alex by smtp.samad.com.au with local  (Exim 4.69 #1 (Debian))
	id 1KOf4g-0007CI-1D
	for <linux-nfs@vger.kernel.org>; Fri, 01 Aug 2008 06:48:38 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--G4iJoqBmSsgzjUCe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi


I can't seem to find answer to this question if i have this in my
/etc/exports

/exports/video
-async,no_subtree_check,mp=3D/exports/video,crossmnt
192.168.8.0/22(no_root_squash,secure,rw)
192.168.11.12(insecure,all_squash,anonuid=3D1022,anongid=3D1020)

and I connect from 192.168.11.12 can I connect from an insecure port.      =
                   =20

the man pages don't specify who precedence is done, is it left to right,
best match, last match

Alex


--=20
"I think it's very important for the American President to mean what he say=
s. That's why I understand that the enemy could misread what I say. That's =
why I try to be as clearly I can."

	- George W. Bush
09/23/2004
Washington, DC

--G4iJoqBmSsgzjUCe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiSJSUACgkQkZz88chpJ2N9xgCgvUd3ijoJRF7ii9ZJGoDckx8J
W6kAn1HSWFxvtN0Dp9UwcWCKgOqQxUTO
=tIrt
-----END PGP SIGNATURE-----

--G4iJoqBmSsgzjUCe--
