Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34775 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933980AbcK2QFS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 11:05:18 -0500
Subject: [PATCH v3 07/10] svcrdma: Remove unused variables in
 xprt_rdma_bc_allocate()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 29 Nov 2016 11:05:15 -0500
Message-ID: <20161129160515.4477.20367.stgit@klimt.1015granger.net>
In-Reply-To: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
References: <20161129155521.4477.53561.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

/linux-2.6/net/sunrpc/xprtrdma/svc_rdma_backchannel.c: In function
 ‘xprt_rdma_bc_allocate’:
linux-2.6/net/sunrpc/xprtrdma/svc_rdma_backchannel.c:169:23: warning:
 variable ‘rdma’ set but not used [-Wunused-but-set-variable]
  struct svcxprt_rdma *rdma;
                       ^

Fixes: 5d252f90a800 ("svcrdma: Add class for RDMA backwards ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 6035c5a..288e35c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -164,13 +164,9 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 xprt_rdma_bc_allocate(struct rpc_task *task)
 {
 	struct rpc_rqst *rqst = task->tk_rqstp;
-	struct svc_xprt *sxprt = rqst->rq_xprt->bc_xprt;
 	size_t size = rqst->rq_callsize;
-	struct svcxprt_rdma *rdma;
 	struct page *page;
 
-	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
-
 	if (size > PAGE_SIZE) {
 		WARN_ONCE(1, "svcrdma: large bc buffer request (size %zu)\n",
 			  size);

