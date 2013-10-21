Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49759 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751559Ab3JUXSI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 19:18:08 -0400
Date: Tue, 22 Oct 2013 10:17:54 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Wangminlan <wangminlan@huawei.com>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - nfs-utils] Stop Treat IP addresses a FQDN rather than
 SUBNETs.
Message-ID: <20131022101754.462d3f8b@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/tdYP2xc1BAMjlD3o36W+jf3"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/tdYP2xc1BAMjlD3o36W+jf3
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



I think there was a reason for this many years ago,
but I can not find any evidence that it ever really did
anything useful and it certainly doesn't seem to now.

And the documentation suggests that IP address take precedence over
SUBNETs, and that can only happen if they are treated as MCL_FQDN.

So remove this apparently pointless code.

Reported-and-tested-by: Wangminlan <wangminlan@huawei.com>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/support/export/client.c b/support/export/client.c
index ba2db8f..adbeed8 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -767,15 +767,5 @@ client_gettype(char *ident)
 			sp++;
 	}
=20
-	/*
-	 * Treat unadorned IP addresses as MCL_SUBNETWORK.
-	 * Everything else is MCL_FQDN.
-	 */
-	ai =3D host_pton(ident);
-	if (ai !=3D NULL) {
-		freeaddrinfo(ai);
-		return MCL_SUBNETWORK;
-	}
-
 	return MCL_FQDN;
 }

--Sig_/tdYP2xc1BAMjlD3o36W+jf3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmW2Ijnsnt1WYoG5AQKNhg/+LYwW5K0b9hOpsdPSYnHzIjaGHQZCk1Z0
TZEfWLgQgfQO1biy+xfRP54+1PjVt/4NOFqp+tuHNC/gFj+R6PZfwZfTYXypDnZ/
wWp01d61UfSdnYwrZHL6SlFbenuatHbdxYaaxlIPwheAWyqXKaMxLKyej4RyWx88
Jbhje2JBC8GdNhWkgIMYb6j2d89KNFuj0CRSM4wopYgNE6+G6I2bDqXqO8GVG5sz
w/1V3lSYku8Xj4VebDO2+EQbMmvtTkPb7cLYfbmm82izqZCPyZtDb9ENibvHRvyg
MI4VkYS34L6cOJV5FTkgNpL5MUDZa7ICsKp7q6ng/a3n6n0c+6+gGv6ZMa9AXL55
XZkAdE3e6aCOHocE/8EuqWpijKziHGnYpqds4zuKj/LXOMJRI+6HucXDq82J/s4e
fFfZ9mhUA97ewXqbHxx3sqJrjgU3//yYg8KYtK84UZI1kFJiTmXYtEYG/xE5Az7m
wrpNVCxLExr5uO2klmUBV6FJVqF+JXD2NHwruXOyFPjgPC0D+cRPmZuP0/NvSZ91
KGf+MRubDhb/bo8WrMKmkxdi5og1uZf7CxEk3hF06WqYZr+LuUhfSNK4LmHIskPb
OMjT65BGyMRvtgBSDDUKoLcI6dX/a+BoiU76cJlYGHc2oEAzdunNUBKpPYe4a8HN
iA7soAeklrU=
=5iEE
-----END PGP SIGNATURE-----

--Sig_/tdYP2xc1BAMjlD3o36W+jf3--
