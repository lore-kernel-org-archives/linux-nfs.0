Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35759 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751742AbeEDTfc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:35:32 -0400
Subject: [PATCH v1 12/19] xprtrdma: Remove rpcrdma_buffer_get_req_locked()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:35:31 -0400
Message-ID: <20180504193530.31688.72972.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up. There is only one call-site for this helper, and it can be
simplified by using list_first_entry_or_null().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9c35540..3edf5c4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1175,17 +1175,6 @@ struct rpcrdma_req *
 	return rc;
 }
 
-static struct rpcrdma_req *
-rpcrdma_buffer_get_req_locked(struct rpcrdma_buffer *buf)
-{
-	struct rpcrdma_req *req;
-
-	req = list_first_entry(&buf->rb_send_bufs,
-			       struct rpcrdma_req, rl_list);
-	list_del_init(&req->rl_list);
-	return req;
-}
-
 static struct rpcrdma_rep *
 rpcrdma_buffer_get_rep_locked(struct rpcrdma_buffer *buf)
 {
@@ -1356,15 +1345,12 @@ struct rpcrdma_req *
 	struct rpcrdma_req *req;
 
 	spin_lock(&buffers->rb_lock);
-	if (unlikely(list_empty(&buffers->rb_send_bufs)))
-		goto out_noreqs;
-	req = rpcrdma_buffer_get_req_locked(buffers);
+	req = list_first_entry_or_null(&buffers->rb_send_bufs,
+				       struct rpcrdma_req, rl_list);
+	if (req)
+		list_del_init(&req->rl_list);
 	spin_unlock(&buffers->rb_lock);
 	return req;
-
-out_noreqs:
-	spin_unlock(&buffers->rb_lock);
-	return NULL;
 }
 
 /**

