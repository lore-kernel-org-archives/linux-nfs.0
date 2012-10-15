Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8375 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755255Ab2JOVc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 17:32:29 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/13] NFSv4: Get rid of unnecessary BUG_ON()s
Date: Mon, 15 Oct 2012 17:31:01 -0400
Message-Id: <1350336667-18770-9-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
References: <1350336667-18770-1-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-2-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-3-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-4-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-5-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-6-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-7-git-send-email-Trond.Myklebust@netapp.com>
 <1350336667-18770-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/cache_lib.c     |  1 -
 fs/nfs/callback_proc.c |  1 -
 fs/nfs/nfs4file.c      |  1 -
 fs/nfs/nfs4proc.c      | 14 ++++++--------
 fs/nfs/nfs4state.c     |  1 -
 5 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index dded263..862a2f1 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -118,7 +118,6 @@ int nfs_cache_register_sb(struct super_block *sb, struct cache_detail *cd)
 	struct dentry *dir;
 
 	dir = rpc_d_lookup_sb(sb, "cache");
-	BUG_ON(dir == NULL);
 	ret = sunrpc_cache_register_pipefs(dir, cd->name, 0600, cd);
 	dput(dir);
 	return ret;
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 76b4a7a..0be08b9 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -216,7 +216,6 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 			}
 			pnfs_get_layout_hdr(lo);
 			spin_unlock(&ino->i_lock);
-			BUG_ON(!list_empty(&lo->plh_bulk_recall));
 			list_add(&lo->plh_bulk_recall, &recall_list);
 		}
 	}
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index afddd66..e769930 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -20,7 +20,6 @@ nfs4_file_open(struct inode *inode, struct file *filp)
 	struct iattr attr;
 	int err;
 
-	BUG_ON(inode != dentry->d_inode);
 	/*
 	 * If no cached dentry exists or if it's negative, NFSv4 handled the
 	 * opens in ->lookup() or ->create().
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 16190b4..3632a16 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -206,7 +206,6 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 {
 	__be32 *start, *p;
 
-	BUG_ON(readdir->count < 80);
 	if (cookie > 2) {
 		readdir->cookie = cookie;
 		memcpy(&readdir->verifier, verifier, sizeof(readdir->verifier));
@@ -416,7 +415,6 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
 static void
 nfs4_free_slot(struct nfs4_slot_table *tbl, u32 slotid)
 {
-	BUG_ON(slotid >= NFS4_MAX_SLOT_TABLE);
 	/* clear used bit in bitmap */
 	__clear_bit(slotid, tbl->used_slots);
 
@@ -2531,7 +2529,8 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS];
 
 	len = rpcauth_list_flavors(flav_array, ARRAY_SIZE(flav_array));
-	BUG_ON(len < 0);
+	if (len < 0)
+		return len;
 
 	for (i = 0; i < len; i++) {
 		/* AUTH_UNIX is the default flavor if none was specified,
@@ -3360,9 +3359,6 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 	int mode = sattr->ia_mode;
 	int status = -ENOMEM;
 
-	BUG_ON(!(sattr->ia_valid & ATTR_MODE));
-	BUG_ON(!S_ISFIFO(mode) && !S_ISBLK(mode) && !S_ISCHR(mode) && !S_ISSOCK(mode));
-
 	data = nfs4_alloc_createdata(dir, &dentry->d_name, sattr, NF4SOCK);
 	if (data == NULL)
 		goto out;
@@ -3378,10 +3374,13 @@ static int _nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
 		data->arg.ftype = NF4CHR;
 		data->arg.u.device.specdata1 = MAJOR(rdev);
 		data->arg.u.device.specdata2 = MINOR(rdev);
+	} else if (!S_ISSOCK(mode)) {
+		status = -EINVAL;
+		goto out_free;
 	}
 	
 	status = nfs4_do_create(dir, dentry, data);
-
+out_free:
 	nfs4_free_createdata(data);
 out:
 	return status;
@@ -5347,7 +5346,6 @@ int nfs4_proc_bind_conn_to_session(struct nfs_client *clp, struct rpc_cred *cred
 	};
 
 	dprintk("--> %s\n", __func__);
-	BUG_ON(clp == NULL);
 
 	res.session = kzalloc(sizeof(struct nfs4_session), GFP_NOFS);
 	if (unlikely(res.session == NULL)) {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c351e6b..e0a28df 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1086,7 +1086,6 @@ void nfs_free_seqid(struct nfs_seqid *seqid)
  */
 static void nfs_increment_seqid(int status, struct nfs_seqid *seqid)
 {
-	BUG_ON(list_first_entry(&seqid->sequence->list, struct nfs_seqid, list) != seqid);
 	switch (status) {
 		case 0:
 			break;
-- 
1.7.11.7

