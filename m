Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:46618 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbeACUiT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Jan 2018 15:38:19 -0500
Subject: [PATCH 2/6] xprtrdma: Correct some documenting comments
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 03 Jan 2018 15:38:17 -0500
Message-ID: <20180103203817.29209.49686.stgit@manet.1015granger.net>
In-Reply-To: <20180103203540.29209.4620.stgit@manet.1015granger.net>
References: <20180103203540.29209.4620.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix kernel-doc warnings in net/sunrpc/xprtrdma/ .

net/sunrpc/xprtrdma/verbs.c:1575: warning: No description found for parameter 'count'
net/sunrpc/xprtrdma/verbs.c:1575: warning: Excess function parameter 'min_reqs' description in 'rpcrdma_ep_post_extra_recv'

net/sunrpc/xprtrdma/backchannel.c:288: warning: No description found for parameter 'r_xprt'
net/sunrpc/xprtrdma/backchannel.c:288: warning: Excess function parameter 'xprt' description in 'rpcrdma_bc_receive_call'

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c       |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index ca0c5d3..ed1a4a3 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -294,7 +294,7 @@ void xprt_rdma_bc_free_rqst(struct rpc_rqst *rqst)
 
 /**
  * rpcrdma_bc_receive_call - Handle a backward direction call
- * @xprt: transport receiving the call
+ * @r_xprt: transport receiving the call
  * @rep: receive buffer containing the call
  *
  * Operational assumptions:
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 57e1139..f4eb63e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1584,7 +1584,7 @@ struct rpcrdma_regbuf *
 /**
  * rpcrdma_ep_post_extra_recv - Post buffers for incoming backchannel requests
  * @r_xprt: transport associated with these backchannel resources
- * @min_reqs: minimum number of incoming requests expected
+ * @count: minimum number of incoming requests expected
  *
  * Returns zero if all requested buffers were posted, or a negative errno.
  */

