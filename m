Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:33300 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752842AbcHOTiO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2016 15:38:14 -0400
Date: Tue, 16 Aug 2016 03:38:12 +0800
From: Mike Frysinger <vapier@gentoo.org>
To: "Yann E. MORIN" <yann.morin.1998@free.fr>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [Libtirpc-devel] [PATCH rpcbind] src: include cdefs.h for the
 __P() macro
Message-ID: <20160815193812.GE30544@vapier.lan>
References: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr>
 <7736F23D-7AA5-4ABD-9693-99C9DCE03B91@oracle.com>
 <20160814221352.GI30771@free.fr>
 <5769F8D5-D7F9-4528-BC5C-B1EF921F52CD@oracle.com>
 <88231b80-c3cd-8486-9e1a-a0abb127a826@RedHat.com>
 <20160815154845.GH5822@free.fr>
 <a64169e9-7e67-b555-1d8f-bf13e1b00a87@RedHat.com>
 <20160815174106.GJ5822@free.fr>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xNm6VWMD3PcA105u"
In-Reply-To: <20160815174106.GJ5822@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--xNm6VWMD3PcA105u
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

GNU projects have been dropping the __P cruft for a while now, and that
includes autoconf and gnulib, both of which are more or less the "gold"
standard when it comes to portability.
-mike

--xNm6VWMD3PcA105u
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXshokAAoJEEFjO5/oN/WBuIgQAN0Yty24R/YXZ6/NzREw8f8s
yUQ445/jUKOCnEAoGsbrDBol/95RbuzxxUtGPoc5djMQo5uMBr47JQBLv3LVmNRI
r+xMj4EfyGkWkOWJSPVuacKNmCIWOv9OXh2LdOmSHndv5G2OvCjZplHE5AeueCrD
//CdyjkAv4KddWDtB/ZL9xraiSW4wzNFvNn9bu1r9Ou0P8zA1Y3yQlffTvi74S35
TMFP50bbFrdJBXeUOZO0uZIvnj05Xtct0UVQOj6WdtHfwzEgvPTETBYeqdYkqBCp
9gHRjCFOptyQqVDq/yHg8MrYysqr7MXitYHNcfBWt9D8g3ycQogp0s9IYexV45PQ
OX/oxI0axzNEKN2gunNB9UuiJESfS4p8yS9AWFu4AgxMfC9o3U9fF34mlVtG1qRM
1eFGloq7PxM+cR6G4AbqmVQff4B0lajDqg/MHOpOiUm1Akb1PFB8ATwmE38+BeJX
xiGd2BXZLzVR3z8GU1SSBznzfMuxICpAdyzk2Yto6RPXVTyAH02P6Ie8AGxZB54i
K3WwKscLEyPdE1w7nwa56cjyqMU7hzzMTVdDHzGnoY/ynCG1WbuPexk0Un1uECCh
ADS7kiDJXNjihoBv8X6GGFZppyObe9xrla79ZpdNXf02Xc5D67PW9Bqr3ZsxwYW5
BURXrrqcB4cDr8L1YeSK
=NjzF
-----END PGP SIGNATURE-----

--xNm6VWMD3PcA105u--
