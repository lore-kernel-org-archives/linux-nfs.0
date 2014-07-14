Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54675 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbaGNFOQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jul 2014 01:14:16 -0400
Date: Mon, 14 Jul 2014 15:14:05 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE inodes.
Message-ID: <20140714151405.2fa06dd7@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/e/C5V4a=/=EDmp=NM6YXdHC"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/e/C5V4a=/=EDmp=NM6YXdHC
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


If an 'open' of a file in an NFSv4 filesystem finds that the dentry is
in cache, but the inode is stale (on the server), the dentry will not
be re-validated immediately and may cause ESTALE to be returned to
user-space.

For a non-create 'open', do_last() calls lookup_fast() and on success
will eventually call may_open() which calls into nfs_permission().
If nfs_permission() makes the ACCESS call to the server it will get
NFS4ERR_STALE, resulting in ESTALE from may_open() and thence from
do_last().
The retry-on-ESTALE in filename_lookup() will repeat exactly the same
process because nothing in this path will invalidate the dentry due to
the inode being stale, so the ESTALE will be returned.

lookup_fast() calls ->d_revalidate(), but for an OPEN on an NFSv4
filesystem, that will succeed for regular files:
	/* Let f_op->open() actually open (and revalidate) the file */

Unfortunately in the case of a STALE inode, f_op->open() never gets
called.  If we teach nfs4_lookup_revalidate() to report a failure on
NFS_STALE() inodes, then the dentry will be invalidated and a full
lookup will be attempted.  The ESTALE errors go away.


While I think this fix is correct, I'm not convinced that it is
sufficient, particularly if lookupcache=3Dnone.
The current code will fail an "open" is nfs_permission() fails,
without having performed a LOOKUP. i.e. it will use the cache.
nfs_lookup_revalidate will force a lookup before the permission check
if NFS_MOUNT_LOOKUP_CACHE_NONE, but nfs4_lookup_revalidate will not.


Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4a3d4ef76127..4f7414afca27 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1563,6 +1563,8 @@ static int nfs4_lookup_revalidate(struct dentry *dent=
ry, unsigned int flags)
 	/* We cannot do exclusive creation on a positive dentry */
 	if (flags & LOOKUP_EXCL)
 		goto no_open_dput;
+	if (NFS_STALE(inode))
+		goto no_open_dput;
=20
 	/* Let f_op->open() actually open (and revalidate) the file */
 	ret =3D 1;

--Sig_/e/C5V4a=/=EDmp=NM6YXdHC
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8NnHTnsnt1WYoG5AQKJBQ/+NUp4m25EO7JlQf2Kd8v74KRI9kuXWwsI
mvzD/OvkUa98qN3ZoA6Na/5MQ5dh4sOpPThRQt1U4JiTQEh3z7FnHnhXloWzV29K
FwRGlKfAjeObLncMYgMakow5w74imZCiSEXvGa12+BZrCryhcZY3PN3JRIA/5vFy
zA/K9PxKyJHJDgPiDKKCR9Jx7IC9GX9e0rEP6/5a8ucutImtDtR2bEQl3nzM4XZs
VDz+0eE8qCOaFJehAgz0b5KiqU8lD9iHPrtEGceLI/u/JiednS2z0mbR0OcbEy80
/0expffjXvmavzUt5P+kVGbZ+SYOO86sGR+F3IwHVN7evgljp58T2DEGj6GmQSzw
D+CRr+0GpLqwVz6rrkANJGXOssdk4agSLZ7TeuVcbfZKSIs3ierwkMTZ3mq3GTKa
D9bpnlacREslaLST7mGpVVsKK1LrHLyUHx5WOsFG1XY5jDC8ltjqOStSWzcQnr31
aaYxsdAihC5pgWKSsjxK9pRuzCgMXg15GAdzfXCi0/UW7XpF0Lm4siOiAifIcpjZ
Q+uINssZstOOpiYwsVxgPUK+gPFq/N8Q9B1ojlnEa/7gyi+m+DhhypXXqRynmTpQ
DsK3G4JtkZRm4eLcKEUD70u7nOxMU8zZPIV7rt3Guqq1JVD7tF+ZHZ4l83r2Mnhh
hXFCInYgcbQ=
=SwuZ
-----END PGP SIGNATURE-----

--Sig_/e/C5V4a=/=EDmp=NM6YXdHC--
