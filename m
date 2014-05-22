Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43467 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbaEVTcp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 15:32:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 39/52] nfsd4: better estimate of getattr response size
Date: Thu, 22 May 2014 15:32:14 -0400
Message-Id: <1400787148-25941-40-git-send-email-bfields@redhat.com>
In-Reply-To: <1400787148-25941-1-git-send-email-bfields@redhat.com>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We plan to use this estimate to decide whether or not to allow zero-copy
reads.  Currently we're assuming all getattr's are a page, which can be
both too small (ACLs e.g. may be arbitrarily long) and too large (after
an upcoming read patch this will unnecessarily prevent zero copy reads
in any read compound also containing a getattr).

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c | 44 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 44 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f56f5e3..7c3df68 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1467,6 +1467,49 @@ static inline u32 nfsd4_create_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op
 		+ nfs4_fattr_bitmap_maxsz) * sizeof(__be32);
 }
 
+/*
+ * Note since this is an idempotent operation we won't insist on failing
+ * the op prematurely if the estimate is too large.  We may turn off splice
+ * reads unnecessarily.
+ */
+static inline u32 nfsd4_getattr_rsize(struct svc_rqst *rqstp,
+				      struct nfsd4_op *op)
+{
+	u32 *bmap = op->u.getattr.ga_bmval;
+	u32 bmap0 = bmap[0], bmap1 = bmap[1], bmap2 = bmap[2];
+	u32 ret = 0;
+
+	if (bmap0 & FATTR4_WORD0_ACL)
+		return svc_max_payload(rqstp);
+	if (bmap0 & FATTR4_WORD0_FS_LOCATIONS)
+		return svc_max_payload(rqstp);
+
+	if (bmap1 & FATTR4_WORD1_OWNER) {
+		ret += IDMAP_NAMESZ + 4;
+		bmap1 &= ~FATTR4_WORD1_OWNER;
+	}
+	if (bmap1 & FATTR4_WORD1_OWNER_GROUP) {
+		ret += IDMAP_NAMESZ + 4;
+		bmap1 &= ~FATTR4_WORD1_OWNER_GROUP;
+	}
+	if (bmap0 & FATTR4_WORD0_FILEHANDLE) {
+		ret += NFS4_FHSIZE + 4;
+		bmap0 &= ~FATTR4_WORD0_FILEHANDLE;
+	}
+	if (bmap2 & FATTR4_WORD2_SECURITY_LABEL) {
+		ret += NFSD4_MAX_SEC_LABEL_LEN + 12;
+		bmap2 &= ~FATTR4_WORD2_SECURITY_LABEL;
+	}
+	/*
+	 * Largest of remaining attributes are 16 bytes (e.g.,
+	 * supported_attributes)
+	 */
+	ret += 16 * (hweight32(bmap0) + hweight32(bmap1) + hweight32(bmap2));
+	/* bitmask, length */
+	ret += 20;
+	return ret;
+}
+
 static inline u32 nfsd4_link_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
 	return (op_encode_hdr_size + op_encode_change_info_maxsz)
@@ -1605,6 +1648,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_GETATTR] = {
 		.op_func = (nfsd4op_func)nfsd4_getattr,
 		.op_flags = ALLOWED_ON_ABSENT_FS,
+		.op_rsize_bop = nfsd4_getattr_rsize,
 		.op_name = "OP_GETATTR",
 	},
 	[OP_GETFH] = {
-- 
1.9.0

