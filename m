Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cpsmtpb-ews03.kpnxchange.com ([213.75.39.6]:50911 "EHLO
	cpsmtpb-ews03.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753243AbaAMQBG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 11:01:06 -0500
Message-ID: <1389627955.20467.9.camel@x41>
Subject: [PATCH] xprtrdma: silence frame size warning
From: Paul Bolle <pebolle@tiscali.nl>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Mon, 13 Jan 2014 16:45:55 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Building verbs.o on 32 bits x86, with CONFIG_FRAME_WARN set to 1024, its
default value, triggers this GCC warning:
    net/sunrpc/xprtrdma/verbs.c: In function ‘rpcrdma_register_default_external’:
    net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1040 bytes is larger than 1024 bytes [-Wframe-larger-than=]

Silence this warning by allocating "ipb" dynamically.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
0) Compile tested only (on 32 bits x86). I don't have access to
Infiniband hardware.

1) Please note that this is not a new warning. The oldest build log I
have still available on this machine is for a v3.8 rc, and it already
showed this warning. 

2) I do hope my choice for the GFP_KERNEL flag is correct here.

 net/sunrpc/xprtrdma/verbs.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 93726560..939ccc8 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1736,11 +1736,14 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
 				  IB_ACCESS_REMOTE_READ);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
+	struct ib_phys_buf *ipb;
 	int len, i, rc = 0;
 
 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
 		*nsegs = RPCRDMA_MAX_DATA_SEGS;
+	ipb = kmalloc(sizeof(*ipb) * *nsegs, GFP_KERNEL);
+	if (ipb == NULL)
+		return -ENOMEM;
 	for (len = 0, i = 0; i < *nsegs;) {
 		rpcrdma_map_one(ia, seg, writing);
 		ipb[i].addr = seg->mr_dma;
@@ -1770,6 +1773,7 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 		seg1->mr_len = len;
 	}
 	*nsegs = i;
+	kfree(ipb);
 	return rc;
 }
 
-- 
1.8.4.2

