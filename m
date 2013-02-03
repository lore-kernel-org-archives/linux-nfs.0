Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f41.google.com ([209.85.210.41]:62063 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab3BCBXQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Feb 2013 20:23:16 -0500
From: Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, rusty@rustcorp.com.au, bfields@fieldses.org,
        skinsbursky@parallels.com, ebiederm@xmission.com, jmorris@namei.org,
        axboe@kernel.dk, Tejun Heo <tj@kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH 61/62] nfs4client: convert to idr_alloc()
Date: Sat,  2 Feb 2013 17:21:02 -0800
Message-Id: <1359854463-2538-62-git-send-email-tj@kernel.org>
In-Reply-To: <1359854463-2538-1-git-send-email-tj@kernel.org>
References: <1359854463-2538-1-git-send-email-tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Convert to the much saner new idr interface.

Only compile tested.

Signed-off-by: Tejun Heo <tj@kernel.org>

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
This patch depends on an earlier idr changes and I think it would be
best to route these together through -mm.  Please holler if there's
any objection.  Thanks.

 fs/nfs/nfs4client.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index acc3472..ff314f6 100644
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

