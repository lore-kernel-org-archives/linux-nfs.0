Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754931AbaEKUwz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 May 2014 16:52:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/43] nfsd4: move proc_compound xdr encode init to helper
Date: Sun, 11 May 2014 16:52:08 -0400
Message-Id: <1399841568-19716-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1399841568-19716-1-git-send-email-bfields@redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Mechanical transformation with no change of behavior.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 1499aa4..6c049c4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1251,6 +1251,17 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 	return !(nextd->op_flags & OP_HANDLES_WRONGSEC);
 }
 
+static void svcxdr_init_encode(struct svc_rqst *rqstp, struct nfsd4_compoundres *resp)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct xdr_buf *buf = &rqstp->rq_res;
+	struct kvec *head = buf->head;
+
+	xdr->buf = buf;
+	xdr->p   = head->iov_base + head->iov_len;
+	xdr->end = head->iov_base + PAGE_SIZE;
+}
+
 /*
  * COMPOUND call.
  */
@@ -1268,13 +1279,10 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	u32		plen = 0;
 	__be32		status;
 
-	resp->xdr.buf = &rqstp->rq_res;
-	resp->xdr.p = rqstp->rq_res.head[0].iov_base +
-						rqstp->rq_res.head[0].iov_len;
+	svcxdr_init_encode(rqstp, resp);
 	resp->tagp = resp->xdr.p;
 	/* reserve space for: taglen, tag, and opcnt */
 	resp->xdr.p += 2 + XDR_QUADLEN(args->taglen);
-	resp->xdr.end = rqstp->rq_res.head[0].iov_base + PAGE_SIZE;
 	resp->taglen = args->taglen;
 	resp->tag = args->tag;
 	resp->opcnt = 0;
-- 
1.7.9.5

