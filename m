Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:37483 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754365AbdJIQD2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Oct 2017 12:03:28 -0400
Subject: [PATCH v1 1/3] xprtrdma: Don't defer fencing an async RPC's chunks
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 09 Oct 2017 12:03:26 -0400
Message-ID: <20171009160326.18726.9300.stgit@manet.1015granger.net>
In-Reply-To: <20171009155524.18726.32086.stgit@manet.1015granger.net>
References: <20171009155524.18726.32086.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In current kernels, waiting in xprt_release appears to be safe to
do. I had erroneously believed that for ASYNC RPCs, waiting of any
kind in xprt_release->xprt_rdma_free would result in deadlock. I've
done injection testing and consulted with Trond to confirm that
waiting in the RPC release path is safe.

For the very few times where RPC resources haven't yet been released
earlier by the reply handler, it is safe to wait synchronously in
xprt_rdma_free for invalidation rather than defering it to MR
recovery.

Note: When the QP is error state, posting a LocalInvalidate should
flush and mark the MR as bad. There is no way the remote HCA can
access that MR via a QP in error state, so it is effectively already
inaccessible and thus safe for the Upper Layer to access. The next
time the MR is used it should be recognized and cleaned up properly
by frwr_op_map.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index c84e2b6..8cf5ccf 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -686,7 +686,7 @@
 	dprintk("RPC:       %s: called on 0x%p\n", __func__, req->rl_reply);
 
 	if (!list_empty(&req->rl_registered))
-		ia->ri_ops->ro_unmap_safe(r_xprt, req, !RPC_IS_ASYNC(task));
+		ia->ri_ops->ro_unmap_sync(r_xprt, &req->rl_registered);
 	rpcrdma_unmap_sges(ia, req);
 	rpcrdma_buffer_put(req);
 }

