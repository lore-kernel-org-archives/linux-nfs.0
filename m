Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36100 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEDR5E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 13:57:04 -0400
Subject: [PATCH v1 02/14] xprtrdma: Warn when there are orphaned IB objects
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 13:57:00 -0400
Message-ID: <20150504175700.3483.57728.stgit@manet.1015granger.net>
In-Reply-To: <20150504174626.3483.97639.stgit@manet.1015granger.net>
References: <20150504174626.3483.97639.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Print an error during transport destruction if ib_dealloc_pd()
fails. This is a sign that xprtrdma orphaned one or more RDMA API
objects at some point, which can pin lower layer kernel modules
and cause shutdown to hang.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 4870d27..0cc4617 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -710,8 +710,8 @@ rpcrdma_ia_close(struct rpcrdma_ia *ia)
 	}
 	if (ia->ri_pd != NULL && !IS_ERR(ia->ri_pd)) {
 		rc = ib_dealloc_pd(ia->ri_pd);
-		dprintk("RPC:       %s: ib_dealloc_pd returned %i\n",
-			__func__, rc);
+		if (rc)
+			pr_warn("rpcrdma: ib_dealloc_pd status %i\n", rc);
 	}
 }
 

