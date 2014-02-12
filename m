Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.bwstor.com.cn ([211.103.180.228]:41320 "EHLO mx.bwstor.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751397AbaBLKHw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Feb 2014 05:07:52 -0500
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        shaobingqing <shaobingqing@bwstor.com.cn>
Subject: [PATCH v2] NFSv4.1: new layout stateid can not be overwrite by one out of date
Date: Wed, 12 Feb 2014 18:06:20 +0800
Message-Id: <1392199580-14249-1-git-send-email-shaobingqing@bwstor.com.cn>
In-Reply-To: <N>
References: <N>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If initiate_file_draining returned NFS4ERR_DELAY, all the lsegs of
a file might be released before the retrying cb_layout request arriving
at the client. In this situation, layoutget request of the file will
use open stateid to obtain a new layout stateid. And if the retrying
cb_layout request arrived at the client after the layoutget reply,
new layout stateid would be overwrite by one out of date.

Signed-off-by: shaobingqing <shaobingqing@bwstor.com.cn>
---
 fs/nfs/callback.h      |    5 +++++
 fs/nfs/callback_proc.c |   24 ++++++++++++++++++++++++
 fs/nfs/inode.c         |    1 +
 include/linux/nfs_fs.h |    1 +
 4 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 84326e9..213ded9 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -166,6 +166,11 @@ struct cb_layoutrecallargs {
 	};
 };
 
+struct cb_stalestatenode {
+	nfs4_stateid cbs_stateid;
+	struct list_head cb_stale_state;
+};
+
 extern __be32 nfs4_callback_layoutrecall(
 	struct cb_layoutrecallargs *args,
 	void *dummy, struct cb_process_state *cps);
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ae2e87b..80bafbe 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -159,9 +159,16 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 {
 	struct inode *ino;
 	struct pnfs_layout_hdr *lo;
+	struct cb_stalestatenode  *state_entry, *state_node;
+	struct cb_stalestatenode *tmp;
+	bool res;
 	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
 	LIST_HEAD(free_me_list);
 
+	state_node = kmalloc(sizeof(cb_stalestatenode), GFP_KERNEL);
+	if (!state_node)
+		return NFS4ERR_DELAY;
+
 	lo = get_layout_by_fh(clp, &args->cbl_fh);
 	if (!lo)
 		return NFS4ERR_NOMATCHING_LAYOUT;
@@ -174,7 +181,24 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
+	list_for_each_entry_safe(state_entry, tmp,
+			&NFS_I(ino)->cb_stale_state_list, cb_stale_state) {
+		if (memcmp(&args->cbl_stateid, &state_entry->cbs_stateid,
+				NFS4_STATEID_OTHER_SIZE) != 0)
+			continue;
+		if (rv == NFS4ERR_NOMATCHING_LAYOUT)
+			list_del(&state_entry->cb_stale_state);
+		goto unlock;
+	}
+	if (rv == NFS4ERR_DELAY) {
+		nfs4_stateid_copy(&state_node->cbs_stateid, &args->cbl_stateid);
+		list_add(&state_node->cb_stale_state,
+				&NFS_I(ino)->cb_stale_state_list);
+	} else {
+		kfree(state_node);
+	}
 	pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
+unlock:
 	spin_unlock(&ino->i_lock);
 	pnfs_free_lseg_list(&free_me_list);
 	pnfs_put_layout_hdr(lo);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index eda8879..e2c881a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1643,6 +1643,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 		return NULL;
 	nfsi->flags = 0UL;
 	nfsi->cache_validity = 0UL;
+	INIT_LIST_HEAD(&nfsi->cb_stale_state_list);
 #ifdef CONFIG_NFS_V3_ACL
 	nfsi->acl_access = ERR_PTR(-EAGAIN);
 	nfsi->acl_default = ERR_PTR(-EAGAIN);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3ea4cde..ba47870 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -181,6 +181,7 @@ struct nfs_inode {
 	struct nfs4_cached_acl	*nfs4_acl;
         /* NFSv4 state */
 	struct list_head	open_states;
+	struct list_head	cb_stale_state_list;
 	struct nfs_delegation __rcu *delegation;
 	fmode_t			 delegation_state;
 	struct rw_semaphore	rwsem;
-- 
1.7.4.2

