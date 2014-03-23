Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:52661 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbaCWSp3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 14:45:29 -0400
From: Monam Agarwal <monamagarwal123@gmail.com>
To: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] fs: Use RCU_INIT_POINTER(x, NULL) in nfs/delegation.c
Date: Mon, 24 Mar 2014 00:14:27 +0530
Message-Id: <1395600267-9169-1-git-send-email-monamagarwal123@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 fs/nfs/delegation.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5d8ccec..349e63b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -249,7 +249,7 @@ nfs_detach_delegation_locked(struct nfs_inode *nfsi,
 	list_del_rcu(&delegation->super_list);
 	delegation->inode = NULL;
 	nfsi->delegation_state = 0;
-	rcu_assign_pointer(nfsi->delegation, NULL);
+	RCU_INIT_POINTER(nfsi->delegation, NULL);
 	spin_unlock(&delegation->lock);
 	return delegation;
 }
-- 
1.7.9.5

