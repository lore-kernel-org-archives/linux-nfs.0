Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:50733 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab3ADSPM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2013 13:15:12 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Weston Andros Adamson <dros@netapp.com>, Tejun Heo <tj@kernel.org>,
        Bruce Fields <bfields@fieldses.org>
Subject: [PATCH 3/3] SUNRPC: Partial revert of commit 168e4b39d1afb79a7e3ea6c3bb246b4c82c6bdb9
Date: Fri,  4 Jan 2013 13:15:02 -0500
Message-Id: <1357323302-12944-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1357323302-12944-2-git-send-email-Trond.Myklebust@netapp.com>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
 <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
 <1357323302-12944-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Partially revert commit (SUNRPC: add WARN_ON_ONCE for potential deadlock).
The looping behaviour has been tracked down to a knownn issue with
workqueues, and a workaround has now been implemented.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Weston Andros Adamson <dros@netapp.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Bruce Fields <bfields@fieldses.org>
Cc: stable@vger.kernel.org [>= 3.7]
---
 net/sunrpc/clnt.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 822f020..1915ffe 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -610,11 +610,6 @@ EXPORT_SYMBOL_GPL(rpc_killall_tasks);
  */
 void rpc_shutdown_client(struct rpc_clnt *clnt)
 {
-	/*
-	 * To avoid deadlock, never call rpc_shutdown_client from a
-	 * workqueue context!
-	 */
-	WARN_ON_ONCE(current->flags & PF_WQ_WORKER);
 	might_sleep();
 
 	dprintk_rcu("RPC:       shutting down %s client for %s\n",
-- 
1.7.11.7

