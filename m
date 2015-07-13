Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33687 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751327AbbGMQaX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 12:30:23 -0400
Subject: [PATCH v2 04/14] xprtrdma: Don't fall back to PHYSICAL memory
 registration
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Jul 2015 12:30:19 -0400
Message-ID: <20150713163019.17630.91612.stgit@manet.1015granger.net>
In-Reply-To: <20150713160617.17630.97475.stgit@manet.1015granger.net>
References: <20150713160617.17630.97475.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PHYSICAL memory registration uses a single rkey for all of the
client's memory, thus is insecure. It is still useful in some cases
for testing.

Retain the ability to select PHYSICAL memory registration capability
via /proc/sys/sunrpc/rdma_memreg_strategy, but don't fall back to it
if the HCA does not support FRWR or FMR.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 891c4ed..1065808 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -539,7 +539,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
 		if (!ia->ri_device->alloc_fmr) {
 			dprintk("RPC:       %s: MTHCAFMR registration "
 				"not supported by HCA\n", __func__);
-			memreg = RPCRDMA_ALLPHYSICAL;
+			goto out3;
 		}
 	}
 

