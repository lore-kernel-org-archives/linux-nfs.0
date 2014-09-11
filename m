Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54678 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbaIKGTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Sep 2014 02:19:49 -0400
Date: Thu, 11 Sep 2014 16:19:37 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: remove BUG possibility in nfs4_open_and_get_state
Message-ID: <20140911161937.29dd4a31@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/aBR75OEoUytIL/g_/_5U9wl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aBR75OEoUytIL/g_/_5U9wl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



commit 4fa2c54b5198d09607a534e2fd436581064587ed
    NFS: nfs4_do_open should add negative results to the dcache.

used "d_drop(); d_add();" to ensure that a dentry was hashed
as a negative cached entry.
This is not safe if the dentry has an non-NULL ->d_inode.
It will trigger a BUG_ON in d_instantiate().
In that case, d_delete() is needed.

Also, only d_add if the dentry is currently unhashed, it seems
pointless removed and re-adding it unchanged.

Reported-by: Christoph Hellwig <hch@infradead.org>
Fixes: 4fa2c54b5198d09607a534e2fd436581064587ed
Cc: Jeff Layton <jeff.layton@primarydata.com>
Link: http://lkml.kernel.org/r/20140908144525.GB19811@infradead.org
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7dd8aca31c29..ac2dd953fc18 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2226,9 +2226,13 @@ static int _nfs4_open_and_get_state(struct nfs4_open=
data *opendata,
 	ret =3D _nfs4_proc_open(opendata);
 	if (ret !=3D 0) {
 		if (ret =3D=3D -ENOENT) {
-			d_drop(opendata->dentry);
-			d_add(opendata->dentry, NULL);
-			nfs_set_verifier(opendata->dentry,
+			dentry =3D opendata->dentry;
+			if (dentry->d_inode)
+				d_delete(dentry);
+			else if (d_unhashed(dentry))
+				d_add(dentry, NULL);
+
+			nfs_set_verifier(dentry,
 					 nfs_save_change_attribute(opendata->dir->d_inode));
 		}
 		goto out;

--Sig_/aBR75OEoUytIL/g_/_5U9wl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVBE++Tnsnt1WYoG5AQIXhw/+J53TN+kqv853R2RxZjJLu4cmR9v9zGrV
wRZhmvzb9eVz+dizfodp8J6VeWJ/+zU8PNa6Q8OsFl518Vh/Fk9JoijLfuoIkJCk
+Vso360YkDS+mc1SxerAQcEZUCZ5FSn8Z01ol6mIobUVr5zBeLZumJy4GUrh4Z9u
EoxxtevaNb1viM2ZVitD9xA5gYfW0laTKKyv7JkL8/RVbeGK0Ulh5dwu28brlZht
EwWlNrV58XJlAJw1XgU+S+WQilvwnHs0pzDYh0eRgVfladL3Jrm7Q0OVSNXGaXtc
LvyszuqJPBc0W6vL+dR9nbk8k8BKp/qr7bQRwY9mc/9BzwfLUzaOfakkH+KQTZfd
T6qOntt92b8JYWLeHHhPfrk2fH9uLtDHaS5pSto42yhynjWGFKQSksXLFqxIv4il
NB8ek4AWkEf8GJ0m1lX0D6RMAGn88yU0ea20D5vxZNrFceB+mkai5efjKZhi9CUa
J5suCoRb9lgMSDY5l4UIM2rXdoh9twmmPBOsmZQVWF0bRq8FzUmPYk7KN26PekdI
br8irCpfHtRPKd4LZrhhja6/T/RVTu/DTL8IqdNMuDaj+nvQfF2BVX0FewGlUWb4
3FeyFSrUrNuC0PofkYLAA7lWxExzSWLkaU/tXIKpFyccTNH8lGFjFCvlOT/DbS4g
7jBrD2UxlVI=
=tuAR
-----END PGP SIGNATURE-----

--Sig_/aBR75OEoUytIL/g_/_5U9wl--
