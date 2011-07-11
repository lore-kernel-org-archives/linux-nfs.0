Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42812 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757467Ab1GKRzD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jul 2011 13:55:03 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1: handle decoding of three attribute bitmaps
Date: Mon, 11 Jul 2011 13:54:07 -0400
Message-Id: <1310406847-31297-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Attribute IDs assigned in RFC 5661 now require three bitmaps.

Signed-off-by: Andy Adamson <andros@netapp.com>
Cc:stable@kernel.org [2.6.39]
---
 fs/nfs/nfs4xdr.c          |   28 ++++++++++++++++------------
 include/linux/nfs_fs_sb.h |    2 +-
 include/linux/nfs_xdr.h   |    2 +-
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index aa83aa7..ee98965 100644
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
@@ -3011,14 +3011,17 @@ static int decode_attr_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
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
+		if (bmlen > 1) {
 			bitmap[1] = be32_to_cpup(p);
+			if (bmlen > 2)
+				bitmap[2] = be32_to_cpup(p++);
+		}
 	}
 	return 0;
 out_overflow:
@@ -3050,8 +3053,9 @@ static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint3
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
 
@@ -4105,7 +4109,7 @@ out_overflow:
 static int decode_server_caps(struct xdr_stream *xdr, struct nfs4_server_caps_res *res)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4131,7 +4135,7 @@ xdr_error:
 static int decode_statfs(struct xdr_stream *xdr, struct nfs_fsstat *fsstat)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4163,7 +4167,7 @@ xdr_error:
 static int decode_pathconf(struct xdr_stream *xdr, struct nfs_pathconf *pathconf)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2] = {0};
+	uint32_t attrlen, bitmap[3] = {0};
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4303,7 +4307,7 @@ static int decode_getfattr_generic(struct xdr_stream *xdr, struct nfs_fattr *fat
 {
 	__be32 *savep;
 	uint32_t attrlen,
-		 bitmap[2] = {0};
+		 bitmap[3] = {0};
 	int status;
 
 	status = decode_op_hdr(xdr, OP_GETATTR);
@@ -4392,7 +4396,7 @@ static int decode_attr_pnfstype(struct xdr_stream *xdr, uint32_t *bitmap,
 static int decode_fsinfo(struct xdr_stream *xdr, struct nfs_fsinfo *fsinfo)
 {
 	__be32 *savep;
-	uint32_t attrlen, bitmap[2];
+	uint32_t attrlen, bitmap[3];
 	int status;
 
 	if ((status = decode_op_hdr(xdr, OP_GETATTR)) != 0)
@@ -4839,7 +4843,7 @@ static int decode_getacl(struct xdr_stream *xdr, struct rpc_rqst *req,
 {
 	__be32 *savep;
 	uint32_t attrlen,
-		 bitmap[2] = {0};
+		 bitmap[3] = {0};
 	struct kvec *iov = req->rq_rcv_buf.head;
 	int status;
 
@@ -6722,7 +6726,7 @@ out:
 int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		       int plus)
 {
-	uint32_t bitmap[2] = {0};
+	uint32_t bitmap[3] = {0};
 	uint32_t len;
 	__be32 *p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4faeac8..b488515 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -132,7 +132,7 @@ struct nfs_server {
 #endif
 
 #ifdef CONFIG_NFS_V4
-	u32			attr_bitmask[2];/* V4 bitmask representing the set
+	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
 	u32			cache_consistency_bitmask[2];
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 956d357..7be2b95 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -943,7 +943,7 @@ struct nfs4_server_caps_arg {
 };
 
 struct nfs4_server_caps_res {
-	u32				attr_bitmask[2];
+	u32				attr_bitmask[3];
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
-- 
1.7.3.1

