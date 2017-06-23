Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36458 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754340AbdFWVR3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jun 2017 17:17:29 -0400
Subject: [PATCH v3 03/18] svcrdma: Avoid Send Queue overflow
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 23 Jun 2017 17:17:24 -0400
Message-ID: <20170623211723.5162.43419.stgit@klimt.1015granger.net>
In-Reply-To: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
References: <20170623211150.5162.59075.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sanity case: Catch the case where more Work Requests are being
posted to the Send Queue than there are Send Queue Entries.

This might happen if a client sends a chunk with more segments than
there are SQEs for the transport. The server can't send that reply,
so the transport will deadlock unless the client drops the RPC.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c     |    5 +++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |    2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 0cf6202..3b35364 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -232,6 +232,9 @@ static int svc_rdma_post_chunk_ctxt(struct svc_rdma_chunk_ctxt *cc)
 	struct ib_cqe *cqe;
 	int ret;
 
+	if (cc->cc_sqecount > rdma->sc_sq_depth)
+		return -EINVAL;
+
 	first_wr = NULL;
 	cqe = &cc->cc_cqe;
 	list_for_each(tmp, &cc->cc_rwctxts) {
@@ -425,6 +428,7 @@ static int svc_rdma_send_xdr_pagelist(struct svc_rdma_write_info *info,
  *
  * Returns a non-negative number of bytes the chunk consumed, or
  *	%-E2BIG if the payload was larger than the Write chunk,
+ *	%-EINVAL if client provided too many segments,
  *	%-ENOMEM if rdma_rw context pool was exhausted,
  *	%-ENOTCONN if posting failed (connection is lost),
  *	%-EIO if rdma_rw initialization failed (DMA mapping, etc).
@@ -465,6 +469,7 @@ int svc_rdma_send_write_chunk(struct svcxprt_rdma *rdma, __be32 *wr_ch,
  *
  * Returns a non-negative number of bytes the chunk consumed, or
  *	%-E2BIG if the payload was larger than the Reply chunk,
+ *	%-EINVAL if client provided too many segments,
  *	%-ENOMEM if rdma_rw context pool was exhausted,
  *	%-ENOTCONN if posting failed (connection is lost),
  *	%-EIO if rdma_rw initialization failed (DMA mapping, etc).
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 5ba6d91..19fd01e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -684,7 +684,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
 	return 0;
 
  err2:
-	if (ret != -E2BIG)
+	if (ret != -E2BIG || ret != -EINVAL)
 		goto err1;
 
 	ret = svc_rdma_post_recv(rdma, GFP_KERNEL);

