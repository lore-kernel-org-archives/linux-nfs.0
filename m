From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS hang
Date: Thu, 30 Nov 2006 23:51:11 -0500
Message-ID: <1164948671.5761.12.camel@lade.trondhjem.org>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
	<1164655027.5727.5.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611271929220.10489@nacho.alt.net>
	<1164657487.5727.12.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0611272110270.24703@nacho.alt.net>
	<Pine.LNX.4.64.0611302108180.16297@nacho.alt.net>
	<Pine.LNX.4.64.0612010337210.4621@nacho.alt.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-SIaND7d9wFPc7i1YLlJd"
Cc: Frank Filz <ffilz@us.ibm.com>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gq0Nj-0003Nl-GN
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 20:52:17 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+L0+5BD7A8VLOiAhm8+dxp44m1+lhCbyA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gq0Ni-0001bR-Lq
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 20:52:17 -0800
To: Chris Caputo <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.64.0612010337210.4621@nacho.alt.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


--=-SIaND7d9wFPc7i1YLlJd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 2006-12-01 at 04:20 +0000, Chris Caputo wrote:
> On Thu, 30 Nov 2006, Chris Caputo wrote:
> > On Mon, 27 Nov 2006, Chris Caputo wrote:
> > > On Mon, 27 Nov 2006, Trond Myklebust wrote:
> > > > No. There is no way this can work. You would need something that
> > > > guarantees that the task stays queued while you are taking the queue
> > > > lock.
> > > > 
> > > > Have you instead tried Christophe Saout's patch (see attachment)?
> > > 
> > > Thank you for the suggestion.  With 65 minutes of uptime so far, Saout's 
> > > November 5th patch is looking good.  For reference, normally I see the 
> > > race happen in under 15 minutes.
> > > 
> > > I'll report back if any problems develop.  This machine is an outgoing 
> > > newsfeed server and so it pounds on NFS client routines 24x7.
> > 
> > I am not sure if this is related, but at just over 3 days of uptime with 
> > 2.6.19-rc6 and the Saout patch, I had this happen:
> > 
> > ---
> > BUG: unable to handle kernel NULL pointer dereference at virtual address 00000028
> >  printing eip:
> > c029cf64
> > EIP is at call_start+0x5c/0x6f
> 
> I believe the above is the following line in clnt.c:call_start():
> 
>   clnt->cl_stats->rpccnt++;
> 
> So call_start() was called with a NULL task->tk_client.
> 
> Similar result with 2.6.19...
> 
> BUG: unable to handle kernel NULL pointer dereference at virtual address 00000008
>  printing eip:
> c029ef8e
> EIP is at xprt_reserve+0x28/0x119
> 
> In this one xprt.c:xprt_reserve() is I believe crashing at:
> 
>   spin_lock(&xprt->reserve_lock);
> 
> due to a NULL task->tk_xprt.
> 
> Ideas on whether this is related to the Saout sched race patch or if this 
> is something else entirely?

I suspect that it is related, but not the same race. I've identified a
couple of other possible race conditions, mainly to do with the fact
that nothing prevents an rpc_task from being freed while you are inside
rpc_wake_up_task(). Could you try applying both the attached patches,
and see if that helps?

Cheers,
  Trond


--=-SIaND7d9wFPc7i1YLlJd
Content-Disposition: attachment;
	filename=linux-2.6.19-002-cleanup_rpc_wakeup.dif
Content-Type: message/rfc822; name=linux-2.6.19-002-cleanup_rpc_wakeup.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 11 Nov 2006 22:18:03 -0500
Subject: No Subject
Message-Id: <1164948671.5761.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c            |   12 +++---
 include/linux/sunrpc/sched.h |    8 +---
 net/sunrpc/clnt.c            |   19 +++++-----
 net/sunrpc/pmap_clnt.c       |    2 +
 net/sunrpc/sched.c           |   80 +++++++++++++++++++++++++-----------------
 net/sunrpc/sunrpc_syms.c     |    1 -
 6 files changed, 65 insertions(+), 57 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8118036..93ac058 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -636,7 +636,7 @@ static int _nfs4_proc_open_confirm(struc
 		smp_wmb();
 	} else
 		status = data->rpc_status;
-	rpc_release_task(task);
+	rpc_put_task(task);
 	return status;
 }
 
@@ -742,7 +742,7 @@ static int _nfs4_proc_open(struct nfs4_o
 		smp_wmb();
 	} else
 		status = data->rpc_status;
-	rpc_release_task(task);
+	rpc_put_task(task);
 	if (status != 0)
 		return status;
 
@@ -3067,7 +3067,7 @@ static int _nfs4_proc_delegreturn(struct
 		if (status == 0)
 			nfs_post_op_update_inode(inode, &data->fattr);
 	}
-	rpc_release_task(task);
+	rpc_put_task(task);
 	return status;
 }
 
@@ -3314,7 +3314,7 @@ static int nfs4_proc_unlck(struct nfs4_s
 	if (IS_ERR(task))
 		goto out;
 	status = nfs4_wait_for_completion_rpc_task(task);
-	rpc_release_task(task);
+	rpc_put_task(task);
 out:
 	return status;
 }
@@ -3430,7 +3430,7 @@ static void nfs4_lock_release(void *call
 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
 				data->arg.lock_seqid);
 		if (!IS_ERR(task))
-			rpc_release_task(task);
+			rpc_put_task(task);
 		dprintk("%s: cancelling lock!\n", __FUNCTION__);
 	} else
 		nfs_free_seqid(data->arg.lock_seqid);
@@ -3472,7 +3472,7 @@ static int _nfs4_do_setlk(struct nfs4_st
 			ret = -EAGAIN;
 	} else
 		data->cancelled = 1;
-	rpc_release_task(task);
+	rpc_put_task(task);
 	dprintk("%s: done, ret = %d!\n", __FUNCTION__, ret);
 	return ret;
 }
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index f399c13..9fdb8c9 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -178,13 +178,6 @@ #define rpc_finish_wakeup(t) \
 	} while (0)
 
 #define RPC_IS_ACTIVATED(t)	(test_bit(RPC_TASK_ACTIVE, &(t)->tk_runstate))
-#define rpc_set_active(t)	(set_bit(RPC_TASK_ACTIVE, &(t)->tk_runstate))
-#define rpc_clear_active(t)	\
-	do { \
-		smp_mb__before_clear_bit(); \
-		clear_bit(RPC_TASK_ACTIVE, &(t)->tk_runstate); \
-		smp_mb__after_clear_bit(); \
-	} while(0)
 
 /*
  * Task priorities.
@@ -254,6 +247,7 @@ struct rpc_task *rpc_run_task(struct rpc
 void		rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt,
 				int flags, const struct rpc_call_ops *ops,
 				void *data);
+void		rpc_put_task(struct rpc_task *);
 void		rpc_release_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
 void		rpc_killall_tasks(struct rpc_clnt *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 78696f2..587f3ec 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -467,10 +467,9 @@ int rpc_call_sync(struct rpc_clnt *clnt,
 
 	BUG_ON(flags & RPC_TASK_ASYNC);
 
-	status = -ENOMEM;
 	task = rpc_new_task(clnt, flags, &rpc_default_ops, NULL);
 	if (task == NULL)
-		goto out;
+		return -ENOMEM;
 
 	/* Mask signals on RPC calls _and_ GSS_AUTH upcalls */
 	rpc_task_sigmask(task, &oldset);
@@ -479,15 +478,17 @@ int rpc_call_sync(struct rpc_clnt *clnt,
 
 	/* Set up the call info struct and execute the task */
 	status = task->tk_status;
-	if (status == 0) {
-		atomic_inc(&task->tk_count);
-		status = rpc_execute(task);
-		if (status == 0)
-			status = task->tk_status;
+	if (status != 0) {
+		rpc_release_task(task);
+		goto out;
 	}
-	rpc_restore_sigmask(&oldset);
-	rpc_release_task(task);
+	atomic_inc(&task->tk_count);
+	status = rpc_execute(task);
+	if (status == 0)
+		status = task->tk_status;
+	rpc_put_task(task);
 out:
+	rpc_restore_sigmask(&oldset);
 	return status;
 }
 
diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index e52afab..8d2e10f 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -134,7 +134,7 @@ void rpc_getport(struct rpc_task *task)
 	child = rpc_run_task(pmap_clnt, RPC_TASK_ASYNC, &pmap_getport_ops, map);
 	if (IS_ERR(child))
 		goto bailout;
-	rpc_release_task(child);
+	rpc_put_task(child);
 
 	task->tk_xprt->stat.bind_count++;
 	return;
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index b57d406..66d0136 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -266,12 +266,28 @@ static int rpc_wait_bit_interruptible(vo
 	return 0;
 }
 
+static void rpc_set_active(struct rpc_task *task)
+{
+	if (test_and_set_bit(RPC_TASK_ACTIVE, &task->tk_runstate) != 0)
+		return;
+	spin_lock(&rpc_sched_lock);
+#ifdef RPC_DEBUG
+	task->tk_magic = RPC_TASK_MAGIC_ID;
+	task->tk_pid = rpc_task_id++;
+#endif
+	/* Add to global list of all tasks */
+	list_add_tail(&task->tk_task, &all_tasks);
+	spin_unlock(&rpc_sched_lock);
+}
+
 /*
  * Mark an RPC call as having completed by clearing the 'active' bit
  */
-static inline void rpc_mark_complete_task(struct rpc_task *task)
+static void rpc_mark_complete_task(struct rpc_task *task)
 {
-	rpc_clear_active(task);
+	smp_mb__before_clear_bit();
+	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
+	smp_mb__after_clear_bit();
 	wake_up_bit(&task->tk_runstate, RPC_TASK_ACTIVE);
 }
 
@@ -335,9 +351,6 @@ static void __rpc_sleep_on(struct rpc_wa
 		return;
 	}
 
-	/* Mark the task as being activated if so needed */
-	rpc_set_active(task);
-
 	__rpc_add_wait_queue(q, task);
 
 	BUG_ON(task->tk_callback != NULL);
@@ -348,6 +361,9 @@ static void __rpc_sleep_on(struct rpc_wa
 void rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 				rpc_action action, rpc_action timer)
 {
+	/* Mark the task as being activated if so needed */
+	rpc_set_active(task);
+
 	/*
 	 * Protect the queue operations.
 	 */
@@ -673,8 +689,6 @@ static int __rpc_execute(struct rpc_task
 	}
 
 	dprintk("RPC: %4d, return %d, status %d\n", task->tk_pid, status, task->tk_status);
-	/* Wake up anyone who is waiting for task completion */
-	rpc_mark_complete_task(task);
 	/* Release all resources associated with the task */
 	rpc_release_task(task);
 	return status;
@@ -788,15 +802,6 @@ void rpc_init_task(struct rpc_task *task
 			task->tk_flags |= RPC_TASK_NOINTR;
 	}
 
-#ifdef RPC_DEBUG
-	task->tk_magic = RPC_TASK_MAGIC_ID;
-	task->tk_pid = rpc_task_id++;
-#endif
-	/* Add to global list of all tasks */
-	spin_lock(&rpc_sched_lock);
-	list_add_tail(&task->tk_task, &all_tasks);
-	spin_unlock(&rpc_sched_lock);
-
 	BUG_ON(task->tk_ops == NULL);
 
 	/* starting timestamp */
@@ -849,16 +854,35 @@ cleanup:
 	goto out;
 }
 
-void rpc_release_task(struct rpc_task *task)
+
+void rpc_put_task(struct rpc_task *task)
 {
 	const struct rpc_call_ops *tk_ops = task->tk_ops;
 	void *calldata = task->tk_calldata;
 
+	if (!atomic_dec_and_test(&task->tk_count))
+		return;
+	/* Release resources */
+	if (task->tk_rqstp)
+		xprt_release(task);
+	if (task->tk_msg.rpc_cred)
+		rpcauth_unbindcred(task);
+	if (task->tk_client) {
+		rpc_release_client(task->tk_client);
+		task->tk_client = NULL;
+	}
+	if (task->tk_flags & RPC_TASK_DYNAMIC)
+		rpc_free_task(task);
+	if (tk_ops->rpc_release)
+		tk_ops->rpc_release(calldata);
+}
+EXPORT_SYMBOL(rpc_put_task);
+
+void rpc_release_task(struct rpc_task *task)
+{
 #ifdef RPC_DEBUG
 	BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);
 #endif
-	if (!atomic_dec_and_test(&task->tk_count))
-		return;
 	dprintk("RPC: %4d release task\n", task->tk_pid);
 
 	/* Remove from global task list */
@@ -871,23 +895,13 @@ #endif
 	/* Synchronously delete any running timer */
 	rpc_delete_timer(task);
 
-	/* Release resources */
-	if (task->tk_rqstp)
-		xprt_release(task);
-	if (task->tk_msg.rpc_cred)
-		rpcauth_unbindcred(task);
-	if (task->tk_client) {
-		rpc_release_client(task->tk_client);
-		task->tk_client = NULL;
-	}
-
 #ifdef RPC_DEBUG
 	task->tk_magic = 0;
 #endif
-	if (task->tk_flags & RPC_TASK_DYNAMIC)
-		rpc_free_task(task);
-	if (tk_ops->rpc_release)
-		tk_ops->rpc_release(calldata);
+	/* Wake up anyone who is waiting for task completion */
+	rpc_mark_complete_task(task);
+
+	rpc_put_task(task);
 }
 
 /**
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 192dff5..faaf81e 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -33,7 +33,6 @@ EXPORT_SYMBOL(rpciod_down);
 EXPORT_SYMBOL(rpciod_up);
 EXPORT_SYMBOL(rpc_new_task);
 EXPORT_SYMBOL(rpc_wake_up_status);
-EXPORT_SYMBOL(rpc_release_task);
 
 /* RPC client functions */
 EXPORT_SYMBOL(rpc_clone_client);

--=-SIaND7d9wFPc7i1YLlJd
Content-Disposition: attachment;
	filename=linux-2.6.19-003-rpc_wakeup_fix_pot_race.dif
Content-Type: message/rfc822; name=linux-2.6.19-003-rpc_wakeup_fix_pot_race.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: 1163453024 -0500
SUNRPC: Fix a potential race in rpc_wake_up_task()
Subject: No Subject
Message-Id: <1164948671.5761.11.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Use RCU to ensure that we can safely call rpc_finish_wakeup after we've
called __rpc_do_wake_up_task. If not, there is a theoretical race, in which
the rpc_task finishes executing, and gets freed first.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/read.c                |    8 +++++++-
 fs/nfs/write.c               |   20 ++++++++++++++++----
 include/linux/nfs_fs.h       |    7 ++-----
 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/sched.c           |   30 ++++++++++++++++++++----------
 5 files changed, 47 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index c2e49c3..8b58bbf 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -65,13 +65,19 @@ struct nfs_read_data *nfs_readdata_alloc
 	return p;
 }
 
-static void nfs_readdata_free(struct nfs_read_data *p)
+static void nfs_readdata_rcu_free(struct rcu_head *head)
 {
+	struct nfs_read_data *p = container_of(head, struct nfs_read_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_rdata_mempool);
 }
 
+static void nfs_readdata_free(struct nfs_read_data *rdata)
+{
+	call_rcu_bh(&rdata->task.u.tk_rcu, nfs_readdata_rcu_free);
+}
+
 void nfs_readdata_release(void *data)
 {
         nfs_readdata_free(data);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 883dd4a..29d8820 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -102,13 +102,19 @@ struct nfs_write_data *nfs_commit_alloc(
 	return p;
 }
 
-void nfs_commit_free(struct nfs_write_data *p)
+void nfs_commit_rcu_free(struct rcu_head *head)
 {
+	struct nfs_write_data *p = container_of(head, struct nfs_write_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_commit_mempool);
 }
 
+void nfs_commit_free(struct nfs_write_data *wdata)
+{
+	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_commit_rcu_free);
+}
+
 struct nfs_write_data *nfs_writedata_alloc(size_t len)
 {
 	unsigned int pagecount = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
@@ -131,13 +137,19 @@ struct nfs_write_data *nfs_writedata_all
 	return p;
 }
 
-static void nfs_writedata_free(struct nfs_write_data *p)
+static void nfs_writedata_rcu_free(struct rcu_head *head)
 {
+	struct nfs_write_data *p = container_of(head, struct nfs_write_data, task.u.tk_rcu);
 	if (p && (p->pagevec != &p->page_array[0]))
 		kfree(p->pagevec);
 	mempool_free(p, nfs_wdata_mempool);
 }
 
+static void nfs_writedata_free(struct nfs_write_data *wdata)
+{
+	call_rcu_bh(&wdata->task.u.tk_rcu, nfs_writedata_rcu_free);
+}
+
 void nfs_writedata_release(void *wdata)
 {
 	nfs_writedata_free(wdata);
@@ -258,7 +270,7 @@ static int nfs_writepage_sync(struct nfs
 io_error:
 	nfs_end_data_update(inode);
 	end_page_writeback(page);
-	nfs_writedata_free(wdata);
+	nfs_writedata_release(wdata);
 	return written ? written : result;
 }
 
@@ -1043,7 +1055,7 @@ out_bad:
 	while (!list_empty(&list)) {
 		data = list_entry(list.next, struct nfs_write_data, pages);
 		list_del(&data->pages);
-		nfs_writedata_free(data);
+		nfs_writedata_release(data);
 	}
 	nfs_mark_request_dirty(req);
 	nfs_clear_page_writeback(req);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 45228c1..abde286 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -428,11 +428,6 @@ extern int  nfs_updatepage(struct file *
 extern int nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern void nfs_writedata_release(void *);
 
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-struct nfs_write_data *nfs_commit_alloc(void);
-void nfs_commit_free(struct nfs_write_data *p);
-#endif
-
 /*
  * Try to write back everything synchronously (but check the
  * return value!)
@@ -440,6 +435,8 @@ #endif
 extern int  nfs_sync_inode_wait(struct inode *, unsigned long, unsigned int, int);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
+extern struct nfs_write_data *nfs_commit_alloc(void);
+extern void nfs_commit_free(struct nfs_write_data *wdata);
 extern void nfs_commit_release(void *wdata);
 #else
 static inline int
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 9fdb8c9..14fc813 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -11,6 +11,7 @@ #define _LINUX_SUNRPC_SCHED_H_
 
 #include <linux/timer.h>
 #include <linux/sunrpc/types.h>
+#include <linux/rcupdate.h>
 #include <linux/spinlock.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
@@ -85,6 +86,7 @@ #endif
 	union {
 		struct work_struct	tk_work;	/* Async task work queue */
 		struct rpc_wait		tk_wait;	/* RPC wait */
+		struct rcu_head		tk_rcu;		/* for task deletion */
 	} u;
 
 	unsigned short		tk_timeouts;	/* maj timeouts */
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 66d0136..6b808c0 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -427,16 +427,19 @@ __rpc_default_timer(struct rpc_task *tas
  */
 void rpc_wake_up_task(struct rpc_task *task)
 {
+	rcu_read_lock_bh();
 	if (rpc_start_wakeup(task)) {
 		if (RPC_IS_QUEUED(task)) {
 			struct rpc_wait_queue *queue = task->u.tk_wait.rpc_waitq;
 
-			spin_lock_bh(&queue->lock);
+			/* Note: we're already in a bh-safe context */
+			spin_lock(&queue->lock);
 			__rpc_do_wake_up_task(task);
-			spin_unlock_bh(&queue->lock);
+			spin_unlock(&queue->lock);
 		}
 		rpc_finish_wakeup(task);
 	}
+	rcu_read_unlock_bh();
 }
 
 /*
@@ -499,14 +502,16 @@ struct rpc_task * rpc_wake_up_next(struc
 	struct rpc_task	*task = NULL;
 
 	dprintk("RPC:      wake_up_next(%p \"%s\")\n", queue, rpc_qname(queue));
-	spin_lock_bh(&queue->lock);
+	rcu_read_lock_bh();
+	spin_lock(&queue->lock);
 	if (RPC_IS_PRIORITY(queue))
 		task = __rpc_wake_up_next_priority(queue);
 	else {
 		task_for_first(task, &queue->tasks[0])
 			__rpc_wake_up_task(task);
 	}
-	spin_unlock_bh(&queue->lock);
+	spin_unlock(&queue->lock);
+	rcu_read_unlock_bh();
 
 	return task;
 }
@@ -522,7 +527,8 @@ void rpc_wake_up(struct rpc_wait_queue *
 	struct rpc_task *task, *next;
 	struct list_head *head;
 
-	spin_lock_bh(&queue->lock);
+	rcu_read_lock_bh();
+	spin_lock(&queue->lock);
 	head = &queue->tasks[queue->maxpriority];
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
@@ -531,7 +537,8 @@ void rpc_wake_up(struct rpc_wait_queue *
 			break;
 		head--;
 	}
-	spin_unlock_bh(&queue->lock);
+	spin_unlock(&queue->lock);
+	rcu_read_unlock_bh();
 }
 
 /**
@@ -546,7 +553,8 @@ void rpc_wake_up_status(struct rpc_wait_
 	struct rpc_task *task, *next;
 	struct list_head *head;
 
-	spin_lock_bh(&queue->lock);
+	rcu_read_lock_bh();
+	spin_lock(&queue->lock);
 	head = &queue->tasks[queue->maxpriority];
 	for (;;) {
 		list_for_each_entry_safe(task, next, head, u.tk_wait.list) {
@@ -557,7 +565,8 @@ void rpc_wake_up_status(struct rpc_wait_
 			break;
 		head--;
 	}
-	spin_unlock_bh(&queue->lock);
+	spin_unlock(&queue->lock);
+	rcu_read_unlock_bh();
 }
 
 static void __rpc_atrun(struct rpc_task *task)
@@ -817,8 +826,9 @@ rpc_alloc_task(void)
 	return (struct rpc_task *)mempool_alloc(rpc_task_mempool, GFP_NOFS);
 }
 
-static void rpc_free_task(struct rpc_task *task)
+static void rpc_free_task(struct rcu_head *rcu)
 {
+	struct rpc_task *task = container_of(rcu, struct rpc_task, u.tk_rcu);
 	dprintk("RPC: %4d freeing task\n", task->tk_pid);
 	mempool_free(task, rpc_task_mempool);
 }
@@ -872,7 +882,7 @@ void rpc_put_task(struct rpc_task *task)
 		task->tk_client = NULL;
 	}
 	if (task->tk_flags & RPC_TASK_DYNAMIC)
-		rpc_free_task(task);
+		call_rcu_bh(&task->u.tk_rcu, rpc_free_task);
 	if (tk_ops->rpc_release)
 		tk_ops->rpc_release(calldata);
 }

--=-SIaND7d9wFPc7i1YLlJd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-SIaND7d9wFPc7i1YLlJd
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-SIaND7d9wFPc7i1YLlJd--
