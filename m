Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34627 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754375AbdCPPxi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 11:53:38 -0400
Subject: [PATCH v1 08/14] svcrdma: Report Write/Reply chunk overruns
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 16 Mar 2017 11:53:31 -0400
Message-ID: <20170316155331.4482.7734.stgit@klimt.1015granger.net>
In-Reply-To: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
References: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Observed at Connectathon 2017.

If a client has underestimated the size of a Write or Reply chunk,
the Linux server writes as much payload data as it can, then it
recognizes there was a problem and closes the connection without
sending the transport header.

This creates a couple of problems:

<> The client never receives indication of the server-side failure,
   so it continues to retransmit the bad RPC. Forward progress on
   the transport is blocked.

<> The reply payload pages are not moved out of the svc_rqst, thus
   they can be released by the RPC server before the RDMA Writes
   have completed.

The new rdma_rw-ized helpers return a distinct error code when a
Write/Reply chunk overrun occurs, so it's now easy for the caller
(svc_rdma_sendto) to recognize this case.

Instead of dropping the connection, post an RDMA_ERROR message. The
client now sees an RDMA_ERROR and can properly terminate the RPC
transaction.

As part of the new logic, set up the same delayed release for these
payload pages as would have occurred in the normal case.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   59 ++++++++++++++++++++++++++++++++-
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 1b230dc..489e602 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -484,6 +484,49 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
 	return ret;
 }
 
+/* Given the client-provided Write and Reply chunks, the server was not
+ * able to form a complete reply. Return an RDMA_ERROR message so the
+ * client can retire this RPC transaction. As above, the Send completion
+ * routine releases payload pages that were part of a previous RDMA Write.
+ *
+ * Remote Invalidation is skipped for simplicity.
+ */
+static int svc_rdma_send_error_msg(struct svcxprt_rdma *rdma,
+				   __be32 *rdma_resp, struct svc_rqst *rqstp)
+{
+	struct svc_rdma_op_ctxt *ctxt;
+	__be32 *p;
+	int ret;
+
+	ctxt = svc_rdma_get_context(rdma);
+
+	/* Replace the original transport header with an
+	 * RDMA_ERROR response. XID etc are preserved.
+	 */
+	p = rdma_resp + 3;
+	*p++ = rdma_error;
+	*p   = err_chunk;
+
+	ret = svc_rdma_map_reply_hdr(rdma, ctxt, rdma_resp, 20);
+	if (ret < 0)
+		goto err;
+
+	svc_rdma_save_io_pages(rqstp, ctxt);
+
+	svc_rdma_build_send_wr(ctxt, 1 + ret);
+	ret = svc_rdma_send(rdma, &ctxt->send_wr);
+	if (ret)
+		goto err;
+
+	return 0;
+
+err:
+	pr_err("svcrdma: failed to post Send WR (%d)\n", ret);
+	svc_rdma_unmap_dma(ctxt);
+	svc_rdma_put_context(ctxt, 1);
+	return ret;
+}
+
 void svc_rdma_prep_reply_hdr(struct svc_rqst *rqstp)
 {
 }
@@ -545,13 +588,13 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		ret = svc_rdma_send_write_list(rdma, wr_lst, rdma_resp,
 					       &rqstp->rq_res);
 		if (ret < 0)
-			goto err1;
+			goto err2;
 	}
 	if (rp_ch) {
 		ret = svc_rdma_send_reply_chunk(rdma, wr_lst, rp_ch,
 						rdma_resp, &rqstp->rq_res);
 		if (ret < 0)
-			goto err1;
+			goto err2;
 	}
 
 	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
@@ -563,6 +606,18 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		goto err0;
 	return 0;
 
+ err2:
+	if (ret != -E2BIG)
+		goto err1;
+
+	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);
+	if (ret)
+		goto err1;
+	ret = svc_rdma_send_error_msg(rdma, rdma_resp, rqstp);
+	if (ret < 0)
+		goto err0;
+	return 0;
+
  err1:
 	put_page(res_page);
  err0:

