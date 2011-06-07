Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52707 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756711Ab1FGR0a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:30 -0400
Date: Tue, 7 Jun 2011 13:26:26 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 05/88] pnfs: xdr support for three word attribute bitmap
Message-ID: <02f0129fe5370e69e08f839debc9eb90b642af51.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: clean up xdr]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c          |   59 +++++++++++++++++++++++++++++++++++----------
 include/linux/nfs_fs_sb.h |    2 +-
 include/linux/nfs_xdr.h   |    2 +-
 3 files changed, 48 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index aeb7bc2..5e4447c 100644
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
@@ -1095,6 +1095,35 @@ static void encode_getattr_two(struct xdr_stream *xdr, uint32_t bm0, uint32_t bm
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
@@ -2947,14 +2976,17 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
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
@@ -2986,8 +3018,9 @@ static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint3
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
 
@@ -4041,7 +4074,7 @@ out_overflow:
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4067,7 +4100,7 @@ xdr_error:
 static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4099,7 +4132,7 @@ xdr_error:
 static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4239,7 +4272,7 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 {
 	__be32 *savep;
 	uint32_t attrlen,
-		 bitmap[2] = {0};
+		 bitmap[3] = {0};
 	int status;
 
 	status = decode_op_hdr(xdr, OP_GETATTR);
@@ -4328,7 +4361,7 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2];
+	uint32_t attrlen, bitmap[3];
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4775,7 +4808,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 {
 	__be32 *savep;
 	uint32_t attrlen,
-		 bitmap[2] = {0};
+		 bitmap[3] = {0};
 	struct kvec *iov = req->rq_rcv_buf.head;
 	int status;
 
@@ -6606,7 +6639,7 @@ out:
 int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		       int plus)
 {
-	uint32_t bitmap[2] = {0};
+	uint32_t bitmap[3] = {0};
 	uint32_t len;
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87694ca..61052fc 100644
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
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a4f3dd6..6c32c9d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -957,7 +957,7 @@ struct nfs4_server_caps_arg {
 };
 
 struct nfs4_server_caps_res {
-	u32				attr_bitmask[2];
+	u32				attr_bitmask[3];
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
-- 
1.7.4.1

