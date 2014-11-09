Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:64628 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbaKIBOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:14:14 -0500
Subject: [PATCH v2 01/10] xprtrdma: Return an errno from
 rpcrdma_register_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:14:12 -0500
Message-ID: <20141109011412.8806.20205.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA send_request method and the chunk registration code
expects an errno from the registration function. This allows
the upper layers to distinguish between a recoverable failure
(for example, temporary memory exhaustion) and a hard failure
(for example, a bug in the registration logic).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 61c4129..6ea2942 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1918,10 +1918,10 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 		break;
 
 	default:
-		return -1;
+		return -EIO;
 	}
 	if (rc)
-		return -1;
+		return rc;
 
 	return nsegs;
 }

