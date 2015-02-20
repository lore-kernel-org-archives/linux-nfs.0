Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33953 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281AbbBTVC6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Feb 2015 16:02:58 -0500
Date: Sat, 21 Feb 2015 08:02:48 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>, Nix <nix@esperi.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] NFS: nfs_prime_dcache() needs fh to be set.
Message-ID: <20150221080248.0a487903@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/gi2kl3hP=3_xYl.2a=V1hW4"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/gi2kl3hP=3_xYl.2a=V1hW4
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


In some circumstances, READDIRPLUS does not return a filehandle.
A particular example is that the Linux NFSv3 server does not return a
filehandle for directories that are mounted on.

When that happens, we mustn't call nfs_prime_cache, as it will assume
that the filehandle has changed and will invalidate the dentry.  This
will unmount any filesystem mounted at or below that point.

This bug has been present since 2.6.37 when commit d39ab9de3b80da
introduced nfs_prime_dcache.
It has become easier to trigger since commit 311324ad17136
in Linux 3.15 increased the usage of READDIRPLUS on directories that
were already largely in cache.

Note that if the server actually returns a different file handle
for a mounted-on directory, that will still force an unmount.
Possibly Linux should refuse to mount anything on a directory which
has a 'FH_VOLATILE_ANY' file handle.

Reported-and-tested-by: Nix <nix@esperi.org.uk>
Signed-off-by: NeilBrown <neilb@suse.de>
Fixes: d39ab9de3b80da5835049b1c3b49da4e84e01c07
Cc: stable@vger.kernel.org (v2.6.27+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 9b0c55cb2a2e..43e29e3e3697 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *d=
esc, struct nfs_entry *en
=20
 		count++;
=20
-		if (desc->plus !=3D 0)
+		if (desc->plus !=3D 0 && entry->fh->size)
 			nfs_prime_dcache(desc->file->f_path.dentry, entry);
=20
 		status =3D nfs_readdir_add_to_array(entry, page);

--Sig_/gi2kl3hP=3_xYl.2a=V1hW4
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVOeg+Dnsnt1WYoG5AQLn2w//XrCpID3cBy/OfgAZltvDOu9z5xh6OaDR
WhjDykX5KkPp7gJ4abR3q3q+ejhl7quFRosW8DNZQod68GrnpgAG2T3TerHAKZIA
YlHYKFqGBh4UR7ugfH3b4ZcKTtUveXp4wLhUomqgkWWAjOLk+VGv4KP4ICQdph2t
1jvSG5GhJPqumA1ksquM7prHtCkM3dbPY1O6he1NQVZ7tV8xd2yd15sor2def3u2
mjNM0WdSHNDj1cw8/zH4O/kCVkm9PgqQBqVB/3JBWFSYoIpFivkaMT1E9C2NUOfI
zMmjxwxg8LFRi+3CsXDhHrO5R+DHJmAF7ZAf8FgSDiDQsnl1iyzjqzGw9B+kpCJH
Xt9ItAUbdZ7qzS+HbGoHN+T3SYHz1PYt6C5Woie+7zaNrGGSAjZk5pzQN/gzjpcK
R7DQEMFy3FByTMUAC8pKpC/VrBUs7yliOZWiNypjDdD6f96GmXg2ZSeLqRGuLY1R
lfpexooj8SsxgvTqsQe47il1P2kEV2gcAKkvfUHSejE+iKEjF1uWV6TZnu7ZrH7w
q7XbeFaCZL7R6cv7xWVfRsrWoK/9L5MIfspZ9249eMVfvWBvabWyNIkBe9kRp/5G
XuedCa5AhVw0R97Qomar/h2IJ2JePczRB2b8Xknb1UUq+pZlsU2toTeVWNjrqvQg
CKQKDPyfJ68=
=XI28
-----END PGP SIGNATURE-----

--Sig_/gi2kl3hP=3_xYl.2a=V1hW4--
