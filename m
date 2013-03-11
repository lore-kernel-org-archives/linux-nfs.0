Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:2901 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754767Ab3CKVPV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 17:15:21 -0400
From: Tim Gardner <tim.gardner@canonical.com>
To: linux-kernel@vger.kernel.org
Cc: Tim Gardner <tim.gardner@canonical.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH linux-next v3] SUNRPC: rpcrdma_register_default_external: Dynamically allocate ib_phys_buf
Date: Mon, 11 Mar 2013 15:15:08 -0600
Message-Id: <1363036508-24935-1-git-send-email-tim.gardner@canonical.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286BA156@sacexcmbx05-prd.hq.netapp.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA9286BA156@sacexcmbx05-prd.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcrdma_register_default_external() is several frames into the call stack which
goes deeper yet. You run the risk of stack corruption by declaring such a large
automatic variable, so move the array of 'struct ib_phys_buf' objects into the
transport structure 'struct rpcrdma_xprt' (which is dynamically allocated) in
order to silence the frame-larger-than warning. Access to each struct
rpcrdma_xprt is serialized by XPRT_LOCKED in xprt_reserve_xprt(), so there is
no danger of multiple accessors to the array of struct ib_phys_buf objects.

net/sunrpc/xprtrdma/verbs.c: In function 'rpcrdma_register_default_external':
net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 4.6.3

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Tom Tucker <tom@ogc.us>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
Cc: Shani Michaeli <shanim@mellanox.com>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
v1 - Use kmalloc() to dynamically allocate and free the array of 'struct
ib_phys_buf' objects

v2 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_req
and pass this request down through rpcrdma_register_external() and
rpcrdma_register_default_external(). This is less overhead then using
kmalloc() and requires no extra error checking as the allocation burden is
shifted to the transport client.

v3 - Move the array of 'struct ib_phys_buf' objects into struct rpcrdma_xprt.
Pass a pointer to this transport structure into rpcrdma_register_default_external().
This is less overhead then using kmalloc() and requires no extra error checking
as the allocation burden is shifted to the transport client.

 net/sunrpc/xprtrdma/verbs.c     |   10 ++++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    5 ++++-
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 93726560..c7aa3da 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1730,13 +1730,14 @@ rpcrdma_deregister_memwin_external(struct rpcrdma_mr_seg *seg,
 }
 
 static int
-rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
-			int *nsegs, int writing, struct rpcrdma_ia *ia)
+rpcrdma_register_default_external(struct rpcrdma_xprt *r_xprt,
+			struct rpcrdma_mr_seg *seg, int *nsegs, int writing,
+			struct rpcrdma_ia *ia)
 {
 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
 				  IB_ACCESS_REMOTE_READ);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
+	struct ib_phys_buf *ipb = r_xprt->ipb;
 	int len, i, rc = 0;
 
 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
@@ -1827,7 +1828,8 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 
 	/* Default registration each time */
 	default:
-		rc = rpcrdma_register_default_external(seg, &nsegs, writing, ia);
+		rc = rpcrdma_register_default_external(r_xprt, seg, &nsegs,
+			writing, ia);
 		break;
 	}
 	if (rc)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index cc1445d..d7b440f 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -269,7 +269,8 @@ struct rpcrdma_stats {
  * for convenience. This structure need not be visible externally.
  *
  * It is allocated and initialized during mount, and released
- * during unmount.
+ * during unmount. Access to this structure is serialized by XPRT_LOCKED
+ * in xprt_reserve_xprt().
  */
 struct rpcrdma_xprt {
 	struct rpc_xprt		xprt;
@@ -279,6 +280,8 @@ struct rpcrdma_xprt {
 	struct rpcrdma_create_data_internal rx_data;
 	struct delayed_work	rdma_connect;
 	struct rpcrdma_stats	rx_stats;
+	/* temp work array */
+	struct ib_phys_buf	ipb[RPCRDMA_MAX_DATA_SEGS];
 };
 
 #define rpcx_to_rdmax(x) container_of(x, struct rpcrdma_xprt, xprt)
-- 
1.7.9.5

