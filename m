Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33641 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752313AbcJ2CWg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Oct 2016 22:22:36 -0400
Received: by mail-it0-f66.google.com with SMTP id e187so474746itc.0
        for <linux-nfs@vger.kernel.org>; Fri, 28 Oct 2016 19:22:35 -0700 (PDT)
Subject: [PATCH] svcrdma: backchannel cannot share a page for send and rcv
 buffers
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com
Date: Fri, 28 Oct 2016 22:22:33 -0400
Message-ID: <20161029021531.2673.6849.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The underlying transport releases the page pointed to by rq_buffer
during xprt_rdma_bc_send_request. When the backchannel reply arrives,
rq_rbuffer then points to freed memory.

Fixes: 68778945e46f ('SUNRPC: Separate buffer pointers for RPC ...')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

Hi Bruce-

This applies on top of Jeff's recent patch in the same area. It's
an obvious quick fix rather than a deep review of that code path.

I've tested with iozone, git "make test", and some xfstests with
NFSv4.1 / RDMA; I ran into another crasher that is preventing more
extensive testing. The prepare_creds crash has not re-appeared so
far.

I enabled RPC client debugging on the server during these tests to
confirm that the CB_RECALL operations were successful.

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index fc4535e..20027f8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -177,19 +177,26 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 		return -EINVAL;
 	}
 
+	/* svc_rdma_sendto releases this page */
 	page = alloc_page(RPCRDMA_DEF_GFP);
 	if (!page)
 		return -ENOMEM;
-
 	rqst->rq_buffer = page_address(page);
-	rqst->rq_rbuffer = (char *)rqst->rq_buffer + rqst->rq_callsize;
+
+	rqst->rq_rbuffer = kmalloc(rqst->rq_rcvsize, RPCRDMA_DEF_GFP);
+	if (!rqst->rq_rbuffer) {
+		put_page(page);
+		return -ENOMEM;
+	}
 	return 0;
 }
 
 static void
 xprt_rdma_bc_free(struct rpc_task *task)
 {
-	/* No-op: ctxt and page have already been freed. */
+	struct rpc_rqst *rqst = task->tk_rqstp;
+
+	kfree(rqst->rq_rbuffer);
 }
 
 static int

