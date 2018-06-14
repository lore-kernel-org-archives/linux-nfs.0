Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:55370 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754912AbeFNNjZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jun 2018 09:39:25 -0400
Received: by mail-it0-f66.google.com with SMTP id 16-v6so8327413itl.5
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jun 2018 06:39:25 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Cc: ross.zwisler@linux.intel.com
Subject: [PATCH] NFS: Fix an rcu deadlock in nfs_delegation_find_inode()
Date: Thu, 14 Jun 2018 09:39:17 -0400
Message-Id: <20180614133917.27656-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

I was able to reproduce this pretty regularily using xfstests
generic/013 on NFS v4.0.

Reported-by: Ross Zwisler <Ross.Zwisler@linux.intel.com>
Fixes: a337fe91 (NFSv4: Return NFS4ERR_DELAY when a delegation recall fails due to igrab())
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/delegation.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index bbd0465535eb..f033f3a69a3b 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -883,8 +883,10 @@ struct inode *nfs_delegation_find_inode(struct nfs_client *clp,
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		res = nfs_delegation_find_inode_server(server, fhandle);
-		if (res != ERR_PTR(-ENOENT))
+		if (res != ERR_PTR(-ENOENT)) {
+			rcu_read_unlock();
 			return res;
+		}
 	}
 	rcu_read_unlock();
 	return ERR_PTR(-ENOENT);
-- 
2.17.1

