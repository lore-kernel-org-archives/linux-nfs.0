Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15938 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078Ab2JPQbG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:06 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 11/25] SUNRPC: remove BUG_ON() from bc_send()
Date: Tue, 16 Oct 2012 12:30:29 -0400
Message-Id: <1350405043-39316-11-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE(). The error condition is a simple
ref counting sanity check and the following code will not free anything
until final put.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/bc_svc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/bc_svc.c b/net/sunrpc/bc_svc.c
index 0b2eb38..15c7a8a 100644
--- a/net/sunrpc/bc_svc.c
+++ b/net/sunrpc/bc_svc.c
@@ -53,7 +53,7 @@ int bc_send(struct rpc_rqst *req)
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
 	else {
-		BUG_ON(atomic_read(&task->tk_count) != 1);
+		WARN_ON_ONCE(atomic_read(&task->tk_count) != 1);
 		ret = task->tk_status;
 		rpc_put_task(task);
 	}
-- 
1.7.9.6 (Apple Git-31.1)

