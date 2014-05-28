Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:62632 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbaE1OdB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:33:01 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 08/24] xprtrdma: mount reports "Invalid mount option" if
	memreg mode not supported
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:33:00 -0400
Message-ID: <20140528143259.23214.36490.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
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

 net/sunrpc/xprtrdma/verbs.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index a352798..7c7e9b4 100644
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
@@ -554,9 +554,9 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		}
 		break;
 	default:
-		printk(KERN_ERR "%s: invalid memory registration mode %d\n",
-				__func__, memreg);
-		rc = -EINVAL;
+		printk(KERN_ERR "RPC: Unsupported memory "
+				"registration mode: %d\n", memreg);
+		rc = -ENOMEM;
 		goto out2;
 	}
 	dprintk("RPC:       %s: memory registration strategy is %d\n",

