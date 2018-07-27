Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:32962 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730395AbeG0QlT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2018 12:41:19 -0400
Subject: [PATCH v1 1/4] svcrdma: Avoid releasing a page in svc_xprt_release()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 27 Jul 2018 11:18:54 -0400
Message-ID: <20180727151854.21878.21860.stgit@klimt.1015granger.net>
In-Reply-To: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_xprt_release() invokes svc_free_res_pages(), which releases
pages between rq_respages and rq_next_page.

Historically, the RPC/RDMA transport has set these two pointers to
be different by one, which means:

- one page gets released when svc_recv returns 0. This normally
happens whenever one or more RDMA Reads need to be dispatched to
complete construction of an RPC Call.

- one page gets released after every call to svc_send.

In both cases, this released page is immediately refilled by
svc_alloc_arg. There does not seem to be a reason for releasing this
page.

To avoid this unnecessary memory allocator traffic, set rq_next_page
more carefully.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    9 ++++++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   |    4 +++-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 841fca1..ddb7def 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -366,9 +366,6 @@ static void svc_rdma_build_arg_xdr(struct svc_rqst *rqstp,
 	arg->page_base = 0;
 	arg->buflen = ctxt->rc_byte_len;
 	arg->len = ctxt->rc_byte_len;
-
-	rqstp->rq_respages = &rqstp->rq_pages[0];
-	rqstp->rq_next_page = rqstp->rq_respages + 1;
 }
 
 /* This accommodates the largest possible Write chunk,
@@ -730,6 +727,12 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 
 	svc_rdma_build_arg_xdr(rqstp, ctxt);
 
+	/* Prevent svc_xprt_release from releasing pages in rq_pages
+	 * if we return 0 or an error.
+	 */
+	rqstp->rq_respages = rqstp->rq_pages;
+	rqstp->rq_next_page = rqstp->rq_respages;
+
 	p = (__be32 *)rqstp->rq_arg.head[0].iov_base;
 	ret = svc_rdma_xdr_decode_req(&rqstp->rq_arg);
 	if (ret < 0)
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 4a3efae..b958fb6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -657,7 +657,9 @@ static void svc_rdma_save_io_pages(struct svc_rqst *rqstp,
 		ctxt->sc_pages[i] = rqstp->rq_respages[i];
 		rqstp->rq_respages[i] = NULL;
 	}
-	rqstp->rq_next_page = rqstp->rq_respages + 1;
+
+	/* Prevent svc_xprt_release from releasing pages in rq_pages */
+	rqstp->rq_next_page = rqstp->rq_respages;
 }
 
 /* Prepare the portion of the RPC Reply that will be transmitted

