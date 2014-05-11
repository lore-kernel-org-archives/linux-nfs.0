Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38551 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757579AbaEKUw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 15/43] nfsd4: "backfill" using write_bytes_to_xdr_buf
Date: Sun, 11 May 2014 16:52:20 -0400
Message-Id: <1399841568-19716-16-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Normally xdr encoding proceeds in a single pass from start of a buffer
to end, but sometimes we have to write a few bytes to an earlier
position.

Use write_bytes_to_xdr_buf for these cases rather than saving a pointer
to write to.  We plan to rewrite xdr_reserve_space to handle encoding
across page boundaries using a scratch buffer, and don't want to risk
writing to a pointer that was contained in a scratch buffer.

Also it will no longer be safe to calculate lengths by subtracting two
pointers, so use xdr_buf offsets instead.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   44 ++++++++++++++++++++++++++------------------
 1 file changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index da6b43d..cc219b8 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1757,16 +1757,19 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
 static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep, char *components, char esc_enter, char esc_exit)
 {
 	__be32 *p;
-	__be32 *countp;
+	__be32 pathlen;
+	int pathlen_offset;
 	int strlen, count=0;
 	char *str, *end, *next;
 
 	dprintk("nfsd4_encode_components(%s)\n", components);
+
+	pathlen_offset = xdr->buf->len;
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		return nfserr_resource;
-	countp = p;
-	WRITE32(0); /* We will fill this in with @count later */
+	p++; /* We will fill this in with @count later */
+
 	end = str = components;
 	while (*end) {
 		bool found_esc = false;
@@ -1799,8 +1802,8 @@ static __be32 nfsd4_encode_components_esc(struct xdr_stream *xdr, char sep, char
 			end++;
 		str = end;
 	}
-	p = countp;
-	WRITE32(count);
+	pathlen = htonl(xdr->buf->len - pathlen_offset);
+	write_bytes_to_xdr_buf(xdr->buf, pathlen_offset, &pathlen, 4);
 	return 0;
 }
 
@@ -2042,7 +2045,8 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 	struct kstatfs statfs;
 	__be32 *p;
 	int starting_len = xdr->buf->len;
-	__be32 *attrlenp;
+	int attrlen_offset;
+	__be32 attrlen;
 	u32 dummy;
 	u64 dummy64;
 	u32 rdattr_err = 0;
@@ -2147,10 +2151,12 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp, struct svc_export
 		WRITE32(1);
 		WRITE32(bmval0);
 	}
+
+	attrlen_offset = xdr->buf->len;
 	p = xdr_reserve_space(xdr, 4);
 	if (!p)
 		goto out_resource;
-	attrlenp = p++;                /* to be backfilled later */
+	p++;                /* to be backfilled later */
 
 	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
 		u32 word0 = nfsd_suppattrs0(minorversion);
@@ -2521,7 +2527,8 @@ out_acl:
 		WRITE32(NFSD_SUPPATTR_EXCLCREAT_WORD2);
 	}
 
-	*attrlenp = htonl((char *)xdr->p - (char *)attrlenp - 4);
+	attrlen = htonl(xdr->buf->len - attrlen_offset - 4);
+	write_bytes_to_xdr_buf(xdr->buf, attrlen_offset, &attrlen, 4);
 	status = nfs_ok;
 
 out:
@@ -3648,15 +3655,16 @@ __be32 nfsd4_check_resp_size(struct nfsd4_compoundres *resp, u32 pad)
 void
 nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 {
+	struct xdr_stream *xdr = &resp->xdr;
 	struct nfs4_stateowner *so = resp->cstate.replay_owner;
 	struct svc_rqst *rqstp = resp->rqstp;
-	__be32 *statp;
+	int post_err_offset;
 	nfsd4_enc encoder;
 	__be32 *p;
 
 	RESERVE_SPACE(8);
 	WRITE32(op->opnum);
-	statp = p++;	/* to be backfilled at the end */
+	post_err_offset = xdr->buf->len;
 
 	if (op->opnum == OP_ILLEGAL)
 		goto status;
@@ -3687,19 +3695,19 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 			       nfsd4_op_name(op->opnum));
 			WARN_ON_ONCE(1);
 		}
-		resp->xdr.p = statp + 1;
+		xdr_truncate_encode(xdr, post_err_offset);
 	}
 	if (so) {
+		int len = xdr->buf->len - post_err_offset;
+
 		so->so_replay.rp_status = op->status;
-		so->so_replay.rp_buflen = (char *)resp->xdr.p - (char *)(statp+1);
-		memcpy(so->so_replay.rp_buf, statp+1, so->so_replay.rp_buflen);
+		so->so_replay.rp_buflen = len;
+		read_bytes_from_xdr_buf(xdr->buf, post_err_offset,
+						so->so_replay.rp_buf, len);
 	}
 status:
-	/*
-	 * Note: We write the status directly, instead of using WRITE32(),
-	 * since it is already in network byte order.
-	 */
-	*statp = op->status;
+	/* Note that op->status is already in network byte order: */
+	write_bytes_to_xdr_buf(xdr->buf, post_err_offset - 4, &op->status, 4);
 }
 
 /* 
-- 
1.7.9.5

