Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:52330 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935828Ab2KAPV5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Nov 2012 11:21:57 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] SUNRPC: return proper errno from backchannel_rqst
Date: Thu,  1 Nov 2012 11:21:53 -0400
Message-Id: <1351783313-39826-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The one and only caller (in fs/nfs/nfs4client.c) uses the result
as an errno and would have interpreted an error as EPERM.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/backchannel_rqst.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 5a3d675..a9c0bbc 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -172,7 +172,7 @@ out_free:
 		xprt_free_allocation(req);
 
 	dprintk("RPC:       setup backchannel transport failed\n");
-	return -1;
+	return -ENOMEM;
 }
 EXPORT_SYMBOL_GPL(xprt_setup_backchannel);
 
-- 
1.7.9.6 (Apple Git-31.1)

