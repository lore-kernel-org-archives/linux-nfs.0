From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [NFS] NFS Killable tasks request comments on patch
Date: Thu, 6 Dec 2007 16:00:39 -0700
Message-ID: <20071206230038.GA15217__6729.66330680556$1196982144$gmane$org@parisc-linux.org>
References: <20071204212543.GA6907@solidsnake>
	<20071206173426.GC15868@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, neilb@suse.de,
	linux-kernel@vger.kernel.org, trond.myklebust@fys.uio.no,
	bfields@fieldses.org, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
To: Liam Howlett <howlett@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:57690 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893AbXLFXAv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2007 18:00:51 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0Pi4-00060h-Rg
	for linux-nfs@vger.kernel.org; Fri, 07 Dec 2007 10:00:48 +1100
In-Reply-To: <20071206173426.GC15868-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 06, 2007 at 10:34:26AM -0700, Matthew Wilcox wrote:
> I've done a more thorough review of Liam's work and come up with a few
> more fixes (which I'll publish later today)

I've put up a git tree for this work; see
http://git.kernel.org/?p=linux/kernel/git/willy/misc.git;a=shortlog;h=task_killable

I've split up some of the earlier patches, hopefully in a way which will
make akpm less grumpy.  Andrew, let me know if I've misunderstood how
you want to see it.

Here's the commit for the NFS people to chew on a bit.

commit f05b88f294044cdf56fbe637a246ba6c7a14d6f1
Author: Matthew Wilcox <matthew@wil.cx>
Date:   Thu Dec 6 16:24:39 2007 -0500

    NFS: Switch from intr mount option to TASK_KILLABLE
    
    By using the TASK_KILLABLE infrastructure, we can get rid of the 'intr'
    mount option.  We have to use _killable everywhere instead of _interruptible
    as we get rid of rpc_clnt_sigmask/sigunmask.
    
    Signed-off-by: Liam R. Howlett <howlett@gmail.com>
    Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 70587f3..310fa2f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -302,7 +302,7 @@ found_client:
 	if (new)
 		nfs_free_client(new);
 
-	error = wait_event_interruptible(nfs_client_active_wq,
+	error = wait_event_killable(nfs_client_active_wq,
 				clp->cl_cons_state != NFS_CS_INITING);
 	if (error < 0) {
 		nfs_put_client(clp);
@@ -494,10 +494,6 @@ static int nfs_init_server_rpcclient(struct nfs_server *server, rpc_authflavor_t
 	if (server->flags & NFS_MOUNT_SOFT)
 		server->client->cl_softrtry = 1;
 
-	server->client->cl_intr = 0;
-	if (server->flags & NFS4_MOUNT_INTR)
-		server->client->cl_intr = 1;
-
 	return 0;
 }
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 5e8d82f..7b994b2 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -193,7 +193,7 @@ static ssize_t nfs_direct_wait(struct nfs_direct_req *dreq)
 	if (dreq->iocb)
 		goto out;
 
-	result = wait_for_completion_interruptible(&dreq->completion);
+	result = wait_for_completion_killable(&dreq->completion);
 
 	if (!result)
 		result = dreq->error;
@@ -391,9 +391,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 			       unsigned long nr_segs, loff_t pos)
 {
 	ssize_t result = 0;
-	sigset_t oldset;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
-	struct rpc_clnt *clnt = NFS_CLIENT(inode);
 	struct nfs_direct_req *dreq;
 
 	dreq = nfs_direct_req_alloc();
@@ -405,11 +403,9 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	rpc_clnt_sigmask(clnt, &oldset);
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
-	rpc_clnt_sigunmask(clnt, &oldset);
 	nfs_direct_req_release(dreq);
 
 	return result;
@@ -767,9 +763,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				size_t count)
 {
 	ssize_t result = 0;
-	sigset_t oldset;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
-	struct rpc_clnt *clnt = NFS_CLIENT(inode);
 	struct nfs_direct_req *dreq;
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	int sync = 0;
@@ -787,11 +781,9 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	rpc_clnt_sigmask(clnt, &oldset);
 	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
 	if (!result)
 		result = nfs_direct_wait(dreq);
-	rpc_clnt_sigunmask(clnt, &oldset);
 	nfs_direct_req_release(dreq);
 
 	return result;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index db5d96d..f68c222 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -433,15 +433,11 @@ static int nfs_wait_schedule(void *word)
  */
 static int nfs_wait_on_inode(struct inode *inode)
 {
-	struct rpc_clnt	*clnt = NFS_CLIENT(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
-	sigset_t oldmask;
 	int error;
 
-	rpc_clnt_sigmask(clnt, &oldmask);
 	error = wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
-					nfs_wait_schedule, TASK_INTERRUPTIBLE);
-	rpc_clnt_sigunmask(clnt, &oldmask);
+					nfs_wait_schedule, TASK_KILLABLE);
 
 	return error;
 }
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 8afd9f7..49c7cd0 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -56,7 +56,7 @@ int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
 		.program	= &mnt_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= RPC_CLNT_CREATE_INTR,
+		.flags		= 0,
 	};
 	struct rpc_clnt		*mnt_clnt;
 	int			status;
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4cdc236..5ae9634 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -27,17 +27,14 @@
 static int
 nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 {
-	sigset_t oldset;
 	int res;
-	rpc_clnt_sigmask(clnt, &oldset);
 	do {
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EJUKEBOX)
 			break;
-		schedule_timeout_interruptible(NFS_JUKEBOX_RETRY_TIME);
+		schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
-	} while (!signalled());
-	rpc_clnt_sigunmask(clnt, &oldset);
+	} while (!fatal_signal_pending(current));
 	return res;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f03d9d5..c4faa43 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -316,12 +316,9 @@ static void nfs4_opendata_put(struct nfs4_opendata *p)
 
 static int nfs4_wait_for_completion_rpc_task(struct rpc_task *task)
 {
-	sigset_t oldset;
 	int ret;
 
-	rpc_clnt_sigmask(task->tk_client, &oldset);
 	ret = rpc_wait_for_completion_task(task);
-	rpc_clnt_sigunmask(task->tk_client, &oldset);
 	return ret;
 }
 
@@ -2806,9 +2803,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 	return 0;
 }
 
-static int nfs4_wait_bit_interruptible(void *word)
+static int nfs4_wait_bit_killable(void *word)
 {
-	if (signal_pending(current))
+	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
 	schedule();
 	return 0;
@@ -2816,18 +2813,14 @@ static int nfs4_wait_bit_interruptible(void *word)
 
 static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp)
 {
-	sigset_t oldset;
 	int res;
 
 	might_sleep();
 
 	rwsem_acquire(&clp->cl_sem.dep_map, 0, 0, _RET_IP_);
 
-	rpc_clnt_sigmask(clnt, &oldset);
 	res = wait_on_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER,
-			nfs4_wait_bit_interruptible,
-			TASK_INTERRUPTIBLE);
-	rpc_clnt_sigunmask(clnt, &oldset);
+			nfs4_wait_bit_killable, TASK_KILLABLE);
 
 	rwsem_release(&clp->cl_sem.dep_map, 1, _RET_IP_);
 	return res;
@@ -2835,7 +2828,6 @@ static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp)
 
 static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 {
-	sigset_t oldset;
 	int res = 0;
 
 	might_sleep();
@@ -2844,14 +2836,9 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 		*timeout = NFS4_POLL_RETRY_MIN;
 	if (*timeout > NFS4_POLL_RETRY_MAX)
 		*timeout = NFS4_POLL_RETRY_MAX;
-	rpc_clnt_sigmask(clnt, &oldset);
-	if (clnt->cl_intr) {
-		schedule_timeout_interruptible(*timeout);
-		if (signalled())
-			res = -ERESTARTSYS;
-	} else
-		schedule_timeout_uninterruptible(*timeout);
-	rpc_clnt_sigunmask(clnt, &oldset);
+	schedule_timeout_killable(*timeout);
+	if (fatal_signal_pending(current))
+		res = -ERESTARTSYS;
 	*timeout <<= 1;
 	return res;
 }
@@ -3085,7 +3072,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	schedule_timeout_interruptible(timeout);
+	schedule_timeout_killable(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 4b03345..531379d 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -228,10 +228,7 @@ static int __init root_nfs_parse(char *name, char *buf)
 				nfs_data.flags &= ~NFS_MOUNT_SOFT;
 				break;
 			case Opt_intr:
-				nfs_data.flags |= NFS_MOUNT_INTR;
-				break;
 			case Opt_nointr:
-				nfs_data.flags &= ~NFS_MOUNT_INTR;
 				break;
 			case Opt_posix:
 				nfs_data.flags |= NFS_MOUNT_POSIX;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 345bb9b..2dff469 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -67,7 +67,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct inode *inode,
 		if (req != NULL)
 			break;
 
-		if (signalled() && (server->flags & NFS_MOUNT_INTR))
+		if (fatal_signal_pending(current))
 			return ERR_PTR(-ERESTARTSYS);
 		yield();
 	}
@@ -175,11 +175,11 @@ void nfs_release_request(struct nfs_page *req)
 	kref_put(&req->wb_kref, nfs_free_request);
 }
 
-static int nfs_wait_bit_interruptible(void *word)
+static int nfs_wait_bit_killable(void *word)
 {
 	int ret = 0;
 
-	if (signal_pending(current))
+	if (fatal_signal_pending(current))
 		ret = -ERESTARTSYS;
 	else
 		schedule();
@@ -190,26 +190,18 @@ static int nfs_wait_bit_interruptible(void *word)
  * nfs_wait_on_request - Wait for a request to complete.
  * @req: request to wait upon.
  *
- * Interruptible by signals only if mounted with intr flag.
+ * Interruptible by fatal signals only.
  * The user is responsible for holding a count on the request.
  */
 int
 nfs_wait_on_request(struct nfs_page *req)
 {
-	struct rpc_clnt *clnt = NFS_CLIENT(req->wb_context->path.dentry->d_inode);
-	sigset_t oldmask;
 	int ret = 0;
 
 	if (!test_bit(PG_BUSY, &req->wb_flags))
 		goto out;
-	/*
-	 * Note: the call to rpc_clnt_sigmask() suffices to ensure that we
-	 *	 are not interrupted if intr flag is not set
-	 */
-	rpc_clnt_sigmask(clnt, &oldmask);
 	ret = out_of_line_wait_on_bit(&req->wb_flags, PG_BUSY,
-			nfs_wait_bit_interruptible, TASK_INTERRUPTIBLE);
-	rpc_clnt_sigunmask(clnt, &oldmask);
+			nfs_wait_bit_killable, TASK_KILLABLE);
 out:
 	return ret;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 4587a86..3dcaa6a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -212,12 +212,7 @@ nfs_async_read_error(struct list_head *head)
  */
 static void nfs_execute_read(struct nfs_read_data *data)
 {
-	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
-	sigset_t oldset;
-
-	rpc_clnt_sigmask(clnt, &oldset);
 	rpc_execute(&data->task);
-	rpc_clnt_sigunmask(clnt, &oldset);
 }
 
 /*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2426e71..5b6339f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -424,7 +424,6 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		const char *nostr;
 	} nfs_info[] = {
 		{ NFS_MOUNT_SOFT, ",soft", ",hard" },
-		{ NFS_MOUNT_INTR, ",intr", ",nointr" },
 		{ NFS_MOUNT_NOCTO, ",nocto", "" },
 		{ NFS_MOUNT_NOAC, ",noac", "" },
 		{ NFS_MOUNT_NONLM, ",nolock", "" },
@@ -624,10 +623,7 @@ static int nfs_parse_mount_options(char *raw,
 			mnt->flags &= ~NFS_MOUNT_SOFT;
 			break;
 		case Opt_intr:
-			mnt->flags |= NFS_MOUNT_INTR;
-			break;
 		case Opt_nointr:
-			mnt->flags &= ~NFS_MOUNT_INTR;
 			break;
 		case Opt_posix:
 			mnt->flags |= NFS_MOUNT_POSIX;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 51cc1bd..60e3e87 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -490,7 +490,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req)
 /*
  * Wait for a request to complete.
  *
- * Interruptible by signals only if mounted with intr flag.
+ * Interruptible by fatal signals only.
  */
 static int nfs_wait_on_requests_locked(struct inode *inode, pgoff_t idx_start, unsigned int npages)
 {
@@ -816,12 +816,7 @@ static void nfs_write_rpcsetup(struct nfs_page *req,
 
 static void nfs_execute_write(struct nfs_write_data *data)
 {
-	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
-	sigset_t oldset;
-
-	rpc_clnt_sigmask(clnt, &oldset);
 	rpc_execute(&data->task);
-	rpc_clnt_sigunmask(clnt, &oldset);
 }
 
 /*
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2d15d4a..2814bd4 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -516,14 +516,7 @@ extern void * nfs_root_data(void);
 
 #define nfs_wait_event(clnt, wq, condition)				\
 ({									\
-	int __retval = 0;						\
-	if (clnt->cl_intr) {						\
-		sigset_t oldmask;					\
-		rpc_clnt_sigmask(clnt, &oldmask);			\
-		__retval = wait_event_interruptible(wq, condition);	\
-		rpc_clnt_sigunmask(clnt, &oldmask);			\
-	} else								\
-		wait_event(wq, condition);				\
+	int __retval = wait_event_killable(wq, condition);		\
 	__retval;							\
 })
 
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index a3ade89..df7c6b7 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -48,7 +48,7 @@ struct nfs_mount_data {
 /* bits in the flags field */
 
 #define NFS_MOUNT_SOFT		0x0001	/* 1 */
-#define NFS_MOUNT_INTR		0x0002	/* 1 */
+#define NFS_MOUNT_INTR		0x0002	/* 1 */ /* now unused, but ABI */
 #define NFS_MOUNT_SECURE	0x0004	/* 1 */
 #define NFS_MOUNT_POSIX		0x0008	/* 1 */
 #define NFS_MOUNT_NOCTO		0x0010	/* 1 */
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index d9d5c5a..0187936 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -41,7 +41,6 @@ struct rpc_clnt {
 	struct rpc_iostats *	cl_metrics;	/* per-client statistics */
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
-				cl_intr     : 1,/* interruptible */
 				cl_discrtry : 1,/* disconnect before retry */
 				cl_autobind : 1;/* use getport() */
 
@@ -109,7 +108,6 @@ struct rpc_create_args {
 
 /* Values for "flags" field */
 #define RPC_CLNT_CREATE_HARDRTRY	(1UL << 0)
-#define RPC_CLNT_CREATE_INTR		(1UL << 1)
 #define RPC_CLNT_CREATE_AUTOBIND	(1UL << 2)
 #define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 3)
 #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 8ea077d..19160e6 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -128,7 +128,6 @@ struct rpc_call_ops {
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
 #define RPC_TASK_KILLED		0x0100		/* task was killed */
 #define RPC_TASK_SOFT		0x0200		/* Use soft timeouts */
-#define RPC_TASK_NOINTR		0x0400		/* uninterruptible task */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
@@ -136,7 +135,6 @@ struct rpc_call_ops {
 #define RPC_ASSASSINATED(t)	((t)->tk_flags & RPC_TASK_KILLED)
 #define RPC_DO_CALLBACK(t)	((t)->tk_callback != NULL)
 #define RPC_IS_SOFT(t)		((t)->tk_flags & RPC_TASK_SOFT)
-#define RPC_TASK_UNINTERRUPTIBLE(t) ((t)->tk_flags & RPC_TASK_NOINTR)
 
 #define RPC_TASK_RUNNING	0
 #define RPC_TASK_QUEUED		1
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76be83e..a99729f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -281,7 +281,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		return clnt;
 
 	if (!(args->flags & RPC_CLNT_CREATE_NOPING)) {
-		int err = rpc_ping(clnt, RPC_TASK_SOFT|RPC_TASK_NOINTR);
+		int err = rpc_ping(clnt, RPC_TASK_SOFT);
 		if (err != 0) {
 			rpc_shutdown_client(clnt);
 			return ERR_PTR(err);
@@ -292,8 +292,6 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	if (args->flags & RPC_CLNT_CREATE_HARDRTRY)
 		clnt->cl_softrtry = 0;
 
-	if (args->flags & RPC_CLNT_CREATE_INTR)
-		clnt->cl_intr = 1;
 	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
@@ -459,7 +457,7 @@ struct rpc_clnt *rpc_bind_new_program(struct rpc_clnt *old,
 	clnt->cl_prog     = program->number;
 	clnt->cl_vers     = version->number;
 	clnt->cl_stats    = program->stats;
-	err = rpc_ping(clnt, RPC_TASK_SOFT|RPC_TASK_NOINTR);
+	err = rpc_ping(clnt, RPC_TASK_SOFT);
 	if (err != 0) {
 		rpc_shutdown_client(clnt);
 		clnt = ERR_PTR(err);
@@ -480,44 +478,6 @@ static const struct rpc_call_ops rpc_default_ops = {
 	.rpc_call_done = rpc_default_callback,
 };
 
-/*
- *	Export the signal mask handling for synchronous code that
- *	sleeps on RPC calls
- */
-#define RPC_INTR_SIGNALS (sigmask(SIGHUP) | sigmask(SIGINT) | sigmask(SIGQUIT) | sigmask(SIGTERM))
-
-static void rpc_save_sigmask(sigset_t *oldset, int intr)
-{
-	unsigned long	sigallow = sigmask(SIGKILL);
-	sigset_t sigmask;
-
-	/* Block all signals except those listed in sigallow */
-	if (intr)
-		sigallow |= RPC_INTR_SIGNALS;
-	siginitsetinv(&sigmask, sigallow);
-	sigprocmask(SIG_BLOCK, &sigmask, oldset);
-}
-
-static inline void rpc_task_sigmask(struct rpc_task *task, sigset_t *oldset)
-{
-	rpc_save_sigmask(oldset, !RPC_TASK_UNINTERRUPTIBLE(task));
-}
-
-static inline void rpc_restore_sigmask(sigset_t *oldset)
-{
-	sigprocmask(SIG_SETMASK, oldset, NULL);
-}
-
-void rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset)
-{
-	rpc_save_sigmask(oldset, clnt->cl_intr);
-}
-
-void rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset)
-{
-	rpc_restore_sigmask(oldset);
-}
-
 static
 struct rpc_task *rpc_do_run_task(struct rpc_clnt *clnt,
 		struct rpc_message *msg,
@@ -526,7 +486,6 @@ struct rpc_task *rpc_do_run_task(struct rpc_clnt *clnt,
 		void *data)
 {
 	struct rpc_task *task, *ret;
-	sigset_t oldset;
 
 	task = rpc_new_task(clnt, flags, ops, data);
 	if (task == NULL) {
@@ -535,7 +494,6 @@ struct rpc_task *rpc_do_run_task(struct rpc_clnt *clnt,
 	}
 
 	/* Mask signals on synchronous RPC calls and RPCSEC_GSS upcalls */
-	rpc_task_sigmask(task, &oldset);
 	if (msg != NULL) {
 		rpc_call_setup(task, msg, 0);
 		if (task->tk_status != 0) {
@@ -548,7 +506,6 @@ struct rpc_task *rpc_do_run_task(struct rpc_clnt *clnt,
 	rpc_execute(task);
 	ret = task;
 out:
-	rpc_restore_sigmask(&oldset);
 	return ret;
 }
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a05493a..c35b6e7 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -172,8 +172,7 @@ static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
 		.program	= &rpcb_program,
 		.version	= version,
 		.authflavor	= RPC_AUTH_UNIX,
-		.flags		= (RPC_CLNT_CREATE_NOPING |
-				   RPC_CLNT_CREATE_INTR),
+		.flags		= RPC_CLNT_CREATE_NOPING,
 	};
 
 	switch (srvaddr->sa_family) {
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c98873f..4b22910 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -245,9 +245,9 @@ void rpc_init_wait_queue(struct rpc_wait_queue *queue, const char *qname)
 }
 EXPORT_SYMBOL(rpc_init_wait_queue);
 
-static int rpc_wait_bit_interruptible(void *word)
+static int rpc_wait_bit_killable(void *word)
 {
-	if (signal_pending(current))
+	if (fatal_signal_pending(current))
 		return -ERESTARTSYS;
 	schedule();
 	return 0;
@@ -299,9 +299,9 @@ static void rpc_mark_complete_task(struct rpc_task *task)
 int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(void *))
 {
 	if (action == NULL)
-		action = rpc_wait_bit_interruptible;
+		action = rpc_wait_bit_killable;
 	return wait_on_bit(&task->tk_runstate, RPC_TASK_ACTIVE,
-			action, TASK_INTERRUPTIBLE);
+			action, TASK_KILLABLE);
 }
 EXPORT_SYMBOL(__rpc_wait_for_completion_task);
 
@@ -690,10 +690,9 @@ static void __rpc_execute(struct rpc_task *task)
 
 		/* sync task: sleep here */
 		dprintk("RPC: %5u sync task going to sleep\n", task->tk_pid);
-		/* Note: Caller should be using rpc_clnt_sigmask() */
 		status = out_of_line_wait_on_bit(&task->tk_runstate,
-				RPC_TASK_QUEUED, rpc_wait_bit_interruptible,
-				TASK_INTERRUPTIBLE);
+				RPC_TASK_QUEUED, rpc_wait_bit_killable,
+				TASK_KILLABLE);
 		if (status == -ERESTARTSYS) {
 			/*
 			 * When a sync task receives a signal, it exits with
@@ -837,8 +836,6 @@ void rpc_init_task(struct rpc_task *task, struct rpc_clnt *clnt, int flags, cons
 		kref_get(&clnt->cl_kref);
 		if (clnt->cl_softrtry)
 			task->tk_flags |= RPC_TASK_SOFT;
-		if (!clnt->cl_intr)
-			task->tk_flags |= RPC_TASK_NOINTR;
 	}
 
 	BUG_ON(task->tk_ops == NULL);
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 33d89e8..1fd3aa8 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -38,8 +38,6 @@ EXPORT_SYMBOL(rpc_killall_tasks);
 EXPORT_SYMBOL(rpc_call_sync);
 EXPORT_SYMBOL(rpc_call_async);
 EXPORT_SYMBOL(rpc_call_setup);
-EXPORT_SYMBOL(rpc_clnt_sigmask);
-EXPORT_SYMBOL(rpc_clnt_sigunmask);
 EXPORT_SYMBOL(rpc_delay);
 EXPORT_SYMBOL(rpc_restart_call);
 EXPORT_SYMBOL(rpc_setbufsize);

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

