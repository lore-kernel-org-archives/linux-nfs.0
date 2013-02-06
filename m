Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f44.google.com ([209.85.220.44]:61913 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758228Ab3BFUBq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 15:01:46 -0500
From: Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 77/77] nfs4client: convert to idr_alloc()
Date: Wed,  6 Feb 2013 11:40:49 -0800
Message-Id: <1360179649-22465-78-git-send-email-tj@kernel.org>
In-Reply-To: <1360179649-22465-1-git-send-email-tj@kernel.org>
References: <1360179649-22465-1-git-send-email-tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert to the much saner new idr interface.

Only compile tested.

Signed-off-by: Tejun Heo <tj@kernel.org>

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/nfs4client.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 2e9779b..47d1008 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -29,15 +29,14 @@ static int nfs_get_cb_ident_idr(struct nfs_client *clp, int minorversion)
 
 	if (clp->rpc_ops->version != 4 || minorversion != 0)
 		return ret;
-retry:
-	if (!idr_pre_get(&nn->cb_ident_idr, GFP_KERNEL))
-		return -ENOMEM;
+	idr_preload(GFP_KERNEL);
 	spin_lock(&nn->nfs_client_lock);
-	ret = idr_get_new(&nn->cb_ident_idr, clp, &clp->cl_cb_ident);
+	ret = idr_alloc(&nn->cb_ident_idr, clp, 0, 0, GFP_NOWAIT);
+	if (ret >= 0)
+		clp->cl_cb_ident = ret;
 	spin_unlock(&nn->nfs_client_lock);
-	if (ret == -EAGAIN)
-		goto retry;
-	return ret;
+	idr_preload_end();
+	return ret < 0 ? ret : 0;
 }
 
 #ifdef CONFIG_NFS_V4_1
-- 
1.8.1

