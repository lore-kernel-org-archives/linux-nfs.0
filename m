Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:54848 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751747AbeEDTfi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:38 -0400
Subject: [PATCH v1 13/19] xprtrdma: Remove rpcrdma_buffer_get_rep_locked()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:36 -0400
Message-ID: <20180504193536.31688.20538.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: There is only one remaining call site for this helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 3edf5c4..3cada42 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1175,17 +1175,6 @@ struct rpcrdma_req *
 	return rc;
 }
 
-static struct rpcrdma_rep *
-rpcrdma_buffer_get_rep_locked(struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_rep *rep;
-
-	rep = list_first_entry(&buf->rb_recv_bufs,
-			       struct rpcrdma_rep, rr_list);
-	list_del(&rep->rr_list);
-	return rep;
-}
-
 static void
 rpcrdma_destroy_rep(struct rpcrdma_rep *rep)
 {
@@ -1244,7 +1233,9 @@ struct rpcrdma_req *
 	while (!list_empty(&buf->rb_recv_bufs)) {
 		struct rpcrdma_rep *rep;
 
-		rep = rpcrdma_buffer_get_rep_locked(buf);
+		rep = list_first_entry(&buf->rb_recv_bufs,
+				       struct rpcrdma_rep, rr_list);
+		list_del(&rep->rr_list);
 		rpcrdma_destroy_rep(rep);
 	}
 

