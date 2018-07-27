Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44046 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730395AbeG0QlY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 12:41:24 -0400
Subject: [PATCH v1 2/4] svcrdma: Clean up Read chunk path
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Jul 2018 11:18:59 -0400
Message-ID: <20180727151859.21878.9016.stgit@klimt.1015granger.net>
In-Reply-To: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simplify the error handling at the tail of recv_read_chunk() by
re-arranging rq_pages[] housekeeping and documenting it properly.

NB: In this path, svc_rdma_recvfrom returns zero. Therefore no
subsequent reply processing is done on the svc_rqstp, and thus the
rq_respages field does not need to be updated.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c |   32 +++++++++++++-------------------
 1 file changed, 13 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index ce3ea84..a1ac999 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -679,6 +679,7 @@ static int svc_rdma_build_read_chunk(struct svc_rqst *rqstp,
 				     struct svc_rdma_read_info *info,
 				     __be32 *p)
 {
+	unsigned int i;
 	int ret;
 
 	ret = -EINVAL;
@@ -701,6 +702,12 @@ static int svc_rdma_build_read_chunk(struct svc_rqst *rqstp,
 		info->ri_chunklen += rs_length;
 	}
 
+	/* Pages under I/O have been copied to head->rc_pages.
+	 * Prevent their premature release by svc_xprt_release() .
+	 */
+	for (i = 0; i < info->ri_readctxt->rc_page_count; i++)
+		rqstp->rq_pages[i] = NULL;
+
 	return ret;
 }
 
@@ -816,7 +823,6 @@ int svc_rdma_recv_read_chunk(struct svcxprt_rdma *rdma, struct svc_rqst *rqstp,
 			     struct svc_rdma_recv_ctxt *head, __be32 *p)
 {
 	struct svc_rdma_read_info *info;
-	struct page **page;
 	int ret;
 
 	/* The request (with page list) is constructed in
@@ -843,27 +849,15 @@ int svc_rdma_recv_read_chunk(struct svcxprt_rdma *rdma, struct svc_rqst *rqstp,
 		ret = svc_rdma_build_normal_read_chunk(rqstp, info, p);
 	else
 		ret = svc_rdma_build_pz_read_chunk(rqstp, info, p);
-
-	/* Mark the start of the pages that can be used for the reply */
-	if (info->ri_pageoff > 0)
-		info->ri_pageno++;
-	rqstp->rq_respages = &rqstp->rq_pages[info->ri_pageno];
-	rqstp->rq_next_page = rqstp->rq_respages + 1;
-
 	if (ret < 0)
-		goto out;
+		goto out_err;
 
 	ret = svc_rdma_post_chunk_ctxt(&info->ri_cc);
-
-out:
-	/* Read sink pages have been moved from rqstp->rq_pages to
-	 * head->rc_arg.pages. Force svc_recv to refill those slots
-	 * in rq_pages.
-	 */
-	for (page = rqstp->rq_pages; page < rqstp->rq_respages; page++)
-		*page = NULL;
-
 	if (ret < 0)
-		svc_rdma_read_info_free(info);
+		goto out_err;
+	return 0;
+
+out_err:
+	svc_rdma_read_info_free(info);
 	return ret;
 }

