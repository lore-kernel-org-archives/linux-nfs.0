Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:61354 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbdEVUYl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 16:24:41 -0400
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "David S. Miller" <davem@davemloft.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] xprtrdma: Delete an error message for a failed memory
 allocation in xprt_rdma_bc_setup()
Message-ID: <3c3f0067-1438-129c-d921-e2c056d5776b@users.sourceforge.net>
Date: Mon, 22 May 2017 22:24:17 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 22:18:28 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sunrpc/xprtrdma/backchannel.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 24fedd4b117e..03f6b5840764 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -119,11 +119,9 @@ int xprt_rdma_bc_setup(struct rpc_xprt *xprt, unsigned int reqs)
 
 	for (i = 0; i < (reqs << 1); i++) {
 		rqst = kzalloc(sizeof(*rqst), GFP_KERNEL);
-		if (!rqst) {
-			pr_err("RPC:       %s: Failed to create bc rpc_rqst\n",
-			       __func__);
+		if (!rqst)
 			goto out_free;
-		}
+
 		dprintk("RPC:       %s: new rqst %p\n", __func__, rqst);
 
 		rqst->rq_xprt = &r_xprt->rx_xprt;
-- 
2.13.0

