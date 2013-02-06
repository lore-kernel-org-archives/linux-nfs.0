Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f45.google.com ([209.85.219.45]:57685 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758108Ab3BFTtl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 14:49:41 -0500
From: Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: [PATCH 12/77] nfs: idr_destroy() no longer needs idr_remove_all()
Date: Wed,  6 Feb 2013 11:39:44 -0800
Message-Id: <1360179649-22465-13-git-send-email-tj@kernel.org>
In-Reply-To: <1360179649-22465-1-git-send-email-tj@kernel.org>
References: <1360179649-22465-1-git-send-email-tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idr_destroy() can destroy idr by itself and idr_remove_all() is being
deprecated.  Drop reference to idr_remove_all().  Note that the code
wasn't completely correct before because idr_remove() on all entries
doesn't necessarily release all idr_layers which could lead to memory
leak.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/client.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9f3c664..84d8eae 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -197,7 +197,6 @@ error_0:
 EXPORT_SYMBOL_GPL(nfs_alloc_client);
 
 #if IS_ENABLED(CONFIG_NFS_V4)
-/* idr_remove_all is not needed as all id's are removed by nfs_put_client */
 void nfs_cleanup_cb_ident_idr(struct net *net)
 {
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
-- 
1.8.1

