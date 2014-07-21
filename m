Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41059 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007AbaGUD2i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jul 2014 23:28:38 -0400
Date: Mon, 21 Jul 2014 13:28:28 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: nfs4_do_open should add negative results to the
 dcache.
Message-ID: <20140721132828.77f1297e@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/3wCpofqhKW+EP+N1st/NZxx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3wCpofqhKW+EP+N1st/NZxx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



If you have an NFSv4 mounted directory which does not container 'foo'
and:

  ls -l foo
  ssh $server touch foo
  cat foo

then the 'cat' will fail (usually, depending a bit on the various
cache ages).  This is correct as negative looks are cached by default.
However with the same initial conditions:

  cat foo
  ssh $server touch foo
  cat foo

will usually succeed.  This is because an "open" does not add a
negative dentry to the dcache, while a "lookup" does.

This can have negative performance effects.  When "gcc" searches for
an include file, it will try to "open" the file in every director in
the search path.  Without caching of negative "open" results, this
generates much more traffic to the server than it should (or than
NFSv3 does).

The root of the problem is that _nfs4_open_and_get_state() will call
d_add_unique() on a positive result, but not on a negative result.
Compare with nfs_lookup() which calls d_materialise_unique on both
a positive result and on ENOENT.

This patch adds a call d_add() in the ENOENT case for
_nfs4_open_and_get_state() and also calls nfs_set_verifier().

With it, many fewer "open" requests for known-non-existent files are
sent to the server.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4bf3d97cc5a0..21fa7bddd3cb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2216,8 +2216,15 @@ static int _nfs4_open_and_get_state(struct nfs4_open=
data *opendata,
 	seq =3D raw_seqcount_begin(&sp->so_reclaim_seqcount);
=20
 	ret =3D _nfs4_proc_open(opendata);
-	if (ret !=3D 0)
+	if (ret !=3D 0) {
+		if (ret =3D=3D -ENOENT) {
+			d_drop(opendata->dentry);
+			d_add(opendata->dentry, NULL);
+			nfs_set_verifier(opendata->dentry,
+					 nfs_save_change_attribute(opendata->dir->d_inode));
+		}
 		goto out;
+	}
=20
 	state =3D nfs4_opendata_to_nfs4_state(opendata);
 	ret =3D PTR_ERR(state);

--Sig_/3wCpofqhKW+EP+N1st/NZxx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8yI3Dnsnt1WYoG5AQIE+hAApGe+IOZkhM85qxnvthh8IdUbhLQiu1B/
acgBONJLnIprpOHKvDfwP8D4Bu5NEt5qbUJBbopeeJI7TpHGAHEJ1OiQMqqtw3gV
e2po9ZhblTT8hzqpAYUblFDa1TMoVSqO8PaeHxymXfy5cnGM4oAYvVnx37TZCQAs
ON2AMoLGSsFSnFe/7KlfWQE+nNKuXr8YDiyiwDf13FVJmBRwdLIRc9ZW9tdr+0nu
o+zXi1bsON7IXEfG5bD34m6gJ7iV6Dvb3vtTtN4LsZbNZNDST/ne8tQRYNi9vgHW
gjTh4wArDphDx5TFdMtzpEj6RN30w9PjwYcswajNBbMbwg0XR9CT0fzqydzvann7
3evHTc1A9CeObzvsXUpBJl53nZ/dDsFtLoyrMalEvafnxK2aXTJARiPqtjREFUT0
+IKjUa2uf992Ij+8SRO49kojT3iFt9CHwzPzr8F1SjRYEySnlE4vG+57QSAdp86S
kcHnH0b0+BUqhKv7Qw9Kem7+oeESWb0J6xKDSOdq1DUBDMjywq8Cjbuip3WUTtv0
GXSYxVSL37Jg8pEW3DatYeTK6FClywNovgvKiZKUFakZ7QvOUMrfcElDcJit8v+a
/KKc7dmOBHAlu1LFu2seHQYXpZxrVh1ykwgwM/A+fX75RYDTG3HpGYk2P1wkSOsz
mjb+n48SxVQ=
=Q74A
-----END PGP SIGNATURE-----

--Sig_/3wCpofqhKW+EP+N1st/NZxx--
