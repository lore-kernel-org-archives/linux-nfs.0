Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:53926 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbbAZWLt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jan 2015 17:11:49 -0500
Received: by mail-ig0-f175.google.com with SMTP id hn18so959187igb.2
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2015 14:11:49 -0800 (PST)
Subject: [PATCH] xprtrdma: Update the GFP flags used in xprt_rdma_allocate()
From: Chuck Lever <chuck.lever@oracle.com>
To: Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 26 Jan 2015 17:11:47 -0500
Message-ID: <20150126220921.29131.70826.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reflect the more conservative approach used in the socket transport's
version of this transport method. An RPC buffer allocation should
avoid forcing not just FS activity, but any I/O.

In particular, two recent changes missed updating xprtrdma:

 - Commit c6c8fe79a83e ("net, sunrpc: suppress allocation warning ...")
 - Commit a564b8f03986 ("nfs: enable swap on NFS")

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

Hi Anna-

Could you append this after my recent NFS/RDMA client patches for 3.20 ?
Thanks!

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 2c2fabe..2e192ba 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -463,13 +463,16 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
 	size_t min_size;
-	gfp_t flags = task->tk_flags & RPC_TASK_SWAPPER ?
-						GFP_ATOMIC : GFP_NOFS;
+	gfp_t flags;
 
 	req = rpcrdma_buffer_get(&r_xprt->rx_buf);
 	if (req == NULL)
 		return NULL;
 
+	flags = GFP_NOIO | __GFP_NOWARN;
+	if (RPC_IS_SWAPPER(task))
+		flags = __GFP_MEMALLOC | GFP_NOWAIT | __GFP_NOWARN;
+
 	if (req->rl_rdmabuf == NULL)
 		goto out_rdmabuf;
 	if (req->rl_sendbuf == NULL)

