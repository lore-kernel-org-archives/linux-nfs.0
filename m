Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([74.45.170.26]:58382 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753068AbaDRUKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 16:10:17 -0400
From: Tim Gardner <tim.gardner@canonical.com>
To: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: Tim Gardner <tim.gardner@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>
Subject: [PATCH net-next] xprtrdma: rpcrdma_register_default_external: Silence frame size warning
Date: Fri, 18 Apr 2014 13:50:25 -0600
Message-Id: <1397850625-44074-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

net/sunrpc/xprtrdma/verbs.c: In function 'rpcrdma_register_default_external':
net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1048 bytes is larger than 1024 bytes [-Wframe-larger-than=]

gcc version 4.8.2, x86_64-linux-gnu

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 net/sunrpc/xprtrdma/verbs.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 93726560..8130349 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1736,9 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
 				  IB_ACCESS_REMOTE_READ);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
+	struct ib_phys_buf *ipb;
 	int len, i, rc = 0;
 
+	ipb = kmalloc(sizeof(*ipb) * RPCRDMA_MAX_DATA_SEGS, GFP_ATOMIC);
+	if (!ipb)
+		return -ENOMEM;
+
 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
 		*nsegs = RPCRDMA_MAX_DATA_SEGS;
 	for (len = 0, i = 0; i < *nsegs;) {
@@ -1770,6 +1774,8 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 		seg1->mr_len = len;
 	}
 	*nsegs = i;
+
+	kfree(ipb);
 	return rc;
 }
 
-- 
1.7.9.5

