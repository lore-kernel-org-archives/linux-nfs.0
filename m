Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38689 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755822AbcHDATP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 20:19:15 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 04 Aug 2016 10:19:06 +1000
Cc: fdmanana@kernel.org, linux-btrfs@vger.kernel.org,
        NFS List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] exportfs: be careful to only return expected errors.
In-Reply-To: <20160722200843.GA7463@fieldses.org>
References: <1465491191-28102-1-git-send-email-fdmanana@kernel.org> <874m7i8oou.fsf@notabene.neil.brown.name> <20160722015904.GB29969@fieldses.org> <87bn1q75ut.fsf@notabene.neil.brown.name> <20160722200843.GA7463@fieldses.org>
Message-ID: <877fbxperp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable



When nfsd calls fh_to_dentry, it expect ESTALE or ENOMEM as errors.
In particular it can be tempting to return ENOENT, but this is not
handled well by nfsd.

Rather than requiring strict adherence to error code code filesystems,
treat all unexpected error codes the same as ESTALE.  This is safest.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

I didn't add a dprintk for unexpected error messages, partly
because dprintk isn't usable in exportfs.  I could have used pr_debug()
but I really didn't see much value.

This has been tested together with the btrfs change, and it restores
correct functionality.

Thanks,
NeilBrown

 fs/exportfs/expfs.c      | 10 ++++++----
 include/linux/exportfs.h | 13 +++++++------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 207ba8d627ca..a4b531be9168 100644
=2D-- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -428,10 +428,10 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mn=
t, struct fid *fid,
 	if (!nop || !nop->fh_to_dentry)
 		return ERR_PTR(-ESTALE);
 	result =3D nop->fh_to_dentry(mnt->mnt_sb, fid, fh_len, fileid_type);
=2D	if (!result)
=2D		result =3D ERR_PTR(-ESTALE);
=2D	if (IS_ERR(result))
=2D		return result;
+	if (PTR_ERR(result) =3D=3D -ENOMEM)
+		return ERR_CAST(result);
+	if (IS_ERR_OR_NULL(result))
+		return ERR_PTR(-ESTALE);
=20
 	if (d_is_dir(result)) {
 		/*
@@ -541,6 +541,8 @@ struct dentry *exportfs_decode_fh(struct vfsmount *mnt,=
 struct fid *fid,
=20
  err_result:
 	dput(result);
+	if (err !=3D -ENOMEM)
+		err =3D -ESTALE;
 	return ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(exportfs_decode_fh);
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index b03c0625fa6e..5ab958cdc50b 100644
=2D-- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -157,12 +157,13 @@ struct fid {
  *    @fh_to_dentry is given a &struct super_block (@sb) and a file handle
  *    fragment (@fh, @fh_len). It should return a &struct dentry which ref=
ers
  *    to the same file that the file handle fragment refers to.  If it can=
not,
=2D *    it should return a %NULL pointer if the file was found but no acce=
ptable
=2D *    &dentries were available, or an %ERR_PTR error code indicating why=
 it
=2D *    couldn't be found (e.g. %ENOENT or %ENOMEM).  Any suitable dentry =
can be
=2D *    returned including, if necessary, a new dentry created with d_allo=
c_root.
=2D *    The caller can then find any other extant dentries by following the
=2D *    d_alias links.
+ *    it should return a %NULL pointer if the file cannot be found, or an
+ *    %ERR_PTR error code of %ENOMEM if a memory allocation failure occurr=
ed.
+ *    Any other error code is treated like %NULL, and will cause an %ESTAL=
E error
+ *    for callers of exportfs_decode_fh().
+ *    Any suitable dentry can be returned including, if necessary, a new d=
entry
+ *    created with d_alloc_root.  The caller can then find any other extant
+ *    dentries by following the d_alias links.
  *
  * fh_to_parent:
  *    Same as @fh_to_dentry, except that it returns a pointer to the parent
=2D-=20
2.9.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXoon6AAoJEDnsnt1WYoG5IJUP/3D4Gf5r4jyqxRWcJzB2+Bj0
UNQv9JF3R2G3A0qBdBbxbyPPtpiOdOEb4gFCOVDP5JJpo2ytRwYCNhxOL3G8RCXO
RrA0yqhgSLYJOz0jqXzYfbojYv8dFNXDySxq/91Fy/U9OWwYMwXdCm8xy9I4ww9L
n04cWWhR0amTwVYiDDORpzLN0pD1NZQliZzU7xBnvcnONgAmRzQtj5HnG2fe6PBd
G1CTTX9fgVrSqK6SabZMQ7HIWaLWq6qGt0p1gDJzV4YtcECs/FrJwia5O47o4Y0h
6RleILj0vMN70EalmikKRSgrHZFOfBey3LXGrmtDIAE/C3uDcF4GfR5SicBGcvHG
bY8PtxrINXIrPosYn5Tdlnh3NhcCylmD80iJcDu9mPAJ8NPQOY641qnM3RARC5Zl
1PZbdi4tmF711Xu3j8gSwQ0k8ABsJoQptXQUwBqDs7MhcFAdOdJIFO1yKsJhvF6U
jZS2+7asljUW7CXwkQ+U1fZPu76kMgUdCQg472wZWEKIzfPg6xmAFoW1B0wW19G/
PCXvNmjj8B/Iw1JABgXu9gpjyL2l6ac7HkxB5i20PvgckbPsZ5I7GbPsGouLm4hL
bp7wVwyuG65eZSw1O1LT9+HMy6n0YN7YyyKax6FsuBzT8tw77/8Fr2viLur7EHXB
wvOInO7MAuhiaLZziBD/
=+kE1
-----END PGP SIGNATURE-----
--=-=-=--
