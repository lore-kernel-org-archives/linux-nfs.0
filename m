Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934331Ab2FEOE5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jun 2012 10:04:57 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] NFSv4: Fix an Oops in the open recovery code
Date: Tue,  5 Jun 2012 10:04:42 -0400
Message-Id: <1338905083-19559-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The open recovery code does not need to request a new value for the
mdsthreshold, and so does not allocate a struct nfs4_threshold.
The problem is that encode_getfattr_open() will still request an
mdsthreshold, and so we end up Oopsing in decode_attr_mdsthreshold.

This patch fixes encode_getfattr_open so that it doesn't request an
mdsthreshold when the caller isn't asking for one. It also fixes
decode_attr_mdsthreshold so that it errors if the server returns
an mdsthreshold that we didn't ask for (instead of Oopsing).

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4_fs.h        |    2 +-
 fs/nfs/nfs4proc.c       |   22 +++++++++++++++++++++-
 fs/nfs/nfs4xdr.c        |   12 ++++++++----
 include/linux/nfs_xdr.h |    1 +
 4 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c6827f93..cc5900a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -295,7 +295,7 @@ is_ds_client(struct nfs_client *clp)
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 
-extern const u32 nfs4_fattr_bitmap[2];
+extern const u32 nfs4_fattr_bitmap[3];
 extern const u32 nfs4_statfs_bitmap[2];
 extern const u32 nfs4_pathconf_bitmap[2];
 extern const u32 nfs4_fsinfo_bitmap[3];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d48dbef..ad15155 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -116,7 +116,7 @@ static int nfs4_map_errors(int err)
 /*
  * This is our standard bitmap for GETATTR requests.
  */
-const u32 nfs4_fattr_bitmap[2] = {
+const u32 nfs4_fattr_bitmap[3] = {
 	FATTR4_WORD0_TYPE
 	| FATTR4_WORD0_CHANGE
 	| FATTR4_WORD0_SIZE
@@ -133,6 +133,24 @@ const u32 nfs4_fattr_bitmap[2] = {
 	| FATTR4_WORD1_TIME_MODIFY
 };
 
+static const u32 nfs4_pnfs_open_bitmap[3] = {
+	FATTR4_WORD0_TYPE
+	| FATTR4_WORD0_CHANGE
+	| FATTR4_WORD0_SIZE
+	| FATTR4_WORD0_FSID
+	| FATTR4_WORD0_FILEID,
+	FATTR4_WORD1_MODE
+	| FATTR4_WORD1_NUMLINKS
+	| FATTR4_WORD1_OWNER
+	| FATTR4_WORD1_OWNER_GROUP
+	| FATTR4_WORD1_RAWDEV
+	| FATTR4_WORD1_SPACE_USED
+	| FATTR4_WORD1_TIME_ACCESS
+	| FATTR4_WORD1_TIME_METADATA
+	| FATTR4_WORD1_TIME_MODIFY,
+	FATTR4_WORD2_MDSTHRESHOLD
+};
+
 const u32 nfs4_statfs_bitmap[2] = {
 	FATTR4_WORD0_FILES_AVAIL
 	| FATTR4_WORD0_FILES_FREE
@@ -844,6 +862,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
+	p->o_arg.open_bitmap = &nfs4_fattr_bitmap[0];
 	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
 	if (attrs != NULL && attrs->ia_valid != 0) {
 		__be32 verf[2];
@@ -1820,6 +1839,7 @@ static int _nfs4_do_open(struct inode *dir,
 		opendata->f_attr.mdsthreshold = pnfs_mdsthreshold_alloc();
 		if (!opendata->f_attr.mdsthreshold)
 			goto err_opendata_put;
+		opendata->o_arg.open_bitmap = &nfs4_pnfs_open_bitmap[0];
 	}
 	if (dentry->d_inode != NULL)
 		opendata->state = nfs4_get_open_state(dentry->d_inode, sp);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ee4a74d..9ca1428 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1198,12 +1198,13 @@ static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct c
 }
 
 static void encode_getfattr_open(struct xdr_stream *xdr, const u32 *bitmask,
+				 const u32 *open_bitmap,
 				 struct compound_hdr *hdr)
 {
 	encode_getattr_three(xdr,
-			     bitmask[0] & nfs4_fattr_bitmap[0],
-			     bitmask[1] & nfs4_fattr_bitmap[1],
-			     bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD,
+			     bitmask[0] & open_bitmap[0],
+			     bitmask[1] & open_bitmap[1],
+			     bitmask[2] & open_bitmap[2],
 			     hdr);
 }
 
@@ -2221,7 +2222,7 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
 	encode_getfh(xdr, &hdr);
-	encode_getfattr_open(xdr, args->bitmask, &hdr);
+	encode_getfattr_open(xdr, args->bitmask, args->open_bitmap, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -4360,6 +4361,9 @@ static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
 	if (unlikely(bitmap[2] & (FATTR4_WORD2_MDSTHRESHOLD - 1U)))
 		return -EIO;
 	if (likely(bitmap[2] & FATTR4_WORD2_MDSTHRESHOLD)) {
+		/* Did the server return an unrequested attribute? */
+		if (unlikely(res == NULL))
+			return -EREMOTEIO;
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
 			goto out_overflow;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index d1a7bf5..7519bae 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -348,6 +348,7 @@ struct nfs_openargs {
 	const struct qstr *	name;
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
+	const u32 *		open_bitmap;
 	__u32			claim;
 	struct nfs4_sequence_args	seq_args;
 };
-- 
1.7.10.2

