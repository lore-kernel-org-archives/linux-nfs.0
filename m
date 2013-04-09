Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53605 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932625Ab3DIXqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:46:51 -0400
Date: Wed, 10 Apr 2013 09:46:39 +1000
From: NeilBrown <neilb@suse.de>
To: chuck.level@oracle.com, sysstat@orange.fr
Cc: linux-nfs@vger.kernel.org
Subject: Too man programs calls nfsiostat.
Message-ID: <20130410094639.5debfc90@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/grbkQl9tCmNvb21I8qXhGbd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/grbkQl9tCmNvb21I8qXhGbd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi all,
 it seems that in 2010, a program called nfsiostat was added to the sysstat
 package (http://sebastien.godard.pagesperso-orange.fr/)

 This is unfortunate because in 2008 a program called nfsiostat was added to
 the nfs-utils package.
    (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)

 The default install locations seem to be different (/usr/bin vs /usr/sbin),
 so packagers would not immediately notice.

 This seems like something that should be "fixed".

 Any suggestions what a good "fix" should look like?

NeilBrown

--Sig_/grbkQl9tCmNvb21I8qXhGbd
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUWSoYDnsnt1WYoG5AQIpWg//QgsD1nE+JalXLx4G8pcMS2n/9203OtsQ
srYqgoHV4D1DvNTBNerNb2AzMvP4pXo2Lx4LXhLbzdZca4Ec1t4RBSpRCUwXvSpw
t0WGrlNBChftsOQb6rzTKe363WkV2Mn3nOxv7idIEBrhyUWcDEWq7uikoXLgNLvd
9nsC9RoFRjqA2rNqYWBVyM/sTXL/TVCGv+vqDS+/bC3dQKPxZkunCpBZImFUlOR5
1KyVQwt8eO8bYqF3qS+D53kHb9BuPutUDACptHc3ZqNfAqSthRk1NmyKaXxqWHk7
22k/kMYM4L3kIkJyy8qq3XBYHf4Kp0w3xmUcUlRwbI4KzwcpVvm7w0DF41AM9mNW
BAAgncdYpdg8dJ6HHwN5FV86Roc3t1Zww/A+FU2FQxTP43Dr7wSdKpQ5zuE7G0lS
iNH66oWv7Liai2MKtebwz//c3NnPDrOAfUfiy7BDOZEf+2/4mjfrOmhfa7GlShLH
oPvQ4DbXFEQH/VKD5lO/1v6lDy4L0CxvmGCzNTPAPfXj6Qqmzy35QuF/SK5CiweS
fug7qMW0kzqBl+7+PE7mkNZ5Am33/z5bJRUVNFhZU1Uw1UlcuHMcdsvzcz9LMNtO
LBxS7BI4RQ5FKHs5JZlij6m1pKL83/pC5yEpZfyiq9UXcRHZnmEdH7tA7DaRXUMm
jvBtZnYORrM=
=Drmt
-----END PGP SIGNATURE-----

--Sig_/grbkQl9tCmNvb21I8qXhGbd--
