Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36031 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753105AbdC0Ntw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 09:49:52 -0400
Subject: [PATCH v2 08/13] svcrdma: Report Write/Reply chunk overruns
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 09:48:59 -0400
Message-ID: <20170327134859.5585.54671.stgit@klimt.1015granger.net>
In-Reply-To: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
References: <20170327132329.5585.98465.stgit@klimt.1015granger.net>
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
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   59 ++++++++++++++++++++++++++++++++-
 1 file changed, 57 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index ffe8ab1..3886ec8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -611,6 +611,49 @@ static int svc_rdma_send_reply_msg(struct svcxprt_rdma *rdma,
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
@@ -672,14 +715,14 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 		/* XXX: Presume the client sent only one Write chunk */
 		ret = svc_rdma_send_write_chunk(rdma, wr_lst, &rqstp->rq_res);
 		if (ret < 0)
-			goto err1;
+			goto err2;
 		svc_rdma_xdr_encode_write_list(rdma_resp, wr_lst, ret);
 	}
 	if (rp_ch) {
 		ret = svc_rdma_send_reply_chunk(rdma, rp_ch, wr_lst != NULL,
 						&rqstp->rq_res);
 		if (ret < 0)
-			goto err1;
+			goto err2;
 		svc_rdma_xdr_encode_reply_chunk(rdma_resp, rp_ch, ret);
 	}
 
@@ -692,6 +735,18 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
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

