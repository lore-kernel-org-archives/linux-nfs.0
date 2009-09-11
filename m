From: NeilBrown <neilb@suse.de>
Subject: [PATCH 1/2] NFS: support changing the soft/hard flag with remount
Date: Fri, 11 Sep 2009 16:56:03 +1000
Message-ID: <20090911065603.8193.4714.stgit@notabene.brown>
References: <20090911065428.8193.8170.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41617 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751222AbZIKGzf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 02:55:35 -0400
In-Reply-To: <20090911065428.8193.8170.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This allows
   mount -o remount,soft
or
   mount -o remount,hard
to be effective on NFS mounts.

Setting to 'soft' when the server is not responding is not as
effective as might be hoped as Linux imposes a filesystem flush before
actioning a remount, so the remount will block waiting for the server
to come back.  Even before this the "mount" program will try to 'stat'
the mountpoint, so this isn't very useful at all when the server is
not responding.

When switching to soft, and pending tasks (which the 'sync' didn't
wait for) will be switched over to 'soft' mode.  However when
switching to 'hard', tasks are not changed.  So the mount does not
become fully hard until the server responds, or the soft requests
time out.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfs/super.c               |   27 ++++++++++++++++++++++++++-
 include/linux/sunrpc/sched.h |    1 +
 net/sunrpc/sched.c           |   21 +++++++++++++++++++++
 3 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 0b4cbdc..76b28ca 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1842,7 +1842,12 @@ static int
 nfs_compare_remount_data(struct nfs_server *nfss,
 			 struct nfs_parsed_mount_data *data)
 {
-	if (data->flags != nfss->flags ||
+	/* Check that the only fields changed are ones that are allowed
+	 * to change.
+	 * Currently they are:
+	 *   flags: NFS_MOUNT_SOFT
+	 */
+	if (((data->flags ^ nfss->flags) & ~(NFS_MOUNT_SOFT)) ||
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
 	    data->retrans != nfss->client->cl_timeout->to_retries ||
@@ -1908,6 +1913,26 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 
 	/* compare new mount options with old ones */
 	error = nfs_compare_remount_data(nfss, data);
+	if (error)
+		goto out;
+	/* The only things that might have changed are ones that
+	 * we know how to handle.
+	 */
+	if ((nfss->flags ^ data->flags) & NFS_MOUNT_SOFT) {
+		int soft = !!(data->flags & NFS_MOUNT_SOFT);
+
+		/* Note that when setting to 'hard' we don't convert all
+		 * tasks to hard.  This is unnecessary as any soft tasks
+		 * will die soon enough.
+		 */
+		nfss->client->cl_softrtry  = soft;
+		if (soft) {
+			nfss->flags |= NFS_MOUNT_SOFT;
+			rpc_alltasks_soft(nfss->client);
+		} else
+			nfss->flags &= ~NFS_MOUNT_SOFT;
+	}
+
 out:
 	kfree(data);
 	unlock_kernel();
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 4010977..a6c401d 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -216,6 +216,7 @@ void		rpc_put_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_release_calldata(const struct rpc_call_ops *, void *);
 void		rpc_killall_tasks(struct rpc_clnt *);
+void		rpc_alltasks_soft(struct rpc_clnt *);
 void		rpc_execute(struct rpc_task *);
 void		rpc_init_priority_wait_queue(struct rpc_wait_queue *, const char *);
 void		rpc_init_wait_queue(struct rpc_wait_queue *, const char *);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 8f459ab..82b388f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -949,6 +949,27 @@ void rpc_killall_tasks(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_killall_tasks);
 
+/*
+ * Mark all tasks for the given client as 'soft'.
+ */
+void rpc_alltasks_soft(struct rpc_clnt *clnt)
+{
+	struct rpc_task *rovr;
+
+	if (list_empty(&clnt->cl_tasks))
+		return;
+	dprintk("RPC:       setting all tasks SOFT for client %p\n", clnt);
+	/*
+	 * Spin lock all_tasks to prevent changes...
+	 */
+	spin_lock(&clnt->cl_lock);
+	list_for_each_entry(rovr, &clnt->cl_tasks, tk_task) {
+		rovr->tk_flags |= RPC_TASK_SOFT;
+	}
+	spin_unlock(&clnt->cl_lock);
+}
+EXPORT_SYMBOL_GPL(rpc_alltasks_soft);
+
 int rpciod_up(void)
 {
 	return try_module_get(THIS_MODULE) ? 0 : -EINVAL;


