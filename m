Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5919 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753997AbdEDDNi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 23:13:38 -0400
From: Jason Yan <yanaijie@huawei.com>
To: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>
CC: <miaoxie@huawei.com>, <zhaohongjiang@huawei.com>,
        <houtao1@huawei.com>, Jason Yan <yanaijie@huawei.com>
Subject: [PATCH] NFS: delete useless rcu_read_lock()
Date: Thu, 4 May 2017 11:16:00 +0800
Message-ID: <1493867760-26684-1-git-send-email-yanaijie@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The rcu_read_lock in nfs_layout_find_inode_by_stateid and
nfs_layout_find_inode_by_fh is very confused, is it a clerical error?

Since it is already called in nfs_layout_find_inode, there's no need to
keep it here.

Signed-off-by: Jason Yan <yanaijie@huawei.com>
---
 fs/nfs/callback_proc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f073a6d2c..39c489f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -131,7 +131,6 @@ static struct inode *nfs_layout_find_inode_by_stateid(struct nfs_client *clp,
 			if (!inode)
 				continue;
 			if (!nfs_sb_active(inode->i_sb)) {
-				rcu_read_lock();
 				spin_unlock(&clp->cl_lock);
 				iput(inode);
 				spin_lock(&clp->cl_lock);
@@ -170,7 +169,6 @@ static struct inode *nfs_layout_find_inode_by_fh(struct nfs_client *clp,
 			if (!inode)
 				continue;
 			if (!nfs_sb_active(inode->i_sb)) {
-				rcu_read_lock();
 				spin_unlock(&clp->cl_lock);
 				iput(inode);
 				spin_lock(&clp->cl_lock);
-- 
2.5.0

