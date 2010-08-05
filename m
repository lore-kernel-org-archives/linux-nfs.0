Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41859 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759195Ab0HEOSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Aug 2010 10:18:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFS: Fix the locking in nfs4_callback_getattr
Date: Thu,  5 Aug 2010 10:17:49 -0400
Message-Id: <1281017872-6043-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1281017872-6043-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1281017872-6043-1-git-send-email-Trond.Myklebust@netapp.com>
 <1281017872-6043-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The delegation is protected by RCU now, so we need to replace the
nfsi->rwsem protection with an rcu protected section.

Reported-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 7445dd0..930d10f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -37,8 +37,8 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 	if (inode == NULL)
 		goto out_putclient;
 	nfsi = NFS_I(inode);
-	down_read(&nfsi->rwsem);
-	delegation = nfsi->delegation;
+	rcu_read_lock();
+	delegation = rcu_dereference(nfsi->delegation);
 	if (delegation == NULL || (delegation->type & FMODE_WRITE) == 0)
 		goto out_iput;
 	res->size = i_size_read(inode);
@@ -53,7 +53,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args, struct cb_getattrres *
 		args->bitmap[1];
 	res->status = 0;
 out_iput:
-	up_read(&nfsi->rwsem);
+	rcu_read_unlock();
 	iput(inode);
 out_putclient:
 	nfs_put_client(clp);
-- 
1.7.2

