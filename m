Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60868 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752534AbdFPPNE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Jun 2017 11:13:04 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, mszeredi@redhat.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v4 2/2] NFS: nfs_rename() - revalidate directories on -ERESTARTSYS
Date: Fri, 16 Jun 2017 11:13:00 -0400
Message-Id: <48493fe9b082017185c48bdccd86ced120b86a0c.1497625662.git.bcodding@redhat.com>
In-Reply-To: <cover.1497625662.git.bcodding@redhat.com>
References: <cover.1497625662.git.bcodding@redhat.com>
In-Reply-To: <cover.1497625662.git.bcodding@redhat.com>
References: <cover.1497625662.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An interrupted rename will leave the old dentry behind if the rename
succeeds.  Fix this by forcing a lookup the next time through
->d_revalidate.

A previous attempt at solving this problem took the approach to complete
the work of the rename asynchronously, however that approach was wrong
since it would allow the d_move() to occur after the directory's i_mutex
had been dropped by the original process.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/dir.c            |  6 +++++-
 fs/nfs/unlink.c         | 13 +++++++++++++
 include/linux/nfs_xdr.h |  1 +
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 2ac00bf4ecf1..7108d272bc87 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2035,7 +2035,11 @@ int nfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	}
 
 	error = rpc_wait_for_completion_task(task);
-	if (error == 0)
+	if (error != 0) {
+		((struct nfs_renamedata *)task->tk_calldata)->cancelled = 1;
+		/* Paired with the atomic_dec_and_test() barrier in rpc_do_put_task() */
+		smp_wmb();
+	} else
 		error = task->tk_status;
 	rpc_put_task(task);
 	nfs_mark_for_revalidate(old_inode);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 191aa577dd1f..e3949d93085c 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -288,6 +288,19 @@ static void nfs_async_rename_release(void *calldata)
 	if (d_really_is_positive(data->old_dentry))
 		nfs_mark_for_revalidate(d_inode(data->old_dentry));
 
+	/* The result of the rename is unknown. Play it safe by
+	 * forcing a new lookup */
+	if (data->cancelled) {
+		spin_lock(&data->old_dir->i_lock);
+		nfs_force_lookup_revalidate(data->old_dir);
+		spin_unlock(&data->old_dir->i_lock);
+		if (data->new_dir != data->old_dir) {
+			spin_lock(&data->new_dir->i_lock);
+			nfs_force_lookup_revalidate(data->new_dir);
+			spin_unlock(&data->new_dir->i_lock);
+		}
+	}
+
 	dput(data->old_dentry);
 	dput(data->new_dentry);
 	iput(data->old_dir);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index b28c83475ee8..1aca3d7c1810 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1533,6 +1533,7 @@ struct nfs_renamedata {
 	struct nfs_fattr	new_fattr;
 	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
 	long timeout;
+	bool cancelled;
 };
 
 struct nfs_access_entry;
-- 
2.9.3

