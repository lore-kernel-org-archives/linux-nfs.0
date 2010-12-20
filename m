Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17919 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214Ab0LTWKf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Dec 2010 17:10:35 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V5 02/11] SUNRPC fix bc_send print
Date: Mon, 20 Dec 2010 16:04:39 -0500
Message-Id: <1292879088-7821-3-git-send-email-andros@netapp.com>
In-Reply-To: <1292879088-7821-2-git-send-email-andros@netapp.com>
References: <1292879088-7821-1-git-send-email-andros@netapp.com>
 <1292879088-7821-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/bc_svc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
index 7dcfe0c..1dd1a68 100644
--- a/net/sunrpc/bc_svc.c
+++ b/net/sunrpc/bc_svc.c
@@ -59,8 +59,8 @@ int bc_send(struct rpc_rqst *req)
 		ret = task->tk_status;
 		rpc_put_task(task);
 	}
-	return ret;
 	dprintk("RPC:       bc_send ret= %d\n", ret);
+	return ret;
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
1.6.6

