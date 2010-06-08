From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 09/24] pnfs: track the number of outstanding commits
Date: Tue,  8 Jun 2010 00:19:06 -0400
Message-ID: <1275970761-31806-10-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4879 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab0FHETr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:47 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQ0014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:31 -0700 (PDT)
In-Reply-To: <1275970761-31806-9-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 71d0a6112a3 "NFS: Fix an unstable write data integrity race"
adds locking which is incompatible with the current file layout commit code,
which splits the commit into several RPCs cloned from the original.
Add a counter so layout driver can properly unlock only once.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    3 +++
 fs/nfs/write.c          |   19 ++++++++++++++++---
 include/linux/nfs_xdr.h |    2 ++
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 7fc93e6..e36c95d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -518,6 +518,9 @@ filelayout_clone_write_data(struct nfs_write_data *old)
 	new = nfs_commitdata_alloc();
 	if (!new)
 		goto out;
+	kref_init(&new->refcount);
+	new->parent      = old;
+	kref_get(&old->refcount);
 	new->inode       = old->inode;
 	new->cred        = old->cred;
 	new->args.offset = 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e42cd2b..13319c8 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1369,7 +1369,8 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
-
+	kref_init(&data->refcount);
+	data->parent      = NULL;
 	data->args.context = first->wb_context;  /* used by commit done */
 
 	return pnfs_initiate_commit(data, NFS_CLIENT(inode), &nfs_commit_ops,
@@ -1421,6 +1422,19 @@ static void nfs_commit_done(struct rpc_task *task, void *calldata)
 		return;
 }
 
+static inline void nfs_commit_cleanup(struct kref *kref)
+{
+	struct nfs_write_data *data;
+
+	data = container_of(kref, struct nfs_write_data, refcount);
+	/* Clear lock only when all cloned commits are finished */
+	if (data->parent)
+		kref_put(&data->parent->refcount, nfs_commit_cleanup);
+	else
+		nfs_commit_clear_lock(NFS_I(data->inode));
+	nfs_commitdata_release(data);
+}
+
 static void nfs_commit_release(void *calldata)
 {
 	struct nfs_write_data	*data = calldata;
@@ -1458,8 +1472,7 @@ static void nfs_commit_release(void *calldata)
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
-	nfs_commit_clear_lock(NFS_I(data->inode));
-	nfs_commitdata_release(calldata);
+	kref_put(&data->refcount, nfs_commit_cleanup);
 }
 
 static const struct rpc_call_ops nfs_commit_ops = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 634a199..07d6dd2 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1010,6 +1010,8 @@ struct nfs_read_data {
 };
 
 struct nfs_write_data {
+	struct kref		refcount;	/* For pnfs commit splitting */
+	struct nfs_write_data	*parent;	/* For pnfs commit splitting */
 	int			flags;
 	struct rpc_task		task;
 	struct inode		*inode;
-- 
1.6.6.1

