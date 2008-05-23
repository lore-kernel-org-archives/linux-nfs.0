From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH] svcrdma: Initialize the context free list for listeners
Date: Fri, 23 May 2008 10:32:59 -0500
Message-ID: <1211556779.4114.17.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:53404 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753599AbYEWP3K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2008 11:29:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the initialization of the sc_ctxt_free list to the
client/listener generic bit of the init logic. This is
necessary to avoid a bug check when shutting down a listening
endpoint when list debug is enabled. This bug was introduced
when the context cache was converted to use Linux lists.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 54b2126..2c2f5f6 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -446,7 +446,6 @@ static void create_context_cache(struct svcxprt_rdma *xprt,
 	xprt->sc_ctxt_cnt = 0;
 	atomic_set(&xprt->sc_ctxt_used, 0);
 
-	INIT_LIST_HEAD(&xprt->sc_ctxt_free);
 	for (i = 0; i < ctxt_count; i++) {
 		ctxt = kmalloc(sizeof(*ctxt), GFP_KERNEL);
 		if (ctxt) {
@@ -496,6 +495,7 @@ static struct svcxprt_rdma *rdma_create_xprt(struct svc_serv *serv,
 	atomic_set(&cma_xprt->sc_sq_count, 0);
 	atomic_set(&cma_xprt->sc_ctxt_used, 0);
 
+	INIT_LIST_HEAD(&cma_xprt->sc_ctxt_free);
 	if (!listener) {
 		int reqs = cma_xprt->sc_max_requests;
 		create_context_cache(cma_xprt,

