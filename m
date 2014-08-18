Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52119 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbaHRGYy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 02:24:54 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 18 Aug 2014 16:22:54 +1000
Subject: [PATCH 2/2] NFS: avoid deadlocks with loop-back mounted NFS
 filesystems.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140818062254.1449.99502.stgit@notabene.brown>
In-Reply-To: <20140818061727.1449.89101.stgit@notabene.brown>
References: <20140818061727.1449.89101.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Support for loop-back mounted NFS filesystems is useful when NFS is
used to access shared storage in a high-availability cluster.

If the node running the NFS server fails, some other node can mount the
filesystem and start providing NFS service.  If that node already had
the filesystem NFS mounted, it will now have it loop-back mounted.

nfsd can suffer a deadlock when allocating memory and entering direct
reclaim.
While direct reclaim does not write to the NFS filesystem it can send
and wait for a COMMIT through nfs_release_page().

This patch modifies nfs_release_page() and the functions it calls so
that if the COMMIT is sent to the local host (i.e. is routed over the
loop-back interface) then nfs_release_page() will not wait forever for
that COMMIT to complete.  This is achieved using a new flag
FLUSH_COND_CONNECTED.  When this is set the flush is conditional and
will only wait if the client is connected to a non-local server.

Aborting early should be safe as kswapd uses the same code but never
waits for the COMMIT.

Always aborting early could upset the balance of memory management so
when the commit was sent to the local host we still wait but with a
100ms timeout.  This is enough to significantly slow down any process
that is allocating lots of memory and often long enough to let the
commit complete.

In those rare cases where it is nfsd, or something that nfsd is
waiting for, that is calling nfs_release_page(), 100ms is not so long
that throughput will be seriously affected.

When fail-over happens a remote (foreign) client will first become
disconnected and then turn into a local client.
To prevent deadlocks from happening at this point, we still have a
timeout when the COMMIT has been sent to a remote client. In this case
the timeout is longer (1 second).

So when a node that has mounted a remote filesystem loses the
connection, nfs_release_page() will stop blocking and start failing.
Memory allocators will then be able to make progress without blocking
in NFS.  Any process which writes to a file will still be blocked in
balance_dirty_pages().

This patch makes use of the new 'private' field in
"struct wait_bit_key" to store the start time of a commit, so the
'action' function called by __wait_on_bit() knows how much longer
it is appropriate to wait.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/file.c               |    2 +
 fs/nfs/write.c              |   72 ++++++++++++++++++++++++++++++++++++++++---
 include/linux/freezer.h     |   10 ++++++
 include/uapi/linux/nfs_fs.h |    3 ++
 4 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 524dd80d1898..9135af74b896 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -473,7 +473,7 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
 	 */
 	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL &&
 	    !(current->flags & PF_FSTRANS)) {
-		int how = FLUSH_SYNC;
+		int how = FLUSH_SYNC | FLUSH_COND_CONNECTED;
 
 		/* Don't let kswapd deadlock waiting for OOM RPC calls */
 		if (current_is_kswapd())
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e3b5cf28bdc5..9694f65e2f39 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -14,6 +14,7 @@
 #include <linux/writeback.h>
 #include <linux/swap.h>
 #include <linux/migrate.h>
+#include <linux/freezer.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
@@ -1457,6 +1458,55 @@ static void nfs_writeback_result(struct rpc_task *task,
 
 
 #if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
+
+static int _wait_bit_connected(struct rpc_clnt *cl,
+			       struct wait_bit_key *key)
+{
+	if (fatal_signal_pending(current))
+		return -ERESTARTSYS;
+	if (cl && rpc_is_foreign(cl)) {
+		/* We are connected to non-local server,
+		 * but might not be so indefinitely, so
+		 * don't wait indefinitely.
+		 */
+		freezable_schedule_timeout_unsafe(HZ);
+	} else {
+		unsigned long waited;
+		if (key->private == 0) {
+			key->private = jiffies;
+			if (key->private == 0)
+				key->private -= 1;
+		}
+		waited = jiffies - key->private;
+
+		/* We might be waiting for ourselves, so don't
+		 * wait too long.
+		 */
+		if (waited >= HZ/10)
+			/* Too long, give up */
+			return -EAGAIN;
+
+		freezable_schedule_timeout_unsafe(HZ/10 - waited);
+	}
+	return 0;
+}
+
+static int nfs_wait_bit_connected(struct wait_bit_key *key)
+{
+	struct nfs_inode *nfsi = container_of(key->flags,
+					      struct nfs_inode, flags);
+
+	return _wait_bit_connected(NFS_CLIENT(&nfsi->vfs_inode), key);
+}
+
+static int rpc_wait_bit_connected(struct wait_bit_key *key)
+{
+	struct rpc_task *task = container_of(key->flags,
+					     struct rpc_task, tk_runstate);
+
+	return _wait_bit_connected(task->tk_client, key);
+}
+
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
@@ -1467,7 +1517,9 @@ static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 		return 0;
 	ret = out_of_line_wait_on_bit_lock(&nfsi->flags,
 				NFS_INO_COMMIT,
-				nfs_wait_bit_killable,
+				(may_wait & FLUSH_COND_CONNECTED)
+				? nfs_wait_bit_connected
+				: nfs_wait_bit_killable,
 				TASK_KILLABLE);
 	return (ret < 0) ? ret : 1;
 }
@@ -1518,8 +1570,12 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
-	if (how & FLUSH_SYNC)
-		rpc_wait_for_completion_task(task);
+	if (how & FLUSH_SYNC) {
+		if (how & FLUSH_COND_CONNECTED)
+			__rpc_wait_for_completion_task(task, rpc_wait_bit_connected);
+		else
+			rpc_wait_for_completion_task(task);
+	}
 	rpc_put_task(task);
 	return 0;
 }
@@ -1695,7 +1751,7 @@ int nfs_commit_inode(struct inode *inode, int how)
 {
 	LIST_HEAD(head);
 	struct nfs_commit_info cinfo;
-	int may_wait = how & FLUSH_SYNC;
+	int may_wait = how & (FLUSH_SYNC | FLUSH_COND_CONNECTED);
 	int res;
 
 	res = nfs_commit_set_lock(NFS_I(inode), may_wait);
@@ -1711,10 +1767,16 @@ int nfs_commit_inode(struct inode *inode, int how)
 			return error;
 		if (!may_wait)
 			goto out_mark_dirty;
+
 		error = wait_on_bit_action(&NFS_I(inode)->flags,
 				NFS_INO_COMMIT,
-				nfs_wait_bit_killable,
+				(how & FLUSH_COND_CONNECTED)
+				? nfs_wait_bit_connected
+				: nfs_wait_bit_killable,
 				TASK_KILLABLE);
+
+		if ((how & FLUSH_COND_CONNECTED) && error == -EAGAIN)
+			goto out_mark_dirty;
 		if (error < 0)
 			return error;
 	} else
diff --git a/include/linux/freezer.h b/include/linux/freezer.h
index 7fd81b8c4897..1a32fe0c1255 100644
--- a/include/linux/freezer.h
+++ b/include/linux/freezer.h
@@ -193,6 +193,16 @@ static inline long freezable_schedule_timeout(long timeout)
 	return __retval;
 }
 
+/* DO NOT ADD ANY NEW CALLERS OF THIS FUNCTION */
+static inline long freezable_schedule_timeout_unsafe(long timeout)
+{
+	long __retval;
+	freezer_do_not_count();
+	__retval = schedule_timeout(timeout);
+	freezer_count_unsafe();
+	return __retval;
+}
+
 /*
  * Like schedule_timeout_interruptible(), but should not block the freezer.  Do not
  * call this with locks held.
diff --git a/include/uapi/linux/nfs_fs.h b/include/uapi/linux/nfs_fs.h
index 49142287999c..896b8d976896 100644
--- a/include/uapi/linux/nfs_fs.h
+++ b/include/uapi/linux/nfs_fs.h
@@ -35,6 +35,9 @@
 #define FLUSH_HIGHPRI		16	/* high priority memory reclaim flush */
 #define FLUSH_COND_STABLE	32	/* conditional stable write - only stable
 					 * if everything fits in one RPC */
+#define FLUSH_COND_CONNECTED   64	/* Don't wait for COMMIT unless client
+					 * is connected to a remote host.
+					 */
 
 
 /*


