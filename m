From: Alex Samad <alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Subject: Re: question about /etc/exports
Date: Tue, 5 Aug 2008 07:41:25 +1000
Message-ID: <20080804214125.GE19523@samad.com.au>
References: <20080731204838.GA27473@samad.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oLBj+sq0vYjzfsbl"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail11.tpgi.com.au ([203.12.160.161]:52241 "EHLO
	mail11.tpgi.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1770656AbYHDVlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Aug 2008 17:41:32 -0400
Received: from sydrt01.samad.com.au (adsl.samad.com.au [60.241.248.86])
	by mail11.tpgi.com.au (envelope-from alex-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org) (8.14.3/8.14.3) with ESMTP id m74LfPZr003645
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2008 07:41:29 +1000
Received: from alex by smtp.samad.com.au with local  (Exim 4.69 #1 (Debian))
	id 1KQ7nx-00056d-RY
	for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2008 07:41:25 +1000
In-Reply-To: <20080731204838.GA27473-SGFoFqf0RKf0CCvOHzKKcA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--oLBj+sq0vYjzfsbl
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



--oLBj+sq0vYjzfsbl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiXd4UACgkQkZz88chpJ2OqAACg2b3UA8lR1OBnNys0GKTB6bqZ
CrkAn2MVIEZO3hRItBWum3eOR03h/upi
=jiyH
-----END PGP SIGNATURE-----

--oLBj+sq0vYjzfsbl--
