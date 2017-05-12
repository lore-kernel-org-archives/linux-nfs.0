Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:45413 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932610AbdELQRr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 12:17:47 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 12/33] nfs: fix decoder callback prototypes
Date: Fri, 12 May 2017 18:16:40 +0200
Message-Id: <20170512161701.22468-13-hch@lst.de>
In-Reply-To: <20170512161701.22468-1-hch@lst.de>
References: <20170512161701.22468-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Declare the p_decode callbacks with the proper prototype instead of
casting to kxdrdproc_t and losing all type safety.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/mount_clnt.c |  10 ++--
 fs/nfs/nfs2xdr.c    |  15 +++---
 fs/nfs/nfs3xdr.c    |  55 +++++++++++++--------
 fs/nfs/nfs42xdr.c   |  18 ++++---
 fs/nfs/nfs4xdr.c    | 137 ++++++++++++++++++++++++++++++++++------------------
 5 files changed, 151 insertions(+), 84 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index f435d640d552..806657d65074 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -357,8 +357,9 @@ static int decode_fhandle(struct xdr_stream *xdr, struct mountres *res)
 
 static int mnt_xdr_dec_mountres(struct rpc_rqst *req,
 				struct xdr_stream *xdr,
-				struct mountres *res)
+				void *data)
 {
+	struct mountres *res = data;
 	int status;
 
 	status = decode_status(xdr, res);
@@ -449,8 +450,9 @@ static int decode_auth_flavors(struct xdr_stream *xdr, struct mountres *res)
 
 static int mnt_xdr_dec_mountres3(struct rpc_rqst *req,
 				 struct xdr_stream *xdr,
-				 struct mountres *res)
+				 void *data)
 {
+	struct mountres *res = data;
 	int status;
 
 	status = decode_fhs_status(xdr, res);
@@ -468,7 +470,7 @@ static struct rpc_procinfo mnt_procedures[] = {
 	[MOUNTPROC_MNT] = {
 		.p_proc		= MOUNTPROC_MNT,
 		.p_encode	= mnt_xdr_enc_dirpath,
-		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres,
+		.p_decode	= mnt_xdr_dec_mountres,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres_sz,
 		.p_statidx	= MOUNTPROC_MNT,
@@ -487,7 +489,7 @@ static struct rpc_procinfo mnt3_procedures[] = {
 	[MOUNTPROC3_MNT] = {
 		.p_proc		= MOUNTPROC3_MNT,
 		.p_encode	= mnt_xdr_enc_dirpath,
-		.p_decode	= (kxdrdproc_t)mnt_xdr_dec_mountres3,
+		.p_decode	= mnt_xdr_dec_mountres3,
 		.p_arglen	= MNT_enc_dirpath_sz,
 		.p_replen	= MNT_dec_mountres3_sz,
 		.p_statidx	= MOUNTPROC3_MNT,
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 8ecd58597228..a299648ea321 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -832,13 +832,13 @@ static int nfs2_xdr_dec_stat(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int nfs2_xdr_dec_attrstat(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_fattr *result)
+				 void *result)
 {
 	return decode_attrstat(xdr, result, NULL);
 }
 
 static int nfs2_xdr_dec_diropres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_diropok *result)
+				 void *result)
 {
 	return decode_diropres(xdr, result);
 }
@@ -883,8 +883,9 @@ static int nfs2_xdr_dec_readlinkres(struct rpc_rqst *req,
  *	};
  */
 static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				struct nfs_pgio_res *result)
+				void *data)
 {
+	struct nfs_pgio_res *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -905,8 +906,10 @@ static int nfs2_xdr_dec_readres(struct rpc_rqst *req, struct xdr_stream *xdr,
 }
 
 static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_pgio_res *result)
+				 void *data)
 {
+	struct nfs_pgio_res *result = data;
+
 	/* All NFSv2 writes are "file sync" writes */
 	result->verf->committed = NFS_FILE_SYNC;
 	return decode_attrstat(xdr, result->fattr, &result->op_status);
@@ -1057,7 +1060,7 @@ static int decode_info(struct xdr_stream *xdr, struct nfs2_fsstat *result)
 }
 
 static int nfs2_xdr_dec_statfsres(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs2_fsstat *result)
+				  void *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -1142,7 +1145,7 @@ static int nfs_stat_to_errno(enum nfs_stat status)
 [NFSPROC_##proc] = {							\
 	.p_proc	    =  NFSPROC_##proc,					\
 	.p_encode   =  nfs2_xdr_enc_##argtype,				\
-	.p_decode   =  (kxdrdproc_t)nfs2_xdr_dec_##restype,		\
+	.p_decode   =  nfs2_xdr_dec_##restype,				\
 	.p_arglen   =  NFS_##argtype##_sz,				\
 	.p_replen   =  NFS_##restype##_sz,				\
 	.p_timer    =  timer,						\
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 773150678633..cc272eb8be3e 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1419,7 +1419,7 @@ static void nfs3_xdr_enc_setacl3args(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs_fattr *result)
+				    void *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -1456,7 +1456,7 @@ static int nfs3_xdr_dec_getattr3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs_fattr *result)
+				    void *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -1497,8 +1497,9 @@ static int nfs3_xdr_dec_setattr3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_diropres *result)
+				   void *data)
 {
+	struct nfs3_diropres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1544,8 +1545,9 @@ static int nfs3_xdr_dec_lookup3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_accessres *result)
+				   void *data)
 {
+	struct nfs3_accessres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1585,7 +1587,7 @@ static int nfs3_xdr_dec_access3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_readlink3res(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs_fattr *result)
+				     void *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -1663,8 +1665,9 @@ static int decode_read3resok(struct xdr_stream *xdr,
 }
 
 static int nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs_pgio_res *result)
+				 void *data)
 {
+	struct nfs_pgio_res *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1736,8 +1739,9 @@ static int decode_write3resok(struct xdr_stream *xdr,
 }
 
 static int nfs3_xdr_dec_write3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				  struct nfs_pgio_res *result)
+				  void *data)
 {
+	struct nfs_pgio_res *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1801,8 +1805,9 @@ static int decode_create3resok(struct xdr_stream *xdr,
 
 static int nfs3_xdr_dec_create3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_diropres *result)
+				   void *data)
 {
+	struct nfs3_diropres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1841,8 +1846,9 @@ static int nfs3_xdr_dec_create3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_removeres *result)
+				   void *data)
 {
+	struct nfs_removeres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1882,8 +1888,9 @@ static int nfs3_xdr_dec_remove3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_renameres *result)
+				   void *data)
 {
+	struct nfs_renameres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -1925,8 +1932,9 @@ static int nfs3_xdr_dec_rename3res(struct rpc_rqst *req,
  *	};
  */
 static int nfs3_xdr_dec_link3res(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs3_linkres *result)
+				 void *data)
 {
+	struct nfs3_linkres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -2109,8 +2117,9 @@ static int decode_readdir3resok(struct xdr_stream *xdr,
 
 static int nfs3_xdr_dec_readdir3res(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs3_readdirres *result)
+				    void *data)
 {
+	struct nfs3_readdirres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -2177,8 +2186,9 @@ static int decode_fsstat3resok(struct xdr_stream *xdr,
 
 static int nfs3_xdr_dec_fsstat3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_fsstat *result)
+				   void *data)
 {
+	struct nfs_fsstat *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -2253,8 +2263,9 @@ static int decode_fsinfo3resok(struct xdr_stream *xdr,
 
 static int nfs3_xdr_dec_fsinfo3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_fsinfo *result)
+				   void *data)
 {
+	struct nfs_fsinfo *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -2316,8 +2327,9 @@ static int decode_pathconf3resok(struct xdr_stream *xdr,
 
 static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs_pathconf *result)
+				     void *data)
 {
+	struct nfs_pathconf *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -2357,8 +2369,9 @@ static int nfs3_xdr_dec_pathconf3res(struct rpc_rqst *req,
  */
 static int nfs3_xdr_dec_commit3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_commitres *result)
+				   void *data)
 {
+	struct nfs_commitres *result = data;
 	enum nfs_stat status;
 	int error;
 
@@ -2426,7 +2439,7 @@ static inline int decode_getacl3resok(struct xdr_stream *xdr,
 
 static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs3_getaclres *result)
+				   void *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -2445,7 +2458,7 @@ static int nfs3_xdr_dec_getacl3res(struct rpc_rqst *req,
 
 static int nfs3_xdr_dec_setacl3res(struct rpc_rqst *req,
 				   struct xdr_stream *xdr,
-				   struct nfs_fattr *result)
+				   void *result)
 {
 	enum nfs_stat status;
 	int error;
@@ -2533,7 +2546,7 @@ static int nfs3_stat_to_errno(enum nfs_stat status)
 [NFS3PROC_##proc] = {							\
 	.p_proc      = NFS3PROC_##proc,					\
 	.p_encode    = nfs3_xdr_enc_##argtype##3args,			\
-	.p_decode    = (kxdrdproc_t)nfs3_xdr_dec_##restype##3res,	\
+	.p_decode    = nfs3_xdr_dec_##restype##3res,			\
 	.p_arglen    = NFS3_##argtype##args_sz,				\
 	.p_replen    = NFS3_##restype##res_sz,				\
 	.p_timer     = timer,						\
@@ -2576,7 +2589,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_GETACL] = {
 		.p_proc = ACLPROC3_GETACL,
 		.p_encode = nfs3_xdr_enc_getacl3args,
-		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_getacl3res,
+		.p_decode = nfs3_xdr_dec_getacl3res,
 		.p_arglen = ACL3_getaclargs_sz,
 		.p_replen = ACL3_getaclres_sz,
 		.p_timer = 1,
@@ -2585,7 +2598,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	[ACLPROC3_SETACL] = {
 		.p_proc = ACLPROC3_SETACL,
 		.p_encode = nfs3_xdr_enc_setacl3args,
-		.p_decode = (kxdrdproc_t)nfs3_xdr_dec_setacl3res,
+		.p_decode = nfs3_xdr_dec_setacl3res,
 		.p_arglen = ACL3_setaclargs_sz,
 		.p_replen = ACL3_setaclres_sz,
 		.p_timer = 0,
diff --git a/fs/nfs/nfs42xdr.c b/fs/nfs/nfs42xdr.c
index 0a1bd60a1f8e..5ee1b0f0d904 100644
--- a/fs/nfs/nfs42xdr.c
+++ b/fs/nfs/nfs42xdr.c
@@ -454,8 +454,9 @@ static int decode_clone(struct xdr_stream *xdr)
  */
 static int nfs4_xdr_dec_allocate(struct rpc_rqst *rqstp,
 				 struct xdr_stream *xdr,
-				 struct nfs42_falloc_res *res)
+				 void *data)
 {
+	struct nfs42_falloc_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -481,8 +482,9 @@ static int nfs4_xdr_dec_allocate(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
 			     struct xdr_stream *xdr,
-			     struct nfs42_copy_res *res)
+			     void *data)
 {
+	struct nfs42_copy_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -514,8 +516,9 @@ static int nfs4_xdr_dec_copy(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
 				   struct xdr_stream *xdr,
-				   struct nfs42_falloc_res *res)
+				   void *data)
 {
+	struct nfs42_falloc_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -541,8 +544,9 @@ static int nfs4_xdr_dec_deallocate(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
 			     struct xdr_stream *xdr,
-			     struct nfs42_seek_res *res)
+			     void *data)
 {
+	struct nfs42_seek_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -565,8 +569,9 @@ static int nfs4_xdr_dec_seek(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_layoutstats(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs42_layoutstat_res *res)
+				    void *data)
 {
+	struct nfs42_layoutstat_res *res = data;
 	struct compound_hdr hdr;
 	int status, i;
 
@@ -595,8 +600,9 @@ static int nfs4_xdr_dec_layoutstats(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_clone(struct rpc_rqst *rqstp,
 			      struct xdr_stream *xdr,
-			      struct nfs42_clone_res *res)
+			      void *data)
 {
+	struct nfs42_clone_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c5036ef770f9..797f3ce75286 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6154,8 +6154,9 @@ int decode_layoutreturn(struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       struct nfs_closeres *res)
+				       void *data)
 {
+	struct nfs_closeres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6183,8 +6184,9 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp,
  * Decode ACCESS response
  */
 static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs4_accessres *res)
+			       void *data)
 {
+	struct nfs4_accessres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6209,8 +6211,9 @@ static int nfs4_xdr_dec_access(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode LOOKUP response
  */
 static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs4_lookup_res *res)
+			       void *data)
 {
+	struct nfs4_lookup_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6239,8 +6242,9 @@ static int nfs4_xdr_dec_lookup(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs4_lookup_res *res)
+				    void *data)
 {
+	struct nfs4_lookup_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6265,8 +6269,9 @@ static int nfs4_xdr_dec_lookup_root(struct rpc_rqst *rqstp,
  * Decode REMOVE response
  */
 static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_removeres *res)
+			       void *data)
 {
+	struct nfs_removeres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6288,8 +6293,9 @@ static int nfs4_xdr_dec_remove(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode RENAME response
  */
 static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_renameres *res)
+			       void *data)
 {
+	struct nfs_renameres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6317,8 +6323,9 @@ static int nfs4_xdr_dec_rename(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode LINK response
  */
 static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs4_link_res *res)
+			     void *data)
 {
+	struct nfs4_link_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6356,8 +6363,9 @@ static int nfs4_xdr_dec_link(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode CREATE response
  */
 static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs4_create_res *res)
+			       void *data)
 {
+	struct nfs4_create_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6385,7 +6393,7 @@ static int nfs4_xdr_dec_create(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode SYMLINK response
  */
 static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-				struct nfs4_create_res *res)
+				void *res)
 {
 	return nfs4_xdr_dec_create(rqstp, xdr, res);
 }
@@ -6394,8 +6402,9 @@ static int nfs4_xdr_dec_symlink(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode GETATTR response
  */
 static int nfs4_xdr_dec_getattr(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-				struct nfs4_getattr_res *res)
+				void *data)
 {
+	struct nfs4_getattr_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6436,8 +6445,9 @@ static void nfs4_xdr_enc_setacl(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static int
 nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-		    struct nfs_setaclres *res)
+		    void *data)
 {
+	struct nfs_setaclres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6460,8 +6470,9 @@ nfs4_xdr_dec_setacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  */
 static int
 nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-		    struct nfs_getaclres *res)
+		    void *data)
 {
+	struct nfs_getaclres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6488,8 +6499,9 @@ nfs4_xdr_dec_getacl(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode CLOSE response
  */
 static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_closeres *res)
+			      void *data)
 {
+	struct nfs_closeres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6522,8 +6534,9 @@ static int nfs4_xdr_dec_close(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode OPEN response
  */
 static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_openres *res)
+			     void *data)
 {
+	struct nfs_openres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6554,8 +6567,9 @@ static int nfs4_xdr_dec_open(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs_open_confirmres *res)
+				     void *data)
 {
+	struct nfs_open_confirmres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6575,8 +6589,9 @@ static int nfs4_xdr_dec_open_confirm(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs_openres *res)
+				    void *data)
 {
+	struct nfs_openres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6604,8 +6619,9 @@ static int nfs4_xdr_dec_open_noattr(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct nfs_setattrres *res)
+				void *data)
 {
+	struct nfs_setattrres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6630,8 +6646,9 @@ static int nfs4_xdr_dec_setattr(struct rpc_rqst *rqstp,
  * Decode LOCK response
  */
 static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_lock_res *res)
+			     void *data)
 {
+	struct nfs_lock_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6653,8 +6670,9 @@ static int nfs4_xdr_dec_lock(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode LOCKT response
  */
 static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_lockt_res *res)
+			      void *data)
 {
+	struct nfs_lockt_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6676,8 +6694,9 @@ static int nfs4_xdr_dec_lockt(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode LOCKU response
  */
 static int nfs4_xdr_dec_locku(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_locku_res *res)
+			      void *data)
 {
+	struct nfs_locku_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6712,8 +6731,9 @@ static int nfs4_xdr_dec_release_lockowner(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp,
 				 struct xdr_stream *xdr,
-				 struct nfs4_readlink_res *res)
+				 void *data)
 {
+	struct nfs4_readlink_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6735,8 +6755,9 @@ static int nfs4_xdr_dec_readlink(struct rpc_rqst *rqstp,
  * Decode READDIR response
  */
 static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-				struct nfs4_readdir_res *res)
+				void *data)
 {
+	struct nfs4_readdir_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6758,8 +6779,9 @@ static int nfs4_xdr_dec_readdir(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode Read response
  */
 static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			     struct nfs_pgio_res *res)
+			     void *data)
 {
+	struct nfs_pgio_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6784,8 +6806,9 @@ static int nfs4_xdr_dec_read(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode WRITE response
  */
 static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			      struct nfs_pgio_res *res)
+			      void *data)
 {
+	struct nfs_pgio_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6814,8 +6837,9 @@ static int nfs4_xdr_dec_write(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode COMMIT response
  */
 static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
-			       struct nfs_commitres *res)
+			       void *data)
 {
+	struct nfs_commitres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6838,8 +6862,9 @@ static int nfs4_xdr_dec_commit(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  * Decode FSINFO response
  */
 static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs4_fsinfo_res *res)
+			       void *data)
 {
+	struct nfs4_fsinfo_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6857,8 +6882,9 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Decode PATHCONF response
  */
 static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
-				 struct nfs4_pathconf_res *res)
+				 void *data)
 {
+	struct nfs4_pathconf_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6876,8 +6902,9 @@ static int nfs4_xdr_dec_pathconf(struct rpc_rqst *req, struct xdr_stream *xdr,
  * Decode STATFS response
  */
 static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
-			       struct nfs4_statfs_res *res)
+			       void *data)
 {
+	struct nfs4_statfs_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6896,8 +6923,9 @@ static int nfs4_xdr_dec_statfs(struct rpc_rqst *req, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_server_caps(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs4_server_caps_res *res)
+				    void *data)
 {
+	struct nfs4_server_caps_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6935,8 +6963,9 @@ static int nfs4_xdr_dec_renew(struct rpc_rqst *rqstp, struct xdr_stream *xdr,
  */
 static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req,
 				    struct xdr_stream *xdr,
-				    struct nfs4_setclientid_res *res)
+				    void *data)
 {
+	struct nfs4_setclientid_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -6950,7 +6979,8 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req,
  * Decode SETCLIENTID_CONFIRM response
  */
 static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req,
-					    struct xdr_stream *xdr)
+					    struct xdr_stream *xdr,
+					    void *data)
 {
 	struct compound_hdr hdr;
 	int status;
@@ -6966,8 +6996,9 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req,
  */
 static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
 				    struct xdr_stream *xdr,
-				    struct nfs4_delegreturnres *res)
+				    void *data)
 {
+	struct nfs4_delegreturnres *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7001,8 +7032,9 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 				     struct xdr_stream *xdr,
-				     struct nfs4_fs_locations_res *res)
+				     void *data)
 {
+	struct nfs4_fs_locations_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7044,8 +7076,9 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
  */
 static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp,
 				struct xdr_stream *xdr,
-				struct nfs4_secinfo_res *res)
+				void *data)
 {
+	struct nfs4_secinfo_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7068,8 +7101,9 @@ static int nfs4_xdr_dec_secinfo(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_fsid_present(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs4_fsid_present_res *res)
+				     void *data)
 {
+	struct nfs4_fsid_present_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7129,7 +7163,7 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       struct nfs41_create_session_res *res)
+				       void *res)
 {
 	struct compound_hdr hdr;
 	int status;
@@ -7177,7 +7211,7 @@ static int nfs4_xdr_dec_destroy_clientid(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp,
 				 struct xdr_stream *xdr,
-				 struct nfs4_sequence_res *res)
+				 void *res)
 {
 	struct compound_hdr hdr;
 	int status;
@@ -7193,8 +7227,9 @@ static int nfs4_xdr_dec_sequence(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp,
 				       struct xdr_stream *xdr,
-				       struct nfs4_get_lease_time_res *res)
+				       void *data)
 {
+	struct nfs4_get_lease_time_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7213,8 +7248,9 @@ static int nfs4_xdr_dec_get_lease_time(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
 					 struct xdr_stream *xdr,
-					 struct nfs41_reclaim_complete_res *res)
+					 void *data)
 {
+	struct nfs41_reclaim_complete_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7231,8 +7267,9 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
 				      struct xdr_stream *xdr,
-				      struct nfs4_getdeviceinfo_res *res)
+				      void *data)
 {
+	struct nfs4_getdeviceinfo_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7252,8 +7289,9 @@ static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp,
 				  struct xdr_stream *xdr,
-				  struct nfs4_layoutget_res *res)
+				  void *data)
 {
+	struct nfs4_layoutget_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7276,8 +7314,9 @@ static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs4_layoutreturn_res *res)
+				     void *data)
 {
+	struct nfs4_layoutreturn_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7300,8 +7339,9 @@ static int nfs4_xdr_dec_layoutreturn(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs4_layoutcommit_res *res)
+				     void *data)
 {
+	struct nfs4_layoutcommit_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7327,8 +7367,9 @@ static int nfs4_xdr_dec_layoutcommit(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_secinfo_no_name(struct rpc_rqst *rqstp,
 					struct xdr_stream *xdr,
-					struct nfs4_secinfo_res *res)
+					void *data)
 {
+	struct nfs4_secinfo_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7351,8 +7392,9 @@ static int nfs4_xdr_dec_secinfo_no_name(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_test_stateid(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs41_test_stateid_res *res)
+				     void *data)
 {
+	struct nfs41_test_stateid_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7372,8 +7414,9 @@ static int nfs4_xdr_dec_test_stateid(struct rpc_rqst *rqstp,
  */
 static int nfs4_xdr_dec_free_stateid(struct rpc_rqst *rqstp,
 				     struct xdr_stream *xdr,
-				     struct nfs41_free_stateid_res *res)
+				     void *data)
 {
+	struct nfs41_free_stateid_res *res = data;
 	struct compound_hdr hdr;
 	int status;
 
@@ -7539,7 +7582,7 @@ nfs4_stat_to_errno(int stat)
 [NFSPROC4_CLNT_##proc] = {					\
 	.p_proc   = NFSPROC4_COMPOUND,				\
 	.p_encode = nfs4_xdr_##argtype,				\
-	.p_decode = (kxdrdproc_t)nfs4_xdr_##restype,		\
+	.p_decode = nfs4_xdr_##restype,				\
 	.p_arglen = NFS4_##argtype##_sz,			\
 	.p_replen = NFS4_##restype##_sz,			\
 	.p_statidx = NFSPROC4_CLNT_##proc,			\
-- 
2.11.0

