Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:44616 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683Ab2IPXFl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Sep 2012 19:05:41 -0400
Received: from relay1.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 0EC229D938
	for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2012 01:05:40 +0200 (CEST)
Date: Mon, 17 Sep 2012 09:05:37 +1000
From: NeilBrown <neilb@suse.de>
To: linux-nfs@vger.kernel.org
Subject: What is NFSv4 READDIR doesn't return a filehandle....
Message-ID: <20120917090537.20e38026@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/VjR8x_bHVt1EjXYd8JWG/42"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/VjR8x_bHVt1EjXYd8JWG/42
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


In NFSv4, the server can report which attributes it chose to return in a
READDIR reply.

A customer has come across a server which does not return the filehandle
information (is that allowed?).

A consequence of this is that Linux/NFS gets confused.
nfs_readdir_page_filler calls nfs_prime_dcache() (because it was a readdir
plus request that was sent) and nfs_prime_dcache goes ahead and creates an
inode based on the filehandle that it has.
However decode_attr_filehandle() had happily decoded nothing as the
FATTR4_WORD0_FILEHANDLE bit wasn't set.
So the inode gets created with a zero-length filehandle and when this gets
sent back to the server to act on the inode, it gets NFS4ERR_BADHANDLE to
the PUTFH op.

So should nfs_prime_dcache() abort if the filehandle doesn't exist (patch
below) or should nfs_fhget() return an error if the filehandle is empty?

Or maybe this behaviour should be detected and readdir should be disabled f=
or
that server?

Suggestions?

Thanks,
NeilBrown

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 627f108..148d09c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -442,6 +442,10 @@ void nfs_prime_dcache(struct dentry *parent, struct nf=
s_entry *entry)
 		if (filename.len =3D=3D 2 && filename.name[1] =3D=3D '.')
 			return;
 	}
+	if (entry->fh.size =3D=3D 0)
+		/* Server didn't return a filehandle */
+		return;
+
 	filename.hash =3D full_name_hash(filename.name, filename.len);
=20
 	dentry =3D d_lookup(parent, &filename);

--Sig_/VjR8x_bHVt1EjXYd8JWG/42
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFZbQjnsnt1WYoG5AQKWnA/+PsqspN5pRZOQDvdCEoI2yEcuW2U1NkEw
NA43ME3USO3tz9GowbF1S8gBC+BACEtEXXtQNBrnl8ZFBnwi6Pqu2/M8SILCa7SL
gDDcb1qjPNqTgDDcdrTkAe59WY6vyJSmq1KlrH7XqmoysUgV1PPGAnkZzlrfmGk+
nchhFVFmk3EnB/UkPDBkz0ce9iuhhVTW3TMf8hyayPtwHvW6uKCflvH4/6+u3Rmg
uhJSy6OoG/Djco1wuDW80DnkXaosHRUC7Gb23j4J7OJFLDoPUaGbGjcwFKXKkYXj
M5LqVVsMIz+jvY/HpVeMUJ1g50vVS8+9Y1rFu/VObBBYfQLKS6bbemmbit8FxMdW
IdHhUBHkdBbNI1XjgHZnYPDmpqZpf6IXNSyj1yAGKEMkqUw0NkN2+c5ldwtFzeYI
1Hu4za9XoLKA15mjGwg36k54VVle2pcAW5r4VjxY759TwfW5FFZOr0viBAurS69S
PW5I5TlQPmFIuqARQdBM0l6ajwi5hF7sJFqizCCIdQC6iw1lstcG7md/uLr9MVE7
e6DX8Wvd51wF6vlVAEj4R6qRZKhl0zB8w01PCBJIrMszCJntAv9Gk9HoiQvYJ9ZK
uEfpHT4i9fdenEGqhzqqSIgC0dZIBexX2MyCiD0GBlqJ4oLnEpIaqB15h8Mgd3ys
kY3Nwb9JGjA=
=iGsr
-----END PGP SIGNATURE-----

--Sig_/VjR8x_bHVt1EjXYd8JWG/42--
