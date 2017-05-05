Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34696 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdEERHF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 May 2017 13:07:05 -0400
Received: by mail-it0-f68.google.com with SMTP id c26so1519911itd.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 May 2017 10:07:05 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jason Yan <yanaijie@huawei.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix an rcu lock leak
Date: Fri,  5 May 2017 13:07:02 -0400
Message-Id: <20170505170702.7226-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The intention in the original patch was to release the lock when
we put the inode, however something got screwed up.

Reported-by: Jason Yan <yanaijie@huawei.com>
Fixes: 7b410d9ce460f ("pNFS: Delay getting the layout header in..")
Cc: stable@vger.kernel.org # v4.10+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e7f041447afd..52479f180ea1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -131,10 +131,11 @@ static struct inode *nfs_layout_find_inode_by_stateid(struct nfs_client *clp,
 			if (!inode)
 				continue;
 			if (!nfs_sb_active(inode->i_sb)) {
-				rcu_read_lock();
+				rcu_read_unlock();
 				spin_unlock(&clp->cl_lock);
 				iput(inode);
 				spin_lock(&clp->cl_lock);
+				rcu_read_lock();
 				goto restart;
 			}
 			return inode;
@@ -170,10 +171,11 @@ static struct inode *nfs_layout_find_inode_by_fh(struct nfs_client *clp,
 			if (!inode)
 				continue;
 			if (!nfs_sb_active(inode->i_sb)) {
-				rcu_read_lock();
+				rcu_read_unlock();
 				spin_unlock(&clp->cl_lock);
 				iput(inode);
 				spin_lock(&clp->cl_lock);
+				rcu_read_lock();
 				goto restart;
 			}
 			return inode;
-- 
2.9.3

