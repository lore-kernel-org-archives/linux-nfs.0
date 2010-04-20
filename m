Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58125 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147Ab0DTMhr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Apr 2010 08:37:47 -0400
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often
 fails to delete things it just created
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nix <nix@esperi.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <87aasz9ssu.fsf@spindle.srvr.nix>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	 <1271618484.8049.1.camel@localhost.localdomain>
	 <87vdboa7e0.fsf@spindle.srvr.nix>
	 <1271620750.8049.3.camel@localhost.localdomain>
	 <87mxx0a5pc.fsf@spindle.srvr.nix>
	 <1271621624.8049.6.camel@localhost.localdomain>
	 <87iq7oa2o8.fsf@spindle.srvr.nix>
	 <1271682635.13653.40.camel@localhost.localdomain>
	 <87aasz9ssu.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Apr 2010 08:37:44 -0400
Message-ID: <1271767064.25129.84.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-04-19 at 19:54 +0100, Nix wrote: 
> On 19 Apr 2010, Trond Myklebust verbalised:
> > Hmm... Could you please try reverting commit
> > 2c61be0a9478258f77b66208a0c4b1f5f8161c3c (NFS: Ensure that the WRITE and
> > COMMIT RPC calls are always uninterruptible). I wonder if that
> > introduced a new race...
> 
> That seems to have fixed it.
> 
> (This must be a heck of a wide race, or I'm very unlucky :) I hit it
> every single time, even if the machine is under heavy load...)

Hmm... Unfortunately I don't think that reverting the patch is
sufficient to completely close the race. For instance, it is entirely
possible for the background flush threads to schedule a COMMIT which can
race with the close() call in a similar fashion.

I therefore think we need something like the following patch.

Cheers
  Trond
------------------------------------------------------------------------------------------------- 
NFS: Fix an unstable write data integrity race

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Commit 2c61be0a9478258f77b66208a0c4b1f5f8161c3c (NFS: Ensure that the WRITE
and COMMIT RPC calls are always uninterruptible) exposed a race on file
close. In order to ensure correct close-to-open behaviour, we want to wait
for all outstanding background commit operations to complete.

This patch adds an inode flag that indicates if a commit operation is under
way, and provides a mechanism to allow ->write_inode() to wait for its
completion if this is a data integrity flush.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/write.c         |   36 ++++++++++++++++++++++++++++++++----
 include/linux/nfs_fs.h |    1 +
 2 files changed, 33 insertions(+), 4 deletions(-)


diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index de38d63..ccde2ae 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1201,6 +1201,25 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 

 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
+{
+	if (!test_and_set_bit(NFS_INO_COMMIT, &nfsi->flags))
+		return 1;
+	if (may_wait && !out_of_line_wait_on_bit_lock(&nfsi->flags,
+				NFS_INO_COMMIT, nfs_wait_bit_killable,
+				TASK_KILLABLE))
+		return 1;
+	return 0;
+}
+
+static void nfs_commit_clear_lock(struct nfs_inode *nfsi)
+{
+	clear_bit(NFS_INO_COMMIT, &nfsi->flags);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&nfsi->flags, NFS_INO_COMMIT);
+}
+
+
 static void nfs_commitdata_release(void *data)
 {
 	struct nfs_write_data *wdata = data;
@@ -1262,8 +1281,6 @@ static int nfs_commit_rpcsetup(struct list_head *head,
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	if (how & FLUSH_SYNC)
-		rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 	return 0;
 }
@@ -1294,6 +1311,7 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
 				BDI_RECLAIMABLE);
 		nfs_clear_page_tag_locked(req);
 	}
+	nfs_commit_clear_lock(NFS_I(inode));
 	return -ENOMEM;
 }
 
@@ -1349,6 +1367,7 @@ static void nfs_commit_release(void *calldata)
 	next:
 		nfs_clear_page_tag_locked(req);
 	}
+	nfs_commit_clear_lock(NFS_I(data->inode));
 	nfs_commitdata_release(calldata);
 }
 
@@ -1363,8 +1382,11 @@ static const struct rpc_call_ops nfs_commit_ops = {
 static int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
-	int res;
+	int may_wait = how & FLUSH_SYNC;
+	int res = 0;
 
+	if (!nfs_commit_set_lock(NFS_I(inode), may_wait))
+		goto out;
 	spin_lock(&inode->i_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
 	spin_unlock(&inode->i_lock);
@@ -1372,7 +1394,13 @@ static int nfs_commit_inode(struct inode *inode, int how)
 		int error = nfs_commit_list(inode, &head, how);
 		if (error < 0)
 			return error;
-	}
+		if (may_wait)
+			wait_on_bit(&NFS_I(inode)->flags, NFS_INO_COMMIT,
+					nfs_wait_bit_killable,
+					TASK_KILLABLE);
+	} else
+		nfs_commit_clear_lock(NFS_I(inode));
+out:
 	return res;
 }
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1a0b85a..07ce460 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -209,6 +209,7 @@ struct nfs_inode {
 #define NFS_INO_FLUSHING	(4)		/* inode is flushing out data */
 #define NFS_INO_FSCACHE		(5)		/* inode can be cached by FS-Cache */
 #define NFS_INO_FSCACHE_LOCK	(6)		/* FS-Cache cookie management lock */
+#define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
 
 static inline struct nfs_inode *NFS_I(const struct inode *inode)
 {

