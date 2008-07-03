From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/2] nfs: return nfs4 compound header status on op header decoding error
Date: Thu,  3 Jul 2008 20:52:25 +0300
Message-ID: <1215107545-6866-1-git-send-email-bhalevy@panasas.com>
References: <486D110F.1010608@panasas.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:52918 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbYGCRwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2008 13:52:40 -0400
In-Reply-To: <486D110F.1010608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c           |   30 +++++++++++++++++++++++-------
 include/linux/sunrpc/xdr.h |    1 +
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b916297..2cf724d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2214,8 +2214,10 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 {
 	__be32 *p;
 
+	xdr->status = -EIO;
 	READ_BUF(8);
 	READ32(hdr->status);
+	xdr->status = hdr->status;
 	READ32(hdr->taglen);
 	
 	READ_BUF(hdr->taglen + 4);
@@ -2225,24 +2227,38 @@ static int decode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	return 0;
 }
 
-static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
+static int
+decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 {
 	__be32 *p;
 	uint32_t opnum;
 	int32_t nfserr;
 
-	READ_BUF(8);
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p)) {
+		dprintk("nfs: %s: prematurely hit end of receive"
+				" buffer\n", __func__);
+		dprintk("nfs: %s: xdr->p=%p, bytes=%u, xdr->end=%p\n",
+				__func__, xdr->p, 8, xdr->end);
+		goto err;
+	}
 	READ32(opnum);
-	if (opnum != expected) {
+	if (unlikely(opnum != expected)) {
 		dprintk("nfs: Server returned operation"
 			" %d but we issued a request for %d\n",
 				opnum, expected);
-		return -EIO;
+		goto err;
 	}
 	READ32(nfserr);
-	if (nfserr != NFS_OK)
-		return nfs4_stat_to_errno(nfserr);
-	return 0;
+	if (likely(nfserr == NFS_OK))
+		return 0;
+	xdr->status = nfserr;
+err:
+	if (xdr->status != NFS_OK)
+		return nfs4_stat_to_errno(xdr->status);
+	dprintk("nfs: %s: xdr status %d, returning %d\n",
+		__func__, xdr->status, -EIO);
+	return -EIO;
 }
 
 /* Dummy routine */
diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index e4057d7..0c09ae5 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -208,6 +208,7 @@ struct xdr_stream {
 
 	__be32 *end;		/* end of available buffer space */
 	struct kvec *iov;	/* pointer to the current kvec */
+	int status;
 };
 
 extern void xdr_init_encode(struct xdr_stream *xdr, struct xdr_buf *buf, __be32 *p);
-- 
1.5.6.GIT

