Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34959 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760971Ab2ERBX5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 May 2012 21:23:57 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 9 1/4] NFSv4.1 mdsthreshold attribute xdr
Date: Thu, 17 May 2012 15:48:19 -0400
Message-Id: <1337284102-3372-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

We only support one layout type per file system, so one threshold_item4 per
mdsthreshold4.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4xdr.c        |  125 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs4.h    |    7 +++
 include/linux/nfs_xdr.h |   10 ++++
 3 files changed, 140 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index db040e9..27eb873 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -99,9 +99,12 @@ static int nfs4_stat_to_errno(int);
 #define nfs4_path_maxsz		(1 + ((3 + NFS4_MAXPATHLEN) >> 2))
 #define nfs4_owner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define nfs4_group_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
+/* We support only one layout type per file system */
+#define decode_mdsthreshold_maxsz (1 + 1 + nfs4_fattr_bitmap_maxsz + 1 + 8)
 /* This is based on getfattr, which uses the most attributes: */
 #define nfs4_fattr_value_maxsz	(1 + (1 + 2 + 2 + 4 + 2 + 1 + 1 + 2 + 2 + \
-				3 + 3 + 3 + nfs4_owner_maxsz + nfs4_group_maxsz))
+				3 + 3 + 3 + nfs4_owner_maxsz + \
+				nfs4_group_maxsz + decode_mdsthreshold_maxsz))
 #define nfs4_fattr_maxsz	(nfs4_fattr_bitmap_maxsz + \
 				nfs4_fattr_value_maxsz)
 #define decode_getattr_maxsz    (op_decode_hdr_maxsz + nfs4_fattr_maxsz)
@@ -1170,6 +1173,16 @@ static void encode_getfattr(struct xdr_stream *xdr, const u32* bitmask, struct c
 			   bitmask[1] & nfs4_fattr_bitmap[1], hdr);
 }
 
+static void encode_getfattr_open(struct xdr_stream *xdr, const u32 *bitmask,
+				 struct compound_hdr *hdr)
+{
+	encode_getattr_three(xdr,
+			     bitmask[0] & nfs4_fattr_bitmap[0],
+			     bitmask[1] & nfs4_fattr_bitmap[1],
+			     bitmask[2] & FATTR4_WORD2_MDSTHRESHOLD,
+			     hdr);
+}
+
 static void encode_fsinfo(struct xdr_stream *xdr, const u32* bitmask, struct compound_hdr *hdr)
 {
 	encode_getattr_three(xdr,
@@ -2197,7 +2210,7 @@ static void nfs4_xdr_enc_open_noattr(struct rpc_rqst *req,
 	encode_sequence(xdr, &args->seq_args, &hdr);
 	encode_putfh(xdr, args->fh, &hdr);
 	encode_open(xdr, args, &hdr);
-	encode_getfattr(xdr, args->bitmask, &hdr);
+	encode_getfattr_open(xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -4183,6 +4196,110 @@ xdr_error:
 	return status;
 }
 
+static int decode_threshold_hint(struct xdr_stream *xdr,
+				  uint32_t *bitmap,
+				  uint64_t *res,
+				  uint32_t hint_bit)
+{
+	__be32 *p;
+
+	*res = 0;
+	if (likely(bitmap[0] & hint_bit)) {
+		p = xdr_inline_decode(xdr, 8);
+		if (unlikely(!p))
+			goto out_overflow;
+		xdr_decode_hyper(p, res);
+	}
+	return 0;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+static int decode_first_threshold_item4(struct xdr_stream *xdr,
+					struct nfs4_threshold *res)
+{
+	__be32 *p, *savep;
+	uint32_t bitmap[3] = {0,}, attrlen;
+	int status;
+
+	/* layout type */
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p)) {
+		print_overflow_msg(__func__, xdr);
+		return -EIO;
+	}
+	res->l_type = be32_to_cpup(p);
+
+	/* thi_hintset bitmap */
+	status = decode_attr_bitmap(xdr, bitmap);
+	if (status < 0)
+		goto xdr_error;
+
+	/* thi_hintlist length */
+	status = decode_attr_length(xdr, &attrlen, &savep);
+	if (status < 0)
+		goto xdr_error;
+	/* thi_hintlist */
+	status = decode_threshold_hint(xdr, bitmap, &res->rd_sz, THRESHOLD_RD);
+	if (status < 0)
+		goto xdr_error;
+	status = decode_threshold_hint(xdr, bitmap, &res->wr_sz, THRESHOLD_WR);
+	if (status < 0)
+		goto xdr_error;
+	status = decode_threshold_hint(xdr, bitmap, &res->rd_io_sz,
+				       THRESHOLD_RD_IO);
+	if (status < 0)
+		goto xdr_error;
+	status = decode_threshold_hint(xdr, bitmap, &res->wr_io_sz,
+				       THRESHOLD_WR_IO);
+	if (status < 0)
+		goto xdr_error;
+
+	status = verify_attr_len(xdr, savep, attrlen);
+	res->bm = bitmap[0];
+
+	dprintk("%s bm=0x%x rd_sz=%llu wr_sz=%llu rd_io=%llu wr_io=%llu\n",
+		 __func__, res->bm, res->rd_sz, res->wr_sz, res->rd_io_sz,
+		res->wr_io_sz);
+xdr_error:
+	dprintk("%s ret=%d!\n", __func__, status);
+	return status;
+}
+
+/*
+ * Thresholds on pNFS direct I/O vrs MDS I/O
+ */
+static int decode_attr_mdsthreshold(struct xdr_stream *xdr,
+				    uint32_t *bitmap,
+				    struct nfs4_threshold *res)
+{
+	__be32 *p;
+	int status = 0;
+	uint32_t num;
+
+	if (unlikely(bitmap[2] & (FATTR4_WORD2_MDSTHRESHOLD - 1U)))
+		return -EIO;
+	if (likely(bitmap[2] & FATTR4_WORD2_MDSTHRESHOLD)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		num = be32_to_cpup(p);
+		if (num == 0)
+			return 0;
+		if (num > 1)
+			printk(KERN_INFO "%s: Warning: Multiple pNFS layout "
+				"drivers per filesystem not supported\n",
+				__func__);
+
+		status = decode_first_threshold_item4(xdr, res);
+	}
+	return status;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
 static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		struct nfs_fattr *fattr, struct nfs_fh *fh,
 		struct nfs4_fs_locations *fs_loc,
@@ -4289,6 +4406,10 @@ static int decode_getfattr_attrs(struct xdr_stream *xdr, uint32_t *bitmap,
 		goto xdr_error;
 	fattr->valid |= status;
 
+	status = decode_attr_mdsthreshold(xdr, bitmap, &fattr->mdsthreshold);
+	if (status < 0)
+		goto xdr_error;
+
 xdr_error:
 	dprintk("%s: xdr returned %d\n", __func__, -status);
 	return status;
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 0987146..72b6bad 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -526,6 +526,13 @@ enum lock_type4 {
 #define FATTR4_WORD1_MOUNTED_ON_FILEID  (1UL << 23)
 #define FATTR4_WORD1_FS_LAYOUT_TYPES    (1UL << 30)
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
+#define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
+
+/* MDS threshold bitmap bits */
+#define THRESHOLD_RD                    (1UL << 0)
+#define THRESHOLD_WR                    (1UL << 1)
+#define THRESHOLD_RD_IO                 (1UL << 2)
+#define THRESHOLD_WR_IO                 (1UL << 3)
 
 #define NFSPROC4_NULL 0
 #define NFSPROC4_COMPOUND 1
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2e53a3f..d23379d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -35,6 +35,15 @@ static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct nfs_fsid
 	return a->major == b->major && a->minor == b->minor;
 }
 
+struct nfs4_threshold {
+	__u32	bm;
+	__u32	l_type;
+	__u64	rd_sz;
+	__u64	wr_sz;
+	__u64	rd_io_sz;
+	__u64	wr_io_sz;
+};
+
 struct nfs_fattr {
 	unsigned int		valid;		/* which fields are valid */
 	umode_t			mode;
@@ -67,6 +76,7 @@ struct nfs_fattr {
 	unsigned long		gencount;
 	struct nfs4_string	*owner_name;
 	struct nfs4_string	*group_name;
+	struct nfs4_threshold	mdsthreshold;	/* pNFS threshold hints */
 };
 
 #define NFS_ATTR_FATTR_TYPE		(1U << 0)
-- 
1.7.7.6

