Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:34165 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186AbaD3Tal (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2014 15:30:41 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V3 08/17] xprtrdma: mount reports "Invalid mount option" if
	memreg mode not supported
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 30 Apr 2014 15:30:38 -0400
Message-ID: <20140430193038.5663.63122.stgit@manet.1015granger.net>
In-Reply-To: <20140430191433.5663.16217.stgit@manet.1015granger.net>
References: <20140430191433.5663.16217.stgit@manet.1015granger.net>
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

