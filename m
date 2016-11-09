Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35416 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752259AbcKITFk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 14:05:40 -0500
Subject: [PATCH v1 06/14] xprtrdma: Address coverity complaint about
 wait_for_completion()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 09 Nov 2016 14:05:38 -0500
Message-ID: <20161109190538.15007.22961.stgit@manet.1015granger.net>
In-Reply-To: <20161109184735.15007.96507.stgit@manet.1015granger.net>
References: <20161109184735.15007.96507.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> ** CID 114101:  Error handling issues  (CHECKED_RETURN)
> /net/sunrpc/xprtrdma/verbs.c: 355 in rpcrdma_create_id()

Commit 5675add36e76 ("RPC/RDMA: harden connection logic against
missing/late rdma_cm upcalls.") replaced wait_for_completion() calls
with these two call sites.

The original wait_for_completion() calls were added in the initial
commit of verbs.c, which was commit c56c65fb67d6 ("RPCRDMA: rpc rdma
verbs interface implementation"), but these returned void.

rpcrdma_create_id() is called by the RDMA connect worker, which
probably won't ever be interrupted. It is also called by
rpcrdma_ia_open which is in the synchronous mount path, and ^C is
possible there.

Add a bit of logic at those two call sites to return if the waits
return ERESTARTSYS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 451f5f2..cbb1885 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -331,6 +331,7 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 			struct rpcrdma_ia *ia, struct sockaddr *addr)
 {
+	unsigned long wtimeout = msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1;
 	struct rdma_cm_id *id;
 	int rc;
 
@@ -352,8 +353,12 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 			__func__, rc);
 		goto out;
 	}
-	wait_for_completion_interruptible_timeout(&ia->ri_done,
-				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
+	if (rc < 0) {
+		dprintk("RPC:       %s: wait() exited: %i\n",
+			__func__, rc);
+		goto out;
+	}
 
 	/* FIXME:
 	 * Until xprtrdma supports DEVICE_REMOVAL, the provider must
@@ -376,8 +381,12 @@ static void rpcrdma_destroy_id(struct rdma_cm_id *id)
 			__func__, rc);
 		goto put;
 	}
-	wait_for_completion_interruptible_timeout(&ia->ri_done,
-				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+	rc = wait_for_completion_interruptible_timeout(&ia->ri_done, wtimeout);
+	if (rc < 0) {
+		dprintk("RPC:       %s: wait() exited: %i\n",
+			__func__, rc);
+		goto put;
+	}
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto put;

