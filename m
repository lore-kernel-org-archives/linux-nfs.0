Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f54.google.com ([209.85.213.54]:56938 "EHLO
	mail-yh0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbaDUWJK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 18:09:10 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V2 09/17] xprtrdma: mount reports "Invalid mount option" if
	memreg mode not supported
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 21 Apr 2014 18:02:05 -0400
Message-ID: <20140421220205.12569.42838.stgit@manet.1015granger.net>
In-Reply-To: <20140421214442.12569.8950.stgit@manet.1015granger.net>
References: <20140421214442.12569.8950.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the selected memory registration mode is not supported by the
underlying provider/HCA, the NFS mount command reports that there was
an invalid mount option, and fails. This is misleading.

Reporting a problem allocating memory is a lot closer to the truth.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a352798..35dcd10 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -513,7 +513,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 #if RPCRDMA_PERSISTENT_REGISTRATION
 			memreg = RPCRDMA_ALLPHYSICAL;
 #else
-			rc = -EINVAL;
+			rc = -ENOMEM;
 			goto out2;
 #endif
 		}
@@ -556,7 +556,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 	default:
 		printk(KERN_ERR "%s: invalid memory registration mode %d\n",
 				__func__, memreg);
-		rc = -EINVAL;
+		rc = -ENOMEM;
 		goto out2;
 	}
 	dprintk("RPC:       %s: memory registration strategy is %d\n",

