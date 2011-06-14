Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:51961 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752246Ab1FNCcP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jun 2011 22:32:15 -0400
Message-Id: <cdef40ef23730695a2c1127d03e0827a72880f90.1308017749.git.rees@umich.edu>
In-Reply-To: <cover.1308017749.git.rees@umich.edu>
References: <cover.1308017749.git.rees@umich.edu>
Subject: [PATCH 05/33] pnfs: ask for layout_blksize and save it in nfs_server
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Mon, 13 Jun 2011 22:32:12 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Block layout needs it to determine IO size.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Tao Guo <glorioustao@gmail.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Peng Tao <bergwolf@gmail.com>
---
 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4_fs.h          |    2 +-
 fs/nfs/nfs4proc.c         |    5 +-
 fs/nfs/nfs4xdr.c          |  101 +++++++++++++++++++++++++++++++++++++--------
 include/linux/nfs_fs_sb.h |    4 +-
 include/linux/nfs_xdr.h   |    3 +-
 6 files changed, 93 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d630bb7..3b75943 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -938,6 +938,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	server->pnfs_blksize = fsinfo->blksize;
 	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c4a6983..5725a7e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -315,7 +315,7 @@ extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
 extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
 extern const u32 nfs4_pathconf_bitmap[2];
-extern const u32 nfs4_fsinfo_bitmap[2];
+extern const u32 nfs4_fsinfo_bitmap[3];
 extern const u32 nfs4_fs_locations_bitmap[2];
 
 /* nfs4renewd.c */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ec580a8..04450bf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -137,12 +137,13 @@ const u32 nfs4_pathconf_bitmap[2] = {
 	0
 };
 
-const u32 nfs4_fsinfo_bitmap[2] = { FATTR4_WORD0_MAXFILESIZE
+const u32 nfs4_fsinfo_bitmap[3] = { FATTR4_WORD0_MAXFILESIZE
 			| FATTR4_WORD0_MAXREAD
 			| FATTR4_WORD0_MAXWRITE
 			| FATTR4_WORD0_LEASE_TIME,
 			FATTR4_WORD1_TIME_DELTA
-			| FATTR4_WORD1_FS_LAYOUT_TYPES
+			| FATTR4_WORD1_FS_LAYOUT_TYPES,
+			FATTR4_WORD2_LAYOUT_BLKSIZE
 };
 
 const u32 nfs4_fs_locations_bitmap[2] = {
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 60e9d44..b8f375e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -91,7 +91,7 @@ static int nfs4_stat_to_errno(int);
 #define encode_getfh_maxsz      (op_encode_hdr_maxsz)
 #define decode_getfh_maxsz      (op_decode_hdr_maxsz + 1 + \
 				((3+NFS4_FHSIZE) >> 2))
-#define nfs4_fattr_bitmap_maxsz 3
+#define nfs4_fattr_bitmap_maxsz 4
 #define encode_getattr_maxsz    (op_encode_hdr_maxsz + nfs4_fattr_bitmap_maxsz)
 #define nfs4_name_maxsz		(1 + ((3 + NFS4_MAXNAMLEN) >> 2))
 #define nfs4_path_maxsz		(1 + ((3 + NFS4_MAXPATHLEN) >> 2))
@@ -113,7 +113,11 @@ static int nfs4_stat_to_errno(int);
 #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
 #define decode_restorefh_maxsz  (op_decode_hdr_maxsz)
 #define encode_fsinfo_maxsz	(encode_getattr_maxsz)
-#define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 15)
+/* The 5 accounts for the PNFS attributes, and assumes that at most three
+ * layout types will be returned.
+ */
+#define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + \
+				 nfs4_fattr_bitmap_maxsz + 4 + 8 + 5)
 #define encode_renew_maxsz	(op_encode_hdr_maxsz + 3)
 #define decode_renew_maxsz	(op_decode_hdr_maxsz)
 #define encode_setclientid_maxsz \
@@ -1095,6 +1099,35 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
 	hdr->replen += decode_getattr_maxsz;
 }
 
+static void
+encode_getattr_three(struct xdr_stream *xdr,
+		     uint32_t bm0, uint32_t bm1, uint32_t bm2,
+		     struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 4);
+	*p = cpu_to_be32(OP_GETATTR);
+	if (bm2) {
+		p = reserve_space(xdr, 16);
+		*p++ = cpu_to_be32(3);
+		*p++ = cpu_to_be32(bm0);
+		*p++ = cpu_to_be32(bm1);
+		*p = cpu_to_be32(bm2);
+	} else if (bm1) {
+		p = reserve_space(xdr, 12);
+		*p++ = cpu_to_be32(2);
+		*p++ = cpu_to_be32(bm0);
+		*p = cpu_to_be32(bm1);
+	} else {
+		p = reserve_space(xdr, 8);
+		*p++ = cpu_to_be32(1);
+		*p = cpu_to_be32(bm0);
+	}
+	hdr->nops++;
+	hdr->replen += decode_getattr_maxsz;
+}
+
 static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	encode_getattr_two(xdr, bitmask[0] & nfs4_fattr_bitmap[0],
@@ -1103,8 +1136,11 @@ static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct c
 
 static void encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
-	encode_getattr_two(xdr, bitmask[0] & nfs4_fsinfo_bitmap[0],
-			   bitmask[1] & nfs4_fsinfo_bitmap[1], hdr);
+	encode_getattr_three(xdr,
+			     bitmask[0] & nfs4_fsinfo_bitmap[0],
+			     bitmask[1] & nfs4_fsinfo_bitmap[1],
+			     bitmask[2] & nfs4_fsinfo_bitmap[2],
+			     hdr);
 }
 
 static void encode_fs_locations(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
@@ -2575,7 +2611,7 @@ static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
+	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_setclientid_confirm(xdr, arg, &hdr);
@@ -2719,7 +2755,7 @@ static void nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req,
 	struct compound_hdr hdr = {
 		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
 	};
-	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
+	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->la_seq_args, &hdr);
@@ -2947,14 +2983,17 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
 		goto out_overflow;
 	bmlen = be32_to_cpup(p);
 
-	bitmap[0] = bitmap[1] = 0;
+	bitmap[0] = bitmap[1] = bitmap[2] = 0;
 	p = xdr_inline_decode(xdr, (bmlen << 2));
 	if (unlikely(!p))
 		goto out_overflow;
 	if (bmlen > 0) {
 		bitmap[0] = be32_to_cpup(p++);
-		if (bmlen > 1)
-			bitmap[1] = be32_to_cpup(p);
+		if (bmlen > 1) {
+			bitmap[1] = be32_to_cpup(p++);
+			if (bmlen > 2)
+				bitmap[2] = be32_to_cpup(p);
+		}
 	}
 	return 0;
 out_overflow:
@@ -2986,8 +3025,9 @@ static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint3
 			return ret;
 		bitmap[0] &= ~FATTR4_WORD0_SUPPORTED_ATTRS;
 	} else
-		bitmask[0] = bitmask[1] = 0;
-	dprintk("%s: bitmask=%08x:%08x\n", __func__, bitmask[0], bitmask[1]);
+		bitmask[0] = bitmask[1] = bitmask[2] = 0;
+	dprintk("%s: bitmask=%08x:%08x:%08x\n", __func__,
+		bitmask[0], bitmask[1], bitmask[2]);
 	return 0;
 }
 
@@ -4041,7 +4081,7 @@ out_overflow:
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4067,7 +4107,7 @@ xdr_error:
 static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4099,7 +4139,7 @@ xdr_error:
 static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4239,7 +4279,7 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 {
 	__be32 *savep;
 	uint32_t attrlen,
-		 bitmap[2] = {0};
+		 bitmap[3] = {0};
 	int status;
 
 	status = decode_op_hdr(xdr, OP_GETATTR);
@@ -4325,10 +4365,32 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 	return status;
 }
 
+/*
+ * The prefered block size for layout directed io
+ */
+static int decode_attr_layout_blksize(struct xdr_stream *xdr, uint32_t *bitmap,
+				      uint32_t *res)
+{
+	__be32 *p;
+
+	dprintk("%s: bitmap is %x\n", __func__, bitmap[2]);
+	*res = 0;
+	if (bitmap[2] & FATTR4_WORD2_LAYOUT_BLKSIZE) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p)) {
+			print_overflow_msg(__func__, xdr);
+			return -EIO;
+		}
+		*res = be32_to_cpup(p);
+		bitmap[2] &= ~FATTR4_WORD2_LAYOUT_BLKSIZE;
+	}
+	return 0;
+}
+
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2];
+	uint32_t attrlen, bitmap[3];
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4356,6 +4418,9 @@ static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 	status = decode_attr_pnfstype(xdr, bitmap, &fsinfo->layouttype);
 	if (status != 0)
 		goto xdr_error;
+	status = decode_attr_layout_blksize(xdr, bitmap, &fsinfo->blksize);
+	if (status)
+		goto xdr_error;
 
 	status = verify_attr_len(xdr, savep, attrlen);
 xdr_error:
@@ -4775,7 +4840,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 {
 	__be32 *savep;
 	uint32_t attrlen,
-		 bitmap[2] = {0};
+		 bitmap[3] = {0};
 	struct kvec *iov = req->rq_rcv_buf.head;
 	int status;
 
@@ -6607,7 +6672,7 @@ out:
 int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		       int plus)
 {
-	uint32_t bitmap[2] = {0};
+	uint32_t bitmap[3] = {0};
 	uint32_t len;
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87694ca..79cc4ca 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -130,7 +130,7 @@ struct nfs_server {
 #endif
 
 #ifdef CONFIG_NFS_V4
-	u32			attr_bitmask[2];/* V4 bitmask representing the set
+	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
 	u32			cache_consistency_bitmask[2];
@@ -143,6 +143,8 @@ struct nfs_server {
 						   filesystem */
 	struct pnfs_layoutdriver_type  *pnfs_curr_ld; /* Active layout driver */
 	struct rpc_wait_queue	roc_rpcwaitq;
+	void			*pnfs_ld_data; /* per mount point data */
+	u32			pnfs_blksize; /* layout_blksize attr */
 
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0863228..1fa6f7a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -122,6 +122,7 @@ struct nfs_fsinfo {
 	struct timespec		time_delta; /* server time granularity */
 	__u32			lease_time; /* in seconds */
 	__u32			layouttype; /* supported pnfs layout driver */
+	__u32			blksize; /* preferred pnfs io block size */
 };
 
 struct nfs_fsstat {
@@ -953,7 +954,7 @@ struct nfs4_server_caps_arg {
 };
 
 struct nfs4_server_caps_res {
-	u32				attr_bitmask[2];
+	u32				attr_bitmask[3];
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
-- 
1.7.4.1

