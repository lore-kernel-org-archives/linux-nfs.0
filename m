Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9530 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752532Ab1ADRLH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 12:11:07 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH_V6 02/11] SUNRPC fix bc_send print
Date: Tue,  4 Jan 2011 12:10:19 -0500
Message-Id: <1294161028-4499-3-git-send-email-andros@netapp.com>
In-Reply-To: <1294161028-4499-2-git-send-email-andros@netapp.com>
References: <1294161028-4499-1-git-send-email-andros@netapp.com>
 <1294161028-4499-2-git-send-email-andros@netapp.com>
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

