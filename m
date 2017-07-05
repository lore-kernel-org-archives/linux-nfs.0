Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45316 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752459AbdGECWc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 22:22:32 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 05 Jul 2017 12:22:20 +1000
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH] NFS: only invalidate dentrys that are clearly invalid.
Message-ID: <87wp7ny65f.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Since commit bafc9b754f75 ("vfs: More precise tests in d_invalidate")
in v3.18, a return of '0' from ->d_revalidate() will cause the dentry
to be invalidated even if it has filesystems mounted on or it or on a
descendant.  The mounted filesystem is unmounted.

This means we need to be careful not to return 0 unless the directory
referred to truly is invalid.  So -ESTALE or -ENOENT should invalidate
the directory.  Other errors such a -EPERM or -ERESTARTSYS should be
returned from ->d_revalidate() so they are propagated to the caller.

A particular problem can be demonstrated by:

1/ mount an NFS filesystem using NFSv3 on /mnt
2/ mount any other filesystem on /mnt/foo
3/ ls /mnt/foo
4/ turn off network, or otherwise make the server unable to respond
5/ ls /mnt/foo &
6/ cat /proc/$!/stack # note that nfs_lookup_revalidate is in the call stack
7/ kill -9 $! # this results in -ERESTARTSYS being returned
8/ observe that /mnt/foo has been unmounted.

This patch changes nfs_lookup_revalidate() to only treat
  -ESTALE from nfs_lookup_verify_inode() and
  -ESTALE or -ENOENT from ->lookup()
as indicating an invalid inode.  Other errors are returned.

Also nfs_check_inode_attributes() is changed to return -ESTALE rather
than -EIO.  This is consistent with the error returned in similar
circumstances from nfs_update_inode().

As this bug allows any user to unmount a filesystem mounted on an NFS
filesystem, this fix is suitable for stable kernels.

Fixes: bafc9b754f75 ("vfs: More precise tests in d_invalidate")
Cc: stable@vger.kernel.org (v3.18+)
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/nfs/dir.c   | 12 ++++++++----
 fs/nfs/inode.c |  4 ++--
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4f0706bd387f..727c5a53417a 100644
=2D-- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1115,11 +1115,13 @@ static int nfs_lookup_revalidate(struct dentry *den=
try, unsigned int flags)
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) &&
 	    nfs_check_verifier(dir, dentry, flags & LOOKUP_RCU)) {
=2D
=2D		if (nfs_lookup_verify_inode(inode, flags)) {
+		error =3D nfs_lookup_verify_inode(inode, flags);
+		if (error) {
 			if (flags & LOOKUP_RCU)
 				return -ECHILD;
=2D			goto out_zap_parent;
+			if (error =3D=3D -ESTALE)
+				goto out_zap_parent;
+			goto out_error;
 		}
 		nfs_advise_use_readdirplus(dir);
 		goto out_valid;
@@ -1144,8 +1146,10 @@ static int nfs_lookup_revalidate(struct dentry *dent=
ry, unsigned int flags)
 	trace_nfs_lookup_revalidate_enter(dir, dentry, flags);
 	error =3D NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr, la=
bel);
 	trace_nfs_lookup_revalidate_exit(dir, dentry, flags, error);
=2D	if (error)
+	if (error =3D=3D -ESTALE || error =3D=3D -ENOENT)
 		goto out_bad;
+	if (error)
+		goto out_error;
 	if (nfs_compare_fh(NFS_FH(inode), fhandle))
 		goto out_bad;
 	if ((error =3D nfs_refresh_inode(inode, fattr)) !=3D 0)
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5751c1310177..7e7a894601b9 100644
=2D-- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1321,9 +1321,9 @@ static int nfs_check_inode_attributes(struct inode *i=
node, struct nfs_fattr *fat
 		return 0;
 	/* Has the inode gone and changed behind our back? */
 	if ((fattr->valid & NFS_ATTR_FATTR_FILEID) && nfsi->fileid !=3D fattr->fi=
leid)
=2D		return -EIO;
+		return -ESTALE;
 	if ((fattr->valid & NFS_ATTR_FATTR_TYPE) && (inode->i_mode & S_IFMT) !=3D=
 (fattr->mode & S_IFMT))
=2D		return -EIO;
+		return -ESTALE;
=20
 	if (!nfs_file_has_buffered_writers(nfsi)) {
 		/* Verify a few of the more important attributes */
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllcTV0ACgkQOeye3VZi
gblrMw/+Povgb/Yh10pAiphWt3Q45GoYdVq1kU4dfR9nvdY2lf9JLRGqaMJAwo6g
cKhA2Hcy1SAzxQXBbz5a0f7xuSxUGErCIZ5/wn4p9+NW8hqpJ5GYOwT3hV7+BKDE
ov94hPtmm34AydxHZL/k/JZiBM4HEyGwVxSu06RtwiKMgKxGTns0fBtL6gS8j+1s
IZ2n6PZTTSUki8cXyIz8x70dkBCkOyfbBLpvDl5AOxjNctELWxpB1bL3NG9bN5Ie
Mmr0qzMrMtBhDsoJ3a0wRHGli6qJh/p42VInnD4qzsWJA6UvUKrMYSCfbZ8sz+9l
iBnaBjvktX/RBqH0P0VL3T2yoSMmcrWgzJZ6TDPuxop5aDoGsfjytd/PJMNIGXD6
RCIUy0wHUXduXuiv6IjpQiQZd2BcCg7lVKznD3lgBfJT7aQYEkgdMBxr4JqhZu6p
dY/6A6+Z4wV8/axwAk2CnxQNqWBdQaFMTJwKV4WcHs1EgtIWPNcggY+/sqwP80K3
3lsubwJJmerI+nAWeIKXj5IAh8P+R0CetotxwXahTGvzE30f237DRb/qPgc0sInA
G3lDRfVrcl2yphV9mxWbDborA8VjuTP9HR2qe3SJW2mjx/fvRCZAu/eJ0oqN8Gw4
Ay8BzV/9UTx/zlz60x/GPZwfl1tiaT6t14wtUJU8qSWYtJWK/VI=
=op9x
-----END PGP SIGNATURE-----
--=-=-=--
