Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56040 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab3KNCAl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 21:00:41 -0500
Date: Thu, 14 Nov 2013 13:00:17 +1100
From: NeilBrown <neilb@suse.de>
To: Charles Edward Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: correctly report misuse of "migration" mount option.
Message-ID: <20131114130017.374c0f3d@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/K3ItMduO.lDT=6R0/a5jHq0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/K3ItMduO.lDT=6R0/a5jHq0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


The current test on valid use of the "migration" mount option can never
report an error as it will only do so if
    mnt->version !=3D4 && mnt->minor_version !=3D 0
(and some other condition), but if that test would succeed, then the previo=
us
test has already gone-to  out_minorversion_mismatch.

So change the && to an || to get correct semantics.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 317d6fc2160e..910ed906eb82 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1613,9 +1613,9 @@ static int nfs_parse_mount_options(char *raw,
 	if (mnt->minorversion && mnt->version !=3D 4)
 		goto out_minorversion_mismatch;
=20
 	if (mnt->options & NFS_OPTION_MIGRATION &&
-	    mnt->version !=3D 4 && mnt->minorversion !=3D 0)
+	    (mnt->version !=3D 4 || mnt->minorversion !=3D 0))
 		goto out_migration_misuse;
=20
 	/*
 	 * verify that any proto=3D/mountproto=3D options match the address

--Sig_/K3ItMduO.lDT=6R0/a5jHq0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoQusTnsnt1WYoG5AQLneg//WsEa8HIlYPOa44IZGwumsVkjXH7PTc/A
1eY7Cc3nAB/iPqKhqoAKmf8rpeYgoB9FsUu0OjwKTHZlw35u1BDr+64sVdk1gbPj
nZp9EkyorEaUtGFI1aZqgAkK79YPO9aRl4eb2jCo9wglAV7fxvUNynLYepPGuAKf
2Jfs7q568Hhsw8CcZ+taJReK759D/7LeOgF1PpwCctjma+YiTyeW88KXa+ERbbfK
fUZyqpuJIoBMasxlHFZUBj5/C7H7KOBf+usP3jgyWIEEmtEIFkGiC3tKSsFBQTqP
24VqoVMamk08P+3xR1y+9xrRxgZmit0StgCSNz182UNB1jK5ksRztivSXWpEZ3M+
210RZQUteWuLzqjIxZvZB9dUVeplPSa2ob9TBpUMNWqAd6cQ9HvIVT0ebMWt6fH4
e74mDOBhvNoxmyettEwuS9nigWY5UehfeuFjFoiwVhy1lxO2UDqb01kcpknk8tTP
WmIXwBo7lyEq8FJrnNSKxl6FWmC65wibBCU6+dupvZ+x0IczfM/AWnMxTK28hvSb
ZzmB6sjfwBj8qhaldD/rXini/7BVhHl2RcFUs+PznZ4+OGqYQsxKuadkAHb7h8Ui
+9+XUaroWz3vYKaSLVjjA7WSUJ07cc0v6Tg07wecZ6C8FgYS0Z4qWT2LaRim6Ga7
/0DqhrH57R8=
=aFNP
-----END PGP SIGNATURE-----

--Sig_/K3ItMduO.lDT=6R0/a5jHq0--
