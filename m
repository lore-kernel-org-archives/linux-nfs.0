Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34708 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125AbaBFCvQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Feb 2014 21:51:16 -0500
Date: Thu, 6 Feb 2014 13:51:01 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20140206135101.1cc83442@notabene.brown>
In-Reply-To: <20140206134539.53d09434@notabene.brown>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
	<20140129182532.7479eeda@notabene.brown>
	<1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
	<20140129071841.1979a48c@tlielax.poochiereds.net>
	<20140206134539.53d09434@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/nTreoQafEXacVzFZ2o/Bjiz"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/nTreoQafEXacVzFZ2o/Bjiz
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


On Thu, 6 Feb 2014 13:45:39 +1100 NeilBrown <neilb@suse.de> wrote:


> The change to nfs_update_inode fixes an issue that had me stumped for a
> while.  It was still sending lots of GETATTR requests even after it had
> switched to READDIRPLUS instead of using cached info.  So that might be a
> genuine bug that should be fixed independently of this patch.

I managed to post the wrong version of the patch, which didn't have this
change.  Sorry.

Here is the real one.

NeilBrown

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be38b573495a..b237fd7f2e0e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -845,9 +845,12 @@ static int nfs_readdir(struct file *file, struct dir_c=
ontext *ctx)
 	desc->dir_cookie =3D &dir_ctx->dir_cookie;
 	desc->decode =3D NFS_PROTO(inode)->decode_dirent;
 	desc->plus =3D nfs_use_readdirplus(inode, ctx) ? 1 : 0;
+	if (desc->plus && ctx->pos =3D=3D 0)
+		clear_bit(NFS_INO_DID_FLUSH, &NFS_I(inode)->flags);
=20
 	nfs_block_sillyrename(dentry);
-	if (ctx->pos =3D=3D 0 || nfs_attribute_cache_expired(inode))
+	if (ctx->pos =3D=3D 0 || nfs_attribute_cache_expired(inode) ||
+	    (NFS_I(inode)->cache_validity & NFS_INO_INVALID_DATA))
 		res =3D nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
 		goto out;
@@ -1080,6 +1083,16 @@ static int nfs_lookup_revalidate(struct dentry *dent=
ry, unsigned int flags)
=20
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentr=
y)) {
+		if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS)
+		    && ((NFS_I(inode)->cache_validity &
+			 (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
+			|| nfs_attribute_cache_expired(inode))
+		    && !test_and_set_bit(NFS_INO_DID_FLUSH, &NFS_I(dir)->flags)
+			) {
+			nfs_advise_use_readdirplus(dir);
+			goto out_zap_parent;
+		}
+
 		if (nfs_lookup_verify_inode(inode, flags))
 			goto out_zap_parent;
 		goto out_valid;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 28a0a3cbd3b7..3996e6c7a728 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1526,6 +1526,7 @@ static int nfs_update_inode(struct inode *inode, stru=
ct nfs_fattr *fattr)
=20
 	save_cache_validity =3D nfsi->cache_validity;
 	nfsi->cache_validity &=3D ~(NFS_INO_INVALID_ATTR
+			| NFS_INO_INVALID_LABEL
 			| NFS_INO_INVALID_ATIME
 			| NFS_INO_REVAL_FORCED
 			| NFS_INO_REVAL_PAGECACHE);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 0ae5807480f4..c282ce3e5349 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -218,6 +218,7 @@ struct nfs_inode {
 #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
 #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
+#define NFS_INO_DID_FLUSH	(11)
=20
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {

--Sig_/nTreoQafEXacVzFZ2o/Bjiz
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUvL4lTnsnt1WYoG5AQIUSQ//e8ZgFd0hvv/RfEiV312RyjlX0XVpIMsF
TvPIfIz8uQApn7YtvImGgUB8N8x2wnZrgZzAW5TdRtFQ4K+7m3QgI7HWfy0lRx8k
FDILKcGo9bXm5HqYWZ0yhlBRKqI0DnXuu48tjoxrqTMzgSbsCe4apNumziQJ0Ayt
QX7+rQ/7x0py13IpwT2i6Yi6WMpSTWmbt2rhzpNsxkM4kdZLtmVEKr/UfA/327k9
dC+g5H7L7tXvnbTPCGeNyEVlQQQN2O2Dr068fAA0pjWDR16Fu487FZauT/8WmEWa
33kXX+jgiKrN7ShwuGavUvEarzljo+TRZMvevs5j7dFtZnQIeTMyjNm3L/azaKuL
gDZb4Pv7Zog09IcST15k29hUHgB7DxJ+17G2twpcYkBc15G9uEyCxCbGgwxohbzb
41uB4x8X143wS3LC3madUR/l5GYIvhsy2h/bvSpOTvUXEZze4yp+IGAQ2gogDWKQ
y08pwPqAhmu9AcSaEiAfPU/KGeKHxCTmOFngOhNGyBBOMPw8tI5gDrifzHJkAodl
2JGx7pHufPfjTyiR8t0gOjh8pZYhoYWVMQ/+INbYFBO4SfKe2ZnBTtTOVY7jxvrV
z0la+2LG+00mpw6PVZW9bbCCSxNLZk/aVFStvIDdD38aw+TC00vofImex5P01Cb0
0TithjDuK/Y=
=sxoC
-----END PGP SIGNATURE-----

--Sig_/nTreoQafEXacVzFZ2o/Bjiz--
