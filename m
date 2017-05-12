Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:58631 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932811AbdELQRU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:20 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/33] nfs: fix encoder callback prototypes
Date: Fri, 12 May 2017 18:16:32 +0200
Message-Id: <20170512161701.22468-5-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_encode callbacks with the proper prototype instead of
casting to kxdreproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/mount_clnt.c |  10 +--
 fs/nfs/nfs2xdr.c    |  49 ++++++++++----
 fs/nfs/nfs3xdr.c    |  83 ++++++++++++++++-------
 fs/nfs/nfs42xdr.c   |  34 ++++++----
 fs/nfs/nfs4xdr.c    | 188 +++++++++++++++++++++++++++++++++-------------------
 5 files changed, 242 insertions(+), 122 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 09b190015df4..f435d640d552 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -304,7 +304,7 @@ static void encode_mntdirpath(struct xdr_stream *xdr, const char *pathname)
 }
 
 static void mnt_xdr_enc_dirpath(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const char *dirpath)
+				const void *dirpath)
 {
 	encode_mntdirpath(xdr, dirpath);
 }
@@ -467,7 +467,7 @@ static int mnt_xdr_dec_mountres3(struct rpc_rqst *req,
 static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
+		.p_encode	= mnt_xdr_enc_dirpath,
 		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres_sz,
@@ -476,7 +476,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 	},
 	[MOUNTPROC_UMNT] = {
 		.p_proc		= MOUNTPROC_UMNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
+		.p_encode	= mnt_xdr_enc_dirpath,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_statidx	= MOUNTPROC_UMNT,
 		.p_name		= "UMOUNT",
@@ -486,7 +486,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
+		.p_encode	= mnt_xdr_enc_dirpath,
 		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres3,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres3_sz,
@@ -495,7 +495,7 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	},
 	[MOUNTPROC3_UMNT] = {
 		.p_proc		= MOUNTPROC3_UMNT,
-		.p_encode	= (kxdreproc_t)mnt_xdr_enc_dirpath,
+		.p_encode	= mnt_xdr_enc_dirpath,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_statidx	= MOUNTPROC3_UMNT,
 		.p_name		= "UMOUNT",
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index b4e03ed8599d..8ecd58597228 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -568,8 +568,10 @@ static int decode_diropres(struct xdr_stream *xdr, struct nfs_diropok *result)
 
 static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 const struct nfs_fh *fh)
+				 const void *data)
 {
+	const struct nfs_fh *fh = data;
+
 	encode_fhandle(xdr, fh);
 }
 
@@ -583,23 +585,29 @@ static void nfs2_xdr_enc_fhandle(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_sattrargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_sattrargs *args)
+				   const void *data)
 {
+	const struct nfs_sattrargs *args = data;
+
 	encode_fhandle(xdr, args->fh);
 	encode_sattr(xdr, args->sattr);
 }
 
 static void nfs2_xdr_enc_diropargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_diropargs *args)
+				   const void *data)
 {
+	const struct nfs_diropargs *args = data;
+
 	encode_diropargs(xdr, args->fh, args->name, args->len);
 }
 
 static void nfs2_xdr_enc_readlinkargs(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs_readlinkargs *args)
+				      const void *data)
 {
+	const struct nfs_readlinkargs *args = data;
+
 	encode_fhandle(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS_readlinkres_sz);
@@ -632,8 +640,10 @@ static void encode_readargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_readargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nfs_pgio_args *args)
+				  const void *data)
 {
+	const struct nfs_pgio_args *args = data;
+
 	encode_readargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS_readres_sz);
@@ -672,8 +682,10 @@ static void encode_writeargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_pgio_args *args)
+				   const void *data)
 {
+	const struct nfs_pgio_args *args = data;
+
 	encode_writeargs(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
 }
@@ -688,16 +700,20 @@ static void nfs2_xdr_enc_writeargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_createargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_createargs *args)
+				    const void *data)
 {
+	const struct nfs_createargs *args = data;
+
 	encode_diropargs(xdr, args->fh, args->name, args->len);
 	encode_sattr(xdr, args->sattr);
 }
 
 static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_removeargs *args)
+				    const void *data)
 {
+	const struct nfs_removeargs *args = data;
+
 	encode_diropargs(xdr, args->fh, args->name.name, args->name.len);
 }
 
@@ -711,8 +727,9 @@ static void nfs2_xdr_enc_removeargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_renameargs *args)
+				    const void *data)
 {
+	const struct nfs_renameargs *args = data;
 	const struct qstr *old = args->old_name;
 	const struct qstr *new = args->new_name;
 
@@ -730,8 +747,10 @@ static void nfs2_xdr_enc_renameargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  const struct nfs_linkargs *args)
+				  const void *data)
 {
+	const struct nfs_linkargs *args = data;
+
 	encode_fhandle(xdr, args->fromfh);
 	encode_diropargs(xdr, args->tofh, args->toname, args->tolen);
 }
@@ -747,8 +766,10 @@ static void nfs2_xdr_enc_linkargs(struct rpc_rqst *req,
  */
 static void nfs2_xdr_enc_symlinkargs(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_symlinkargs *args)
+				     const void *data)
 {
+	const struct nfs_symlinkargs *args = data;
+
 	encode_diropargs(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_path(xdr, args->pages, args->pathlen);
 	encode_sattr(xdr, args->sattr);
@@ -777,8 +798,10 @@ static void encode_readdirargs(struct xdr_stream *xdr,
 
 static void nfs2_xdr_enc_readdirargs(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_readdirargs *args)
+				     const void *data)
 {
+	const struct nfs_readdirargs *args = data;
+
 	encode_readdirargs(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 					args->count, NFS_readdirres_sz);
@@ -1118,7 +1141,7 @@ static int nfs_stat_to_errno(enum nfs_stat status)
 #define PROC(proc, argtype, restype, timer)				\
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
-	.p_encode   =  (kxdreproc_t)nfs2_xdr_enc_##argtype,		\
+	.p_encode   =  nfs2_xdr_enc_##argtype,				\
 	.p_decode   =  (kxdrdproc_t)nfs2_xdr_dec_##restype,		\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 267126d32ec0..773150678633 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -846,8 +846,10 @@ static void encode_diropargs3(struct xdr_stream *xdr, const struct nfs_fh *fh,
  */
 static void nfs3_xdr_enc_getattr3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs_fh *fh)
+				      const void *data)
 {
+	const struct nfs_fh *fh = data;
+
 	encode_nfs_fh3(xdr, fh);
 }
 
@@ -884,8 +886,9 @@ static void encode_sattrguard3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs3_sattrargs *args)
+				      const void *data)
 {
+	const struct nfs3_sattrargs *args = data;
 	encode_nfs_fh3(xdr, args->fh);
 	encode_sattr3(xdr, args->sattr);
 	encode_sattrguard3(xdr, args);
@@ -900,8 +903,10 @@ static void nfs3_xdr_enc_setattr3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_lookup3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_diropargs *args)
+				     const void *data)
 {
+	const struct nfs3_diropargs *args = data;
+
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 }
 
@@ -922,8 +927,10 @@ static void encode_access3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_accessargs *args)
+				     const void *data)
 {
+	const struct nfs3_accessargs *args = data;
+
 	encode_access3args(xdr, args);
 }
 
@@ -936,8 +943,10 @@ static void nfs3_xdr_enc_access3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_readlink3args(struct rpc_rqst *req,
 				       struct xdr_stream *xdr,
-				       const struct nfs3_readlinkargs *args)
+				       const void *data)
 {
+	const struct nfs3_readlinkargs *args = data;
+
 	encode_nfs_fh3(xdr, args->fh);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->pglen, NFS3_readlinkres_sz);
@@ -966,8 +975,10 @@ static void encode_read3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_read3args(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs_pgio_args *args)
+				   const void *data)
 {
+	const struct nfs_pgio_args *args = data;
+
 	encode_read3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, args->pgbase,
 					args->count, NFS3_readres_sz);
@@ -1008,8 +1019,10 @@ static void encode_write3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_write3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs_pgio_args *args)
+				    const void *data)
 {
+	const struct nfs_pgio_args *args = data;
+
 	encode_write3args(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
 }
@@ -1055,8 +1068,10 @@ static void encode_createhow3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_createargs *args)
+				     const void *data)
 {
+	const struct nfs3_createargs *args = data;
+
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_createhow3(xdr, args);
 }
@@ -1071,8 +1086,10 @@ static void nfs3_xdr_enc_create3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs3_mkdirargs *args)
+				    const void *data)
 {
+	const struct nfs3_mkdirargs *args = data;
+
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_sattr3(xdr, args->sattr);
 }
@@ -1091,16 +1108,20 @@ static void nfs3_xdr_enc_mkdir3args(struct rpc_rqst *req,
  *	};
  */
 static void encode_symlinkdata3(struct xdr_stream *xdr,
-				const struct nfs3_symlinkargs *args)
+				const void *data)
 {
+	const struct nfs3_symlinkargs *args = data;
+
 	encode_sattr3(xdr, args->sattr);
 	encode_nfspath3(xdr, args->pages, args->pathlen);
 }
 
 static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs3_symlinkargs *args)
+				      const void *data)
 {
+	const struct nfs3_symlinkargs *args = data;
+
 	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_symlinkdata3(xdr, args);
 	xdr->buf->flags |= XDRBUF_WRITE;
@@ -1160,8 +1181,10 @@ static void encode_mknoddata3(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    const struct nfs3_mknodargs *args)
+				    const void *data)
 {
+	const struct nfs3_mknodargs *args = data;
+
 	encode_diropargs3(xdr, args->fh, args->name, args->len);
 	encode_mknoddata3(xdr, args);
 }
@@ -1175,8 +1198,10 @@ static void nfs3_xdr_enc_mknod3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_removeargs *args)
+				     const void *data)
 {
+	const struct nfs_removeargs *args = data;
+
 	encode_diropargs3(xdr, args->fh, args->name.name, args->name.len);
 }
 
@@ -1190,8 +1215,9 @@ static void nfs3_xdr_enc_remove3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_renameargs *args)
+				     const void *data)
 {
+	const struct nfs_renameargs *args = data;
 	const struct qstr *old = args->old_name;
 	const struct qstr *new = args->new_name;
 
@@ -1209,8 +1235,10 @@ static void nfs3_xdr_enc_rename3args(struct rpc_rqst *req,
  */
 static void nfs3_xdr_enc_link3args(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   const struct nfs3_linkargs *args)
+				   const void *data)
 {
+	const struct nfs3_linkargs *args = data;
+
 	encode_nfs_fh3(xdr, args->fromfh);
 	encode_diropargs3(xdr, args->tofh, args->toname, args->tolen);
 }
@@ -1240,8 +1268,10 @@ static void encode_readdir3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_readdir3args(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      const struct nfs3_readdirargs *args)
+				      const void *data)
 {
+	const struct nfs3_readdirargs *args = data;
+
 	encode_readdir3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
@@ -1280,8 +1310,10 @@ static void encode_readdirplus3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_readdirplus3args(struct rpc_rqst *req,
 					  struct xdr_stream *xdr,
-					  const struct nfs3_readdirargs *args)
+					  const void *data)
 {
+	const struct nfs3_readdirargs *args = data;
+
 	encode_readdirplus3args(xdr, args);
 	prepare_reply_buffer(req, args->pages, 0,
 				args->count, NFS3_readdirres_sz);
@@ -1310,8 +1342,10 @@ static void encode_commit3args(struct xdr_stream *xdr,
 
 static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs_commitargs *args)
+				     const void *data)
 {
+	const struct nfs_commitargs *args = data;
+
 	encode_commit3args(xdr, args);
 }
 
@@ -1319,8 +1353,10 @@ static void nfs3_xdr_enc_commit3args(struct rpc_rqst *req,
 
 static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_getaclargs *args)
+				     const void *data)
 {
+	const struct nfs3_getaclargs *args = data;
+
 	encode_nfs_fh3(xdr, args->fh);
 	encode_uint32(xdr, args->mask);
 	if (args->mask & (NFS_ACL | NFS_DFACL))
@@ -1331,8 +1367,9 @@ static void nfs3_xdr_enc_getacl3args(struct rpc_rqst *req,
 
 static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs3_setaclargs *args)
+				     const void *data)
 {
+	const struct nfs3_setaclargs *args = data;
 	unsigned int base;
 	int error;
 
@@ -2495,7 +2532,7 @@ static int nfs3_stat_to_errno(enum nfs_stat status)
 #define PROC(proc, argtype, restype, timer)				\
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
-	.p_encode    = (kxdreproc_t)nfs3_xdr_enc_##argtype##3args,	\
+	.p_encode    = nfs3_xdr_enc_##argtype##3args,			\
 	.p_decode    = (kxdrdproc_t)nfs3_xdr_dec_##restype##3res,	\
 	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##res_sz,				\
@@ -2538,7 +2575,7 @@ const struct rpc_version nfs_version3 = {
 static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
-		.p_encode = (kxdreproc_t)nfs3_xdr_enc_getacl3args,
+		.p_encode = nfs3_xdr_enc_getacl3args,
 		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_getacl3res,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
@@ -2547,7 +2584,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
-		.p_encode = (kxdreproc_t)nfs3_xdr_enc_setacl3args,
+		.p_encode = nfs3_xdr_enc_setacl3args,
 		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_setacl3res,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 528362f69cc1..0a1bd60a1f8e 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -112,7 +112,7 @@
 					 decode_getattr_maxsz)
 
 static void encode_fallocate(struct xdr_stream *xdr,
-			     struct nfs42_falloc_args *args)
+			     const struct nfs42_falloc_args *args)
 {
 	encode_nfs4_stateid(xdr, &args->falloc_stateid);
 	encode_uint64(xdr, args->falloc_offset);
@@ -120,7 +120,7 @@ static void encode_fallocate(struct xdr_stream *xdr,
 }
 
 static void encode_allocate(struct xdr_stream *xdr,
-			    struct nfs42_falloc_args *args,
+			    const struct nfs42_falloc_args *args,
 			    struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_ALLOCATE, decode_allocate_maxsz, hdr);
@@ -128,7 +128,7 @@ static void encode_allocate(struct xdr_stream *xdr,
 }
 
 static void encode_copy(struct xdr_stream *xdr,
-			struct nfs42_copy_args *args,
+			const struct nfs42_copy_args *args,
 			struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_COPY, decode_copy_maxsz, hdr);
@@ -145,7 +145,7 @@ static void encode_copy(struct xdr_stream *xdr,
 }
 
 static void encode_deallocate(struct xdr_stream *xdr,
-			      struct nfs42_falloc_args *args,
+			      const struct nfs42_falloc_args *args,
 			      struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_DEALLOCATE, decode_deallocate_maxsz, hdr);
@@ -153,7 +153,7 @@ static void encode_deallocate(struct xdr_stream *xdr,
 }
 
 static void encode_seek(struct xdr_stream *xdr,
-			struct nfs42_seek_args *args,
+			const struct nfs42_seek_args *args,
 			struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_SEEK, decode_seek_maxsz, hdr);
@@ -163,7 +163,7 @@ static void encode_seek(struct xdr_stream *xdr,
 }
 
 static void encode_layoutstats(struct xdr_stream *xdr,
-			       struct nfs42_layoutstat_args *args,
+			       const struct nfs42_layoutstat_args *args,
 			       struct nfs42_layoutstat_devinfo *devinfo,
 			       struct compound_hdr *hdr)
 {
@@ -191,7 +191,7 @@ static void encode_layoutstats(struct xdr_stream *xdr,
 }
 
 static void encode_clone(struct xdr_stream *xdr,
-			 struct nfs42_clone_args *args,
+			 const struct nfs42_clone_args *args,
 			 struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -210,8 +210,9 @@ static void encode_clone(struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
 				  struct xdr_stream *xdr,
-				  struct nfs42_falloc_args *args)
+				  const void *data)
 {
+	const struct nfs42_falloc_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -225,7 +226,7 @@ static void nfs4_xdr_enc_allocate(struct rpc_rqst *req,
 }
 
 static void encode_copy_commit(struct xdr_stream *xdr,
-			  struct nfs42_copy_args *args,
+			  const struct nfs42_copy_args *args,
 			  struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -241,8 +242,9 @@ static void encode_copy_commit(struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
 			      struct xdr_stream *xdr,
-			      struct nfs42_copy_args *args)
+			      const void *data)
 {
+	const struct nfs42_copy_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -262,8 +264,9 @@ static void nfs4_xdr_enc_copy(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs42_falloc_args *args)
+				    const void *data)
 {
+	const struct nfs42_falloc_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -281,8 +284,9 @@ static void nfs4_xdr_enc_deallocate(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
 			      struct xdr_stream *xdr,
-			      struct nfs42_seek_args *args)
+			      const void *data)
 {
+	const struct nfs42_seek_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -299,8 +303,9 @@ static void nfs4_xdr_enc_seek(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutstats(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs42_layoutstat_args *args)
+				     const void *data)
 {
+	const struct nfs42_layoutstat_args *args = data;
 	int i;
 
 	struct compound_hdr hdr = {
@@ -321,8 +326,9 @@ static void nfs4_xdr_enc_layoutstats(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_clone(struct rpc_rqst *req,
 			       struct xdr_stream *xdr,
-			       struct nfs42_clone_args *args)
+			       const void *data)
 {
+	const struct nfs42_clone_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3aebfdc82b30..c5036ef770f9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1651,7 +1651,8 @@ encode_restorefh(struct xdr_stream *xdr, struct compound_hdr *hdr)
 }
 
 static void
-encode_setacl(struct xdr_stream *xdr, struct nfs_setaclargs *arg, struct compound_hdr *hdr)
+encode_setacl(struct xdr_stream *xdr, const struct nfs_setaclargs *arg,
+		struct compound_hdr *hdr)
 {
 	__be32 *p;
 
@@ -1735,7 +1736,7 @@ static void encode_secinfo(struct xdr_stream *xdr, const struct qstr *name, stru
 #if defined(CONFIG_NFS_V4_1)
 /* NFSv4.1 operations */
 static void encode_bind_conn_to_session(struct xdr_stream *xdr,
-				   struct nfs41_bind_conn_to_session_args *args,
+				   const struct nfs41_bind_conn_to_session_args *args,
 				   struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1748,7 +1749,7 @@ static void encode_bind_conn_to_session(struct xdr_stream *xdr,
 	*p = (args->use_conn_in_rdma_mode) ? cpu_to_be32(1) : cpu_to_be32(0);
 }
 
-static void encode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
+static void encode_op_map(struct xdr_stream *xdr, const struct nfs4_op_map *op_map)
 {
 	unsigned int i;
 	encode_uint32(xdr, NFS4_OP_MAP_NUM_WORDS);
@@ -1757,7 +1758,7 @@ static void encode_op_map(struct xdr_stream *xdr, struct nfs4_op_map *op_map)
 }
 
 static void encode_exchange_id(struct xdr_stream *xdr,
-			       struct nfs41_exchange_id_args *args,
+			       const struct nfs41_exchange_id_args *args,
 			       struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1809,7 +1810,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 }
 
 static void encode_create_session(struct xdr_stream *xdr,
-				  struct nfs41_create_session_args *args,
+				  const struct nfs41_create_session_args *args,
 				  struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -1862,7 +1863,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 }
 
 static void encode_destroy_session(struct xdr_stream *xdr,
-				   struct nfs4_session *session,
+				   const struct nfs4_session *session,
 				   struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_DESTROY_SESSION, decode_destroy_session_maxsz, hdr);
@@ -1878,7 +1879,7 @@ static void encode_destroy_clientid(struct xdr_stream *xdr,
 }
 
 static void encode_reclaim_complete(struct xdr_stream *xdr,
-				    struct nfs41_reclaim_complete_args *args,
+				    const struct nfs41_reclaim_complete_args *args,
 				    struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_RECLAIM_COMPLETE, decode_reclaim_complete_maxsz, hdr);
@@ -1974,7 +1975,7 @@ encode_layoutget(struct xdr_stream *xdr,
 static int
 encode_layoutcommit(struct xdr_stream *xdr,
 		    struct inode *inode,
-		    struct nfs4_layoutcommit_args *args,
+		    const struct nfs4_layoutcommit_args *args,
 		    struct compound_hdr *hdr)
 {
 	__be32 *p;
@@ -2044,7 +2045,7 @@ encode_secinfo_no_name(struct xdr_stream *xdr,
 }
 
 static void encode_test_stateid(struct xdr_stream *xdr,
-				struct nfs41_test_stateid_args *args,
+				const struct nfs41_test_stateid_args *args,
 				struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_TEST_STATEID, decode_test_stateid_maxsz, hdr);
@@ -2053,7 +2054,7 @@ static void encode_test_stateid(struct xdr_stream *xdr,
 }
 
 static void encode_free_stateid(struct xdr_stream *xdr,
-				struct nfs41_free_stateid_args *args,
+				const struct nfs41_free_stateid_args *args,
 				struct compound_hdr *hdr)
 {
 	encode_op_hdr(xdr, OP_FREE_STATEID, decode_free_stateid_maxsz, hdr);
@@ -2086,8 +2087,9 @@ static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
  * Encode an ACCESS request
  */
 static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_accessargs *args)
+				const void *data)
 {
+	const struct nfs4_accessargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2104,8 +2106,9 @@ static void nfs4_xdr_enc_access(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode LOOKUP request
  */
 static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_lookup_arg *args)
+				const void *data)
 {
+	const struct nfs4_lookup_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2124,8 +2127,9 @@ static void nfs4_xdr_enc_lookup(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs4_lookup_root_arg *args)
+				     const void *data)
 {
+	const struct nfs4_lookup_root_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2142,8 +2146,9 @@ static void nfs4_xdr_enc_lookup_root(struct rpc_rqst *req,
  * Encode REMOVE request
  */
 static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs_removeargs *args)
+				const void *data)
 {
+	const struct nfs_removeargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2159,8 +2164,9 @@ static void nfs4_xdr_enc_remove(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode RENAME request
  */
 static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs_renameargs *args)
+				const void *data)
 {
+	const struct nfs_renameargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2178,8 +2184,9 @@ static void nfs4_xdr_enc_rename(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode LINK request
  */
 static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
-			     const struct nfs4_link_arg *args)
+			      const void *data)
 {
+	const struct nfs4_link_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2199,8 +2206,9 @@ static void nfs4_xdr_enc_link(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode CREATE request
  */
 static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_create_arg *args)
+				const void *data)
 {
+	const struct nfs4_create_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2218,8 +2226,10 @@ static void nfs4_xdr_enc_create(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode SYMLINK request
  */
 static void nfs4_xdr_enc_symlink(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 const struct nfs4_create_arg *args)
+				 const void *data)
 {
+	const struct nfs4_create_arg *args = data;
+
 	nfs4_xdr_enc_create(req, xdr, args);
 }
 
@@ -2227,8 +2237,9 @@ static void nfs4_xdr_enc_symlink(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode GETATTR request
  */
 static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 const struct nfs4_getattr_arg *args)
+				 const void *data)
 {
+	const struct nfs4_getattr_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2244,8 +2255,9 @@ static void nfs4_xdr_enc_getattr(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a CLOSE request
  */
 static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_closeargs *args)
+			       const void *data)
 {
+	const struct nfs_closeargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2265,8 +2277,9 @@ static void nfs4_xdr_enc_close(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode an OPEN request
  */
 static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_openargs *args)
+			      const void *data)
 {
+	const struct nfs_openargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2287,8 +2300,9 @@ static void nfs4_xdr_enc_open(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs_open_confirmargs *args)
+				      const void *data)
 {
+	const struct nfs_open_confirmargs *args = data;
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
@@ -2304,8 +2318,9 @@ static void nfs4_xdr_enc_open_confirm(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs_openargs *args)
+				     const void *data)
 {
+	const struct nfs_openargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2325,8 +2340,9 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs_closeargs *args)
+					const void *data)
 {
+	const struct nfs_closeargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2344,8 +2360,9 @@ static void nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req,
  * Encode a LOCK request
  */
 static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_lock_args *args)
+			      const void *data)
 {
+	const struct nfs_lock_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2361,8 +2378,9 @@ static void nfs4_xdr_enc_lock(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a LOCKT request
  */
 static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_lockt_args *args)
+			       const void *data)
 {
+	const struct nfs_lockt_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2378,8 +2396,9 @@ static void nfs4_xdr_enc_lockt(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a LOCKU request
  */
 static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_locku_args *args)
+			       const void *data)
 {
+	const struct nfs_locku_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2393,8 +2412,9 @@ static void nfs4_xdr_enc_locku(struct rpc_rqst *req, struct xdr_stream *xdr,
 
 static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
 					   struct xdr_stream *xdr,
-					struct nfs_release_lockowner_args *args)
+					   const void *data)
 {
+	const struct nfs_release_lockowner_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = 0,
 	};
@@ -2408,8 +2428,9 @@ static void nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req,
  * Encode a READLINK request
  */
 static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  const struct nfs4_readlink *args)
+				  const void *data)
 {
+	const struct nfs4_readlink *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2428,8 +2449,9 @@ static void nfs4_xdr_enc_readlink(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a READDIR request
  */
 static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 const struct nfs4_readdir_arg *args)
+				 const void *data)
 {
+	const struct nfs4_readdir_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2451,8 +2473,9 @@ static void nfs4_xdr_enc_readdir(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a READ request
  */
 static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
-			      struct nfs_pgio_args *args)
+			      const void *data)
 {
+	const struct nfs_pgio_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2472,8 +2495,9 @@ static void nfs4_xdr_enc_read(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode an SETATTR request
  */
 static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_setattrargs *args)
+				 const void *data)
 {
+	const struct nfs_setattrargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2490,8 +2514,9 @@ static void nfs4_xdr_enc_setattr(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a GETACL request
  */
 static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_getaclargs *args)
+				const void *data)
 {
+	const struct nfs_getaclargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2513,8 +2538,9 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Encode a WRITE request
  */
 static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_pgio_args *args)
+			       const void *data)
 {
+	const struct nfs_pgio_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2533,8 +2559,9 @@ static void nfs4_xdr_enc_write(struct rpc_rqst *req, struct xdr_stream *xdr,
  *  a COMMIT request
  */
 static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_commitargs *args)
+				const void *data)
 {
+	const struct nfs_commitargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2550,8 +2577,9 @@ static void nfs4_xdr_enc_commit(struct rpc_rqst *req, struct xdr_stream *xdr,
  * FSINFO request
  */
 static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs4_fsinfo_arg *args)
+				const void *data)
 {
+	const struct nfs4_fsinfo_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2567,8 +2595,9 @@ static void nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
  * a PATHCONF request
  */
 static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  const struct nfs4_pathconf_arg *args)
+				  const void *data)
 {
+	const struct nfs4_pathconf_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2585,8 +2614,9 @@ static void nfs4_xdr_enc_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
  * a STATFS request
  */
 static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
-				const struct nfs4_statfs_arg *args)
+				const void *data)
 {
+	const struct nfs4_statfs_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2604,8 +2634,9 @@ static void nfs4_xdr_enc_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs4_server_caps_arg *args)
+				     const void *data)
 {
+	const struct nfs4_server_caps_arg *args = data;
 	const u32 *bitmask = args->bitmask;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
@@ -2622,8 +2653,10 @@ static void nfs4_xdr_enc_server_caps(struct rpc_rqst *req,
  * a RENEW request
  */
 static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs_client *clp)
+			       const void *data)
+
 {
+	const struct nfs_client *clp = data;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
@@ -2638,8 +2671,9 @@ static void nfs4_xdr_enc_renew(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs4_setclientid *sc)
+				     const void *data)
 {
+	const struct nfs4_setclientid *sc = data;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
@@ -2654,8 +2688,9 @@ static void nfs4_xdr_enc_setclientid(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
 					     struct xdr_stream *xdr,
-					     struct nfs4_setclientid_res *arg)
+					     const void *data)
 {
+	const struct nfs4_setclientid_res *arg = data;
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
@@ -2670,8 +2705,9 @@ static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     const struct nfs4_delegreturnargs *args)
+				     const void *data)
 {
+	const struct nfs4_delegreturnargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2692,8 +2728,9 @@ static void nfs4_xdr_enc_delegreturn(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_fs_locations_arg *args)
+				      const void *data)
 {
+	const struct nfs4_fs_locations_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2715,8 +2752,8 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 	}
 
 	/* Set up reply kvec to capture returned fs_locations array. */
-	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
-			0, PAGE_SIZE);
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
+			 (struct page **)&args->page, 0, PAGE_SIZE);
 	encode_nops(&hdr);
 }
 
@@ -2725,8 +2762,9 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nfs4_secinfo_arg *args)
+				const void *data)
 {
+	const struct nfs4_secinfo_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2743,8 +2781,9 @@ static void nfs4_xdr_enc_secinfo(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_fsid_present_arg *args)
+				      const void *data)
 {
+	const struct nfs4_fsid_present_arg *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2764,8 +2803,9 @@ static void nfs4_xdr_enc_fsid_present(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct nfs41_bind_conn_to_session_args *args)
+				const void *data)
 {
+	const struct nfs41_bind_conn_to_session_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
@@ -2780,8 +2820,9 @@ static void nfs4_xdr_enc_bind_conn_to_session(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs41_exchange_id_args *args)
+				     const void *data)
 {
+	const struct nfs41_exchange_id_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
@@ -2796,8 +2837,9 @@ static void nfs4_xdr_enc_exchange_id(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs41_create_session_args *args)
+					const void *data)
 {
+	const struct nfs41_create_session_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = args->client->cl_mvops->minor_version,
 	};
@@ -2812,8 +2854,9 @@ static void nfs4_xdr_enc_create_session(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
 					 struct xdr_stream *xdr,
-					 struct nfs4_session *session)
+					 const void *data)
 {
+	const struct nfs4_session *session = data;
 	struct compound_hdr hdr = {
 		.minorversion = session->clp->cl_mvops->minor_version,
 	};
@@ -2828,8 +2871,9 @@ static void nfs4_xdr_enc_destroy_session(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
 					 struct xdr_stream *xdr,
-					 struct nfs_client *clp)
+					 const void *data)
 {
+	const struct nfs_client *clp = data;
 	struct compound_hdr hdr = {
 		.minorversion = clp->cl_mvops->minor_version,
 	};
@@ -2843,8 +2887,9 @@ static void nfs4_xdr_enc_destroy_clientid(struct rpc_rqst *req,
  * a SEQUENCE request
  */
 static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs4_sequence_args *args)
+				  const void *data)
 {
+	const struct nfs4_sequence_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(args),
 	};
@@ -2859,8 +2904,9 @@ static void nfs4_xdr_enc_sequence(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs4_get_lease_time_args *args)
+					const void *data)
 {
+	const struct nfs4_get_lease_time_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
 	};
@@ -2878,8 +2924,9 @@ static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
 					  struct xdr_stream *xdr,
-				struct nfs41_reclaim_complete_args *args)
+					  const void *data)
 {
+	const struct nfs41_reclaim_complete_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args)
 	};
@@ -2895,8 +2942,9 @@ static void nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
 				       struct xdr_stream *xdr,
-				       struct nfs4_getdeviceinfo_args *args)
+				       const void *data)
 {
+	const struct nfs4_getdeviceinfo_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2919,8 +2967,9 @@ static void nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs4_layoutget_args *args)
+				   const void *data)
 {
+	const struct nfs4_layoutget_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2941,8 +2990,9 @@ static void nfs4_xdr_enc_layoutget(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_layoutcommit_args *args)
+				      const void *priv)
 {
+	const struct nfs4_layoutcommit_args *args = priv;
 	struct nfs4_layoutcommit_data *data =
 		container_of(args, struct nfs4_layoutcommit_data, args);
 	struct compound_hdr hdr = {
@@ -2962,8 +3012,9 @@ static void nfs4_xdr_enc_layoutcommit(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs4_layoutreturn_args *args)
+				      const void *data)
 {
+	const struct nfs4_layoutreturn_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2978,10 +3029,11 @@ static void nfs4_xdr_enc_layoutreturn(struct rpc_rqst *req,
 /*
  * Encode SECINFO_NO_NAME request
  */
-static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
+static void nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
 					struct xdr_stream *xdr,
-					struct nfs41_secinfo_no_name_args *args)
+					const void *data)
 {
+	const struct nfs41_secinfo_no_name_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -2991,7 +3043,6 @@ static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
 	encode_putrootfh(xdr, &hdr);
 	encode_secinfo_no_name(xdr, args, &hdr);
 	encode_nops(&hdr);
-	return 0;
 }
 
 /*
@@ -2999,8 +3050,9 @@ static int nfs4_xdr_enc_secinfo_no_name(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
 				      struct xdr_stream *xdr,
-				      struct nfs41_test_stateid_args *args)
+				      const void *data)
 {
+	const struct nfs41_test_stateid_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -3016,8 +3068,9 @@ static void nfs4_xdr_enc_test_stateid(struct rpc_rqst *req,
  */
 static void nfs4_xdr_enc_free_stateid(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs41_free_stateid_args *args)
+				     const void *data)
 {
+	const struct nfs41_free_stateid_args *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -6364,8 +6417,9 @@ static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Encode an SETACL request
  */
 static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_setaclargs *args)
+				const void *data)
 {
+	const struct nfs_setaclargs *args = data;
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
@@ -7484,7 +7538,7 @@ nfs4_stat_to_errno(int stat)
 #define PROC(proc, argtype, restype)				\
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
-	.p_encode = (kxdreproc_t)nfs4_xdr_##argtype,		\
+	.p_encode = nfs4_xdr_##argtype,				\
 	.p_decode = (kxdrdproc_t)nfs4_xdr_##restype,		\
 	.p_arglen = NFS4_##argtype##_sz,			\
 	.p_replen = NFS4_##restype##_sz,			\
-- 
2.11.0

