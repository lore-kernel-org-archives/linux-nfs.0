Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:45292 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751985AbcLFUuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 15:50:37 -0500
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@Netapp.com>, <neilb@suse.com>
Subject: [PATCH] NFSv4: Add missing nfs_put_lock_context()
Date: Tue, 6 Dec 2016 15:50:06 -0500
Message-ID: <20161206205006.3467-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.com>

Otherwise the lock context won't be freed when we're done with it.

From: NeilBrown <neilb@suse.com>
Fixes: 5bd3f817 ("NFSv4: change nfs4_select_rw_stateid to take a lock_context inplace of lock_owner")
Signed-off-by: Anna Schumaker <Anna.Schumaker@netapp.com>
---
 fs/nfs/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f992281..21c861a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2951,8 +2951,10 @@ static int _nfs4_do_setattr(struct inode *inode,
 		l_ctx = nfs_get_lock_context(ctx);
 		if (IS_ERR(l_ctx))
 			return PTR_ERR(l_ctx);
-		if (nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, l_ctx,
-				&arg->stateid, &delegation_cred) == -EIO)
+		status = nfs4_select_rw_stateid(ctx->state, FMODE_WRITE, l_ctx,
+						&arg->stateid, &delegation_cred);
+		nfs_put_lock_context(l_ctx);
+		if (status == -EIO)
 			return -EBADF;
 	} else
 		nfs4_stateid_copy(&arg->stateid, &zero_stateid);
-- 
2.10.2

