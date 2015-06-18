Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42375 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932301AbbFROrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 10:47:08 -0400
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] nfsd: fput rd_file from XDR encode context
Date: Thu, 18 Jun 2015 16:45:01 +0200
Message-Id: <1434638702-353-5-git-send-email-hch@lst.de>
In-Reply-To: <1434638702-353-1-git-send-email-hch@lst.de>
References: <1434638702-353-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the hack where we fput the read-specific file in generic code.
Instead we can do it in nfsd4_encode_read as that gets called for all
error cases as well.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4proc.c |  4 ----
 fs/nfsd/nfs4xdr.c  | 22 ++++++++++++++--------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 5aa7c4e..90cfda7 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1723,10 +1723,6 @@ encode_op:
 			be32_to_cpu(status));
 
 		nfsd4_cstate_clear_replay(cstate);
-		/* XXX Ugh, we need to get rid of this kind of special case: */
-		if (op->opnum == OP_READ && op->u.read.rd_filp)
-			fput(op->u.read.rd_filp);
-
 		nfsd4_increment_op_stats(op->opnum);
 	}
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5efef8a..9388a5f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -33,6 +33,7 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <linux/file.h>
 #include <linux/slab.h>
 #include <linux/namei.h>
 #include <linux/statfs.h>
@@ -3420,19 +3421,20 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	int starting_len = xdr->buf->len;
 	struct raparms *ra = NULL;
 	__be32 *p;
-	__be32 err;
 
 	if (nfserr)
-		return nfserr;
+		goto out;
 
 	p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
 	if (!p) {
 		WARN_ON_ONCE(test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags));
-		return nfserr_resource;
+		nfserr = nfserr_resource;
+		goto out;
 	}
 	if (resp->xdr.buf->page_len && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags)) {
 		WARN_ON_ONCE(1);
-		return nfserr_resource;
+		nfserr = nfserr_resource;
+		goto out;
 	}
 	xdr_commit_encode(xdr);
 
@@ -3444,16 +3446,20 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 		ra = nfsd_init_raparms(file);
 
 	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
-		err = nfsd4_encode_splice_read(resp, read, file, maxcount);
+		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
-		err = nfsd4_encode_readv(resp, read, file, maxcount);
+		nfserr = nfsd4_encode_readv(resp, read, file, maxcount);
 
 	if (ra)
 		nfsd_put_raparams(file, ra);
 
-	if (err)
+	if (nfserr)
 		xdr_truncate_encode(xdr, starting_len);
-	return err;
+
+out:
+	if (file)
+		fput(file);
+	return nfserr;
 }
 
 static __be32
-- 
1.9.1

