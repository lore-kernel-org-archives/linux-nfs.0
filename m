Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36714 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753099AbdC0Ntw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 09:49:52 -0400
Subject: [PATCH v2 04/13] svcrdma: Add helper to save pages under I/O
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 09:48:27 -0400
Message-ID: <20170327134827.5585.57220.stgit@klimt.1015granger.net>
In-Reply-To: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: extract the logic to save pages under I/O into a helper to
add a big documenting comment without adding clutter in the send
path.

This is a refactoring change only.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   31 ++++++++++++++++++-------------
 1 file changed, 18 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 0e55b34..b4028bc3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -478,6 +478,23 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 	return -EIO;
 }
 
+/* The svc_rqst and all resources it owns are released as soon as
+ * svc_rdma_sendto returns. Transfer pages under I/O to the ctxt
+ * so they are released by the Send completion handler.
+ */
+static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
+				   struct svc_rdma_op_ctxt *ctxt)
+{
+	int i, pages = rqstp->rq_next_page - rqstp->rq_respages;
+
+	ctxt->count += pages;
+	for (i = 0; i < pages; i++) {
+		ctxt->pages[i + 1] = rqstp->rq_respages[i];
+		rqstp->rq_respages[i] = NULL;
+	}
+	rqstp->rq_next_page = rqstp->rq_respages + 1;
+}
+
 /**
  * svc_rdma_build_send_wr - Set up a Send Work Request
  * @ctxt: op_ctxt for transmitting the Send WR
@@ -529,8 +546,6 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	u32 xdr_off;
 	int sge_no;
 	int sge_bytes;
-	int page_no;
-	int pages;
 	int ret = -EIO;
 
 	/* Prepare the context */
@@ -573,17 +588,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 		goto err;
 	}
 
-	/* Save all respages in the ctxt and remove them from the
-	 * respages array. They are our pages until the I/O
-	 * completes.
-	 */
-	pages = rqstp->rq_next_page - rqstp->rq_respages;
-	for (page_no = 0; page_no < pages; page_no++) {
-		ctxt->pages[page_no+1] = rqstp->rq_respages[page_no];
-		ctxt->count++;
-		rqstp->rq_respages[page_no] = NULL;
-	}
-	rqstp->rq_next_page = rqstp->rq_respages + 1;
+	svc_rdma_save_io_pages(rqstp, ctxt);
 
 	if (sge_no > rdma->sc_max_sge) {
 		pr_err("svcrdma: Too many sges (%d)\n", sge_no);

