Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48492 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750814AbdFOU7Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jun 2017 16:59:16 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, mszeredi@redhat.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFS: nfs_rename() - revalidate directories on -ERESTARTSYS
Date: Thu, 15 Jun 2017 16:59:14 -0400
Message-Id: <4051bbbec3bf880f65dbd4c63e6dc2b649c16e8e.1497559453.git.bcodding@redhat.com>
In-Reply-To: <cover.1497559453.git.bcodding@redhat.com>
References: <cover.1497559453.git.bcodding@redhat.com>
In-Reply-To: <cover.1497559453.git.bcodding@redhat.com>
References: <cover.1497559453.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An interrupted rename will leave the old dentry behind if the rename
succeeds.  Fix this by forcing a lookup the next time through
->d_revalidate.

A previous attempt at solving this problem took the approach to complete
the work of the rename asynchronously, however that approach was wrong
since it would allow the d_move() to occur after the directory's i_mutex
had been dropped by the original process.

v2:  Add memory barrier, hold directory i_locks while revalidating, specify
     single-bit field width for cancelled flag.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/dir.c            |  5 ++++-
 fs/nfs/unlink.c         | 11 +++++++++++
 include/linux/nfs_xdr.h |  1 +
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 1faf337b316f..94b05d0eec06 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2035,7 +2035,10 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	}
 
 	error = rpc_wait_for_completion_task(task);
-	if (error == 0)
+	if (error != 0) {
+		((struct nfs_renamedata *)task->tk_calldata)->cancelled = 1;
+		smp_wmb();
+	} else
 		error = task->tk_status;
 	rpc_put_task(task);
 	nfs_mark_for_revalidate(old_inode);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 191aa577dd1f..28628dde38b9 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -288,6 +288,17 @@ static void nfs_async_rename_release(void *calldata)
 	if (d_really_is_positive(data->old_dentry))
 		nfs_mark_for_revalidate(d_inode(data->old_dentry));
 
+	/* The result of the rename is unknown. Play it safe by
+	 * forcing a new lookup */
+	if (data->cancelled) {
+		spin_lock(&data->old_dir->i_lock);
+		nfs_force_lookup_revalidate(data->old_dir);
+		spin_unlock(&data->old_dir->i_lock);
+		spin_lock(&data->new_dir->i_lock);
+		nfs_force_lookup_revalidate(data->new_dir);
+		spin_unlock(&data->new_dir->i_lock);
+	}
+
 	dput(data->old_dentry);
 	dput(data->new_dentry);
 	iput(data->old_dir);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b28c83475ee8..0c32443d29a7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1533,6 +1533,7 @@ struct nfs_renamedata {
 	struct nfs_fattr	new_fattr;
 	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
 	long timeout;
+	unsigned int cancelled : 1;
 };
 
 struct nfs_access_entry;
-- 
2.9.3

