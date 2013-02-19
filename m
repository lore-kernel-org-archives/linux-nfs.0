Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932828Ab3BSOAz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 09:00:55 -0500
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Dave Wysochanski <dwysocha@redhat.com>
Subject: [PATCH] nfs: Don't allow NFS silly-renamed files to be deleted, no signal
Date: Tue, 19 Feb 2013 08:59:51 -0500
Message-Id: <1361282391-6578-1-git-send-email-dwysocha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 73ca100 broke the code that prevents the client from deleting
a silly renamed dentry.  This affected "delete on last close"
semantics as after that commit, nothing prevented removal of
silly-renamed files.  As a result, a process holding a file open
could easily get an ESTALE on the file in a directory where some
other process issued 'rm -rf some_dir_containing_the_file' twice.
Before the commit, any attempt at unlinking silly renamed files would
fail inside may_delete() with -EBUSY because of the
DCACHE_NFSFS_RENAMED flag.  The following testcase demonstrates
the problem:
  tail -f /nfsmnt/dir/file &
  rm -rf /nfsmnt/dir
  rm -rf /nfsmnt/dir
  # second removal does not fail, 'tail' process receives ESTALE

The problem with the above commit is that it unhashes the old and
new dentries from the lookup path, even in the normal case when
a signal is not encountered and it would have been safe to call
d_move.  Unfortunately the old dentry has the special
DCACHE_NFSFS_RENAMED flag set on it.  Unhashing has the
side-effect that future lookups call d_alloc(), allocating a new
dentry without the special flag for any silly-renamed files.  As a
result, subsequent calls to unlink silly renamed files do not fail
but allow the removal to go through.  This will result in ESTALE
errors for any other process doing operations on the file.

To fix this, go back to using d_move.  However, to use d_move safely,
we have to isolate the special case where we receive a signal.
To handle this, we add two flags to nfs_renamedata,
NFS_RENAME_CANCELLED and NFS_RENAME_CALLBACK_IN_PROGRESS.

If a signal occurs, inside nfs_sillyrename() we first set
NFS_RENAME_CANCELLED and then wait for NFS_RENAME_CALLBACK_IN_PROGRESS
to clear.  Inside nfs_async_rename_done(), we set
NFS_RENAME_CALLBACK_IN_PROGRESS at the top and clear at the bottom,
waking up anyone sleeping on the bit.  Before calling d_move, we
check NFS_RENAME_CANCELLED and if set, we d_drop instead of calling
d_move.  If this case is hit, and we have to d_drop, a process will
still receive an ESTALE, but the non-signal case is not affected.

For the signal case, it's unclear what we may safely do beyond d_drop
as we've dropped the mutexes, and to call d_move we must reacquire
them.  I made an attempt at reacquiring mutexes and then checking
for various scenarios, but the testcases and the code quickly became
fairly complex and seemed like the wrong approach.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/unlink.c         |   39 +++++++++++++++++++++++++++++++++++++--
 include/linux/nfs_xdr.h |    3 +++
 2 files changed, 40 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 3f79c77..4e2d81d 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -323,6 +323,19 @@ nfs_cancel_async_unlink(struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 }
 
+static int nfs_async_rename_wait_bit(void *flags)
+{
+	schedule();
+	return 0;
+}
+static inline void nfs_async_rename_wake_up(struct nfs_renamedata *data)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(NFS_RENAME_CALLBACK_IN_PROGRESS, &data->flags);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&data->flags, NFS_RENAME_CALLBACK_IN_PROGRESS);
+}
+
 /**
  * nfs_async_rename_done - Sillyrename post-processing
  * @task: rpc_task of the sillyrename
@@ -338,18 +351,32 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 	struct dentry *old_dentry = data->old_dentry;
 	struct dentry *new_dentry = data->new_dentry;
 
+	set_bit(NFS_RENAME_CALLBACK_IN_PROGRESS, &data->flags);
+	/* ensure the read of NFS_RENAME_CANCELLED is not reordered */
+	smp_mb();
+
 	if (!NFS_PROTO(old_dir)->rename_done(task, old_dir, new_dir)) {
 		rpc_restart_call_prepare(task);
+		nfs_async_rename_wake_up(data);
 		return;
 	}
 
 	if (task->tk_status != 0) {
 		nfs_cancel_async_unlink(old_dentry);
+		nfs_async_rename_wake_up(data);
+		return;
+	}
+
+	if (test_bit(NFS_RENAME_CANCELLED, &data->flags)) {
+		d_drop(old_dentry);
+		d_drop(new_dentry);
+		nfs_async_rename_wake_up(data);
 		return;
 	}
 
-	d_drop(old_dentry);
-	d_drop(new_dentry);
+	nfs_set_verifier(data->old_dentry, nfs_save_change_attribute(old_dir));
+	d_move(data->old_dentry, data->new_dentry);
+	nfs_async_rename_wake_up(data);
 }
 
 /**
@@ -483,6 +510,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	struct dentry *sdentry;
 	struct rpc_task *task;
 	int            error = -EIO;
+	struct nfs_renamedata *data;
 
 	dfprintk(VFS, "NFS: silly-rename(%s/%s, ct=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
@@ -550,6 +578,13 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	error = rpc_wait_for_completion_task(task);
 	if (error == 0)
 		error = task->tk_status;
+	else if (error == -ERESTARTSYS) /* We got a signal */ {
+		data = (struct nfs_renamedata *)task->tk_calldata;
+		set_bit(NFS_RENAME_CANCELLED, &data->flags);
+		/* barrier inside wait_on_bit before we read the bit */
+		wait_on_bit(&data->flags, NFS_RENAME_CALLBACK_IN_PROGRESS,
+			    nfs_async_rename_wait_bit, TASK_UNINTERRUPTIBLE);
+	}
 	rpc_put_task(task);
 out_dput:
 	dput(sdentry);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 29adb12..136e3d4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1339,6 +1339,8 @@ struct nfs_unlinkdata {
 	struct nfs_fattr dir_attr;
 };
 
+#define NFS_RENAME_CANCELLED			(1U << 0)
+#define NFS_RENAME_CALLBACK_IN_PROGRESS		(1U << 1)
 struct nfs_renamedata {
 	struct nfs_renameargs	args;
 	struct nfs_renameres	res;
@@ -1349,6 +1351,7 @@ struct nfs_renamedata {
 	struct inode		*new_dir;
 	struct dentry		*new_dentry;
 	struct nfs_fattr	new_fattr;
+	unsigned long		flags;
 };
 
 struct nfs_access_entry;
-- 
1.7.1

