Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f51.google.com ([74.125.82.51]:63180 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932132AbaHVOII (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 10:08:08 -0400
Date: Fri, 22 Aug 2014 17:07:59 +0300
From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
To: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com
Subject: [PATCH] nfs: delegation: Replace rcu_assign_pointer() with
 RCU_INIT_POINTER()
Message-ID: <20140822140759.GA31775@ada>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The use of "rcu_assign_pointer()" is NULLing out the pointer.
According to RCU_INIT_POINTER()'s block comment:
"1.   This use of RCU_INIT_POINTER() is NULLing out the pointer"
it is better to use it instead of rcu_assign_pointer() because it has a
smaller overhead.

The following Coccinelle semantic patch was used:
@@
@@

- rcu_assign_pointer
+ RCU_INIT_POINTER
  (..., NULL)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 fs/nfs/delegation.c | 2 +-
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
1.9.1

