From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 08/22] pnfs: track the number of outstanding commits
Date: Sat, 15 May 2010 21:22:59 -0400
Message-ID: <1273972993-15369-9-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0ETKah (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:37 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQbw022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:36 -0700 (PDT)
In-Reply-To: <1273972993-15369-8-git-send-email-iisaman@netapp.com>
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
index c96dd0e..789706e 100644
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
index a4c95a0..937da85 100644
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
index dee1c8c..864eac1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1005,6 +1005,8 @@ struct nfs_read_data {
 };
 
 struct nfs_write_data {
+	struct kref		refcount;	/* For pnfs commit splitting */
+	struct nfs_write_data	*parent;	/* For pnfs commit splitting */
 	int			flags;
 	struct rpc_task		task;
 	struct inode		*inode;
-- 
1.6.6.1

