Return-Path: linux-nfs-owner@vger.kernel.org
Received: from perches-mx.perches.com ([206.117.179.246]:44975 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755315Ab3AGTlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2013 14:41:36 -0500
Message-ID: <1357587696.21481.48.camel@joe-AO722>
Subject: [PATCH] sunrpc: verbs: Avoid 1kb stack
From: Joe Perches <joe@perches.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 07 Jan 2013 11:41:36 -0800
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

16 * 64 is a bit much.
Use kmalloc_array instead.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/xprtrdma/verbs.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 745973b..9cfebb4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1736,8 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
 				  IB_ACCESS_REMOTE_READ);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
 	int len, i, rc = 0;
+	struct ib_phys_buf *ipb = kmalloc_array(RPCRDMA_MAX_DATA_SEGS,
+						sizeof(*ipb),
+						GFP_KERNEL);
+
+	if (!ipb)
+		return -ENOMEM;
 
 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
 		*nsegs = RPCRDMA_MAX_DATA_SEGS;
@@ -1770,6 +1775,9 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 		seg1->mr_len = len;
 	}
 	*nsegs = i;
+
+	kfree(ipb);
+
 	return rc;
 }
 


