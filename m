Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e31.co.us.ibm.com ([32.97.110.149]:43464 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290Ab2A3TaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:01 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:00 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D808D1FF004C
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTw0N144734
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTv2u003863
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:57 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTuGS003773
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:56 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/13] SUNRPC: Use RCU to dereference the rpc_clnt.cl_xprt field
Date: Mon, 30 Jan 2012 13:29:44 -0600
Message-Id: <1327951795-16400-3-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

A migration event will replace the rpc_xprt used by an rpc_clnt.  To
ensure this can be done safely, all references to cl_xprt must now use
a form of rcu_dereference().

Special care is taken with rpc_peeraddr2str(), which returns a pointer
to memory whose lifetime is the same as the rpc_xprt.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: fix lockdep splats and layering violations ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/callback_proc.c       |    9 ++--
 fs/nfs/client.c              |   16 +++++--
 fs/nfs/nfs4proc.c            |   15 +++++--
 fs/nfs/nfs4state.c           |   25 ++++++++----
 fs/nfs/super.c               |    5 ++
 include/linux/sunrpc/clnt.h  |    4 +-
 include/linux/sunrpc/debug.h |   11 +++++
 net/sunrpc/clnt.c            |   94 +++++++++++++++++++++++++++++++++++-------
 net/sunrpc/rpc_pipe.c        |    3 +
 net/sunrpc/rpcb_clnt.c       |   15 +++++--
 net/sunrpc/stats.c           |    6 ++-
 11 files changed, 161 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 54cea8a..60ce755 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -8,6 +8,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfs_fs.h>
 #include <linux/slab.h>
+#include <linux/rcupdate.h>
 #include "nfs4_fs.h"
 #include "callback.h"
 #include "delegation.h"
@@ -33,7 +34,7 @@ __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 	res->bitmap[0] = res->bitmap[1] = 0;
 	res->status = htonl(NFS4ERR_BADHANDLE);
 
-	dprintk("NFS: GETATTR callback request from %s\n",
+	dprintk_rcu("NFS: GETATTR callback request from %s\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	inode = nfs_delegation_find_inode(cps->clp, &args->fh);
@@ -73,7 +74,7 @@ __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 	if (!cps->clp) /* Always set for v4.0. Set in cb_sequence for v4.1 */
 		goto out;
 
-	dprintk("NFS: RECALL callback request from %s\n",
+	dprintk_rcu("NFS: RECALL callback request from %s\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	res = htonl(NFS4ERR_BADHANDLE);
@@ -517,7 +518,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
-	dprintk("NFS: RECALL_ANY callback request from %s\n",
+	dprintk_rcu("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	status = cpu_to_be32(NFS4ERR_INVAL);
@@ -552,7 +553,7 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
-	dprintk("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
+	dprintk_rcu("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR),
 		args->crsa_target_max_slots);
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 31778f7..be5e702 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1284,16 +1284,18 @@ static int nfs4_init_callback(struct nfs_client *clp)
 	int error;
 
 	if (clp->rpc_ops->version == 4) {
+		struct rpc_xprt *xprt;
+
+		xprt = rcu_dereference_raw(clp->cl_rpcclient->cl_xprt);
+
 		if (nfs4_has_session(clp)) {
-			error = xprt_setup_backchannel(
-						clp->cl_rpcclient->cl_xprt,
+			error = xprt_setup_backchannel(xprt,
 						NFS41_BC_MIN_CALLBACKS);
 			if (error < 0)
 				return error;
 		}
 
-		error = nfs_callback_up(clp->cl_mvops->minor_version,
-					clp->cl_rpcclient->cl_xprt);
+		error = nfs_callback_up(clp->cl_mvops->minor_version, xprt);
 		if (error < 0) {
 			dprintk("%s: failed to start callback. Error = %d\n",
 				__func__, error);
@@ -1675,7 +1677,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addrlen,
 				parent_client->cl_ipaddr,
 				data->authflavor,
-				parent_server->client->cl_xprt->prot,
+				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
 				parent_client->cl_mvops->minor_version);
 	if (error < 0)
@@ -1880,12 +1882,14 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 	if (clp->cl_cons_state != NFS_CS_READY)
 		return 0;
 
+	rcu_read_lock();
 	seq_printf(m, "v%u %s %s %3d %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
 		   atomic_read(&clp->cl_count),
 		   clp->cl_hostname);
+	rcu_read_unlock();
 
 	return 0;
 }
@@ -1959,6 +1963,7 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
+	rcu_read_lock();
 	seq_printf(m, "v%u %s %s %-7s %-17s %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
@@ -1966,6 +1971,7 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		   dev,
 		   fsid,
 		   nfs_server_fscache_state(server));
+	rcu_read_unlock();
 
 	return 0;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f0c849c..6ceae67 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3789,6 +3789,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 
 	for(;;) {
+		rcu_read_lock();
 		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
 				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
 				clp->cl_ipaddr,
@@ -3805,6 +3806,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
+		rcu_read_unlock();
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 		if (status != -NFS4ERR_CLID_INUSE)
@@ -5152,11 +5154,16 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 
 void nfs4_destroy_session(struct nfs4_session *session)
 {
+	struct rpc_xprt *xprt;
+
 	nfs4_proc_destroy_session(session);
+
+	rcu_read_lock();
+	xprt = rcu_dereference(session->clp->cl_rpcclient->cl_xprt);
+	rcu_read_unlock();
 	dprintk("%s Destroy backchannel for xprt %p\n",
-		__func__, session->clp->cl_rpcclient->cl_xprt);
-	xprt_destroy_backchannel(session->clp->cl_rpcclient->cl_xprt,
-				NFS41_BC_MIN_CALLBACKS);
+		__func__, xprt);
+	xprt_destroy_backchannel(xprt, NFS41_BC_MIN_CALLBACKS);
 	nfs4_destroy_slot_tables(session);
 	kfree(session);
 }
@@ -5184,7 +5191,7 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 	args->fc_attrs.max_rqst_sz = mxrqst_sz;
 	args->fc_attrs.max_resp_sz = mxresp_sz;
 	args->fc_attrs.max_ops = NFS4_MAX_OPS;
-	args->fc_attrs.max_reqs = session->clp->cl_rpcclient->cl_xprt->max_reqs;
+	args->fc_attrs.max_reqs = rpc_max_reqs(session->clp->cl_rpcclient);
 
 	dprintk("%s: Fore Channel : max_rqst_sz=%u max_resp_sz=%u "
 		"max_ops=%u max_reqs=%u\n",
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a53f33b..c97bbc7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1072,19 +1072,28 @@ static void nfs4_clear_state_manager_bit(struct nfs_client *clp)
 void nfs4_schedule_state_manager(struct nfs_client *clp)
 {
 	struct task_struct *task;
+	char buf[INET6_ADDRSTRLEN + sizeof("-manager") + 1];
 
 	if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 		return;
 	__module_get(THIS_MODULE);
 	atomic_inc(&clp->cl_count);
-	task = kthread_run(nfs4_run_state_manager, clp, "%s-manager",
-				rpc_peeraddr2str(clp->cl_rpcclient,
-							RPC_DISPLAY_ADDR));
-	if (!IS_ERR(task))
-		return;
-	nfs4_clear_state_manager_bit(clp);
-	nfs_put_client(clp);
-	module_put(THIS_MODULE);
+
+	/* The rcu_read_lock() is not strictly necessary, as the state
+	 * manager is the only thread that ever changes the rpc_xprt
+	 * after it's initialized.  At this point, we're single threaded. */
+	rcu_read_lock();
+	snprintf(buf, sizeof(buf), "%s-manager",
+			rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_ADDR));
+	rcu_read_unlock();
+	task = kthread_run(nfs4_run_state_manager, clp, buf);
+	if (IS_ERR(task)) {
+		printk(KERN_ERR "%s: kthread_run: %ld\n",
+			__func__, PTR_ERR(task));
+		nfs4_clear_state_manager_bit(clp);
+		nfs_put_client(clp);
+		module_put(THIS_MODULE);
+	}
 }
 
 /*
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3dfa4f1..f2e7d7c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -52,6 +52,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
+#include <linux/rcupdate.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -676,8 +677,10 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		else
 			seq_puts(m, nfs_infop->nostr);
 	}
+	rcu_read_lock();
 	seq_printf(m, ",proto=%s",
 		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));
+	rcu_read_unlock();
 	if (version == 4) {
 		if (nfss->port != NFS_PORT)
 			seq_printf(m, ",port=%u", nfss->port);
@@ -726,9 +729,11 @@ static int nfs_show_options(struct seq_file *m, struct dentry *root)
 
 	nfs_show_mount_options(m, nfss, 0);
 
+	rcu_read_lock();
 	seq_printf(m, ",addr=%s",
 			rpc_peeraddr2str(nfss->nfs_client->cl_rpcclient,
 							RPC_DISPLAY_ADDR));
+	rcu_read_unlock();
 
 	return 0;
 }
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index c85696e..a0a384f 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -37,7 +37,7 @@ struct rpc_clnt {
 	struct list_head	cl_clients;	/* Global list of clients */
 	struct list_head	cl_tasks;	/* List of tasks */
 	spinlock_t		cl_lock;	/* spinlock */
-	struct rpc_xprt *	cl_xprt;	/* transport */
+	struct rpc_xprt __rcu *	cl_xprt;	/* transport */
 	struct rpc_procinfo *	cl_procinfo;	/* procedure info */
 	u32			cl_prog,	/* RPC program number */
 				cl_vers,	/* RPC version number */
@@ -167,6 +167,8 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 int		rpc_restart_call_prepare(struct rpc_task *);
 int		rpc_restart_call(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
+int		rpc_protocol(struct rpc_clnt *);
+unsigned int	rpc_max_reqs(struct rpc_clnt *);
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index c2786f2..28136fd 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -47,15 +47,26 @@ extern unsigned int		nlm_debug;
 #endif
 
 #define dprintk(args...)	dfprintk(FACILITY, ## args)
+#define dprintk_rcu(args...)	dfprintk_rcu(FACILITY, ## args)
 
 #undef ifdebug
 #ifdef RPC_DEBUG			
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
 # define dfprintk(fac, args...)	do { ifdebug(fac) printk(args); } while(0)
+
+# define dfprintk_rcu(fac, args...)	\
+	do { \
+		ifdebug(fac) { \
+			rcu_read_lock(); \
+			printk(args); \
+			rcu_read_unlock(); \
+		} \
+	} while (0)
 # define RPC_IFDEBUG(x)		x
 #else
 # define ifdebug(fac)		if (0)
 # define dfprintk(fac, args...)	do ; while (0)
+# define dfprintk_rcu(fac, args...)	do ; while (0)
 # define RPC_IFDEBUG(x)
 #endif
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b6a7817..e67eba3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -31,6 +31,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/un.h>
+#include <linux/rcupdate.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -189,7 +190,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	}
 	strlcpy(clnt->cl_server, args->servername, len);
 
-	clnt->cl_xprt     = xprt;
+	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_protname = program->name;
@@ -204,7 +205,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	INIT_LIST_HEAD(&clnt->cl_tasks);
 	spin_lock_init(&clnt->cl_lock);
 
-	if (!xprt_bound(clnt->cl_xprt))
+	if (!xprt_bound(xprt))
 		clnt->cl_autobind = 1;
 
 	clnt->cl_timeout = xprt->timeout;
@@ -376,6 +377,7 @@ struct rpc_clnt *
 rpc_clone_client(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *new;
+	struct rpc_xprt *xprt;
 	int err = -ENOMEM;
 
 	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
@@ -395,6 +397,12 @@ rpc_clone_client(struct rpc_clnt *clnt)
 		if (new->cl_principal == NULL)
 			goto out_no_principal;
 	}
+	rcu_read_lock();
+	xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
+	rcu_read_unlock();
+	if (xprt == NULL)
+		goto out_no_transport;
+	rcu_assign_pointer(new->cl_xprt, xprt);
 	atomic_set(&new->cl_count, 1);
 	atomic_set(&new->cl_active_tasks, 0);
 	rpc_init_wait_queue(&new->cl_waitqueue, "client waitqueue");
@@ -403,12 +411,13 @@ rpc_clone_client(struct rpc_clnt *clnt)
 		goto out_no_path;
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
-	xprt_get(clnt->cl_xprt);
 	atomic_inc(&clnt->cl_count);
 	rpc_register_client(new);
 	rpciod_up();
 	return new;
 out_no_path:
+	xprt_put(xprt);
+out_no_transport:
 	kfree(new->cl_principal);
 out_no_principal:
 	rpc_free_iostats(new->cl_metrics);
@@ -493,7 +502,7 @@ out_free:
 	rpc_free_iostats(clnt->cl_metrics);
 	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;
-	xprt_put(clnt->cl_xprt);
+	xprt_put(rcu_dereference_raw(clnt->cl_xprt));
 	rpciod_down();
 	kfree(clnt);
 }
@@ -850,13 +859,18 @@ EXPORT_SYMBOL_GPL(rpc_call_start);
 size_t rpc_peeraddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t bufsize)
 {
 	size_t bytes;
-	struct rpc_xprt *xprt = clnt->cl_xprt;
+	struct rpc_xprt *xprt;
+
+	rcu_read_lock();
+	xprt = rcu_dereference(clnt->cl_xprt);
 
-	bytes = sizeof(xprt->addr);
+	bytes = xprt->addrlen;
 	if (bytes > bufsize)
 		bytes = bufsize;
-	memcpy(buf, &clnt->cl_xprt->addr, bytes);
-	return xprt->addrlen;
+	memcpy(buf, &xprt->addr, bytes);
+	rcu_read_unlock();
+
+	return bytes;
 }
 EXPORT_SYMBOL_GPL(rpc_peeraddr);
 
@@ -865,11 +879,16 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr);
  * @clnt: RPC client structure
  * @format: address format
  *
+ * NB: the lifetime of the memory referenced by the returned pointer is
+ * the same as the rpc_xprt itself.  As long as the caller uses this
+ * pointer, it must hold the RCU read lock.
  */
 const char *rpc_peeraddr2str(struct rpc_clnt *clnt,
 			     enum rpc_display_format_t format)
 {
-	struct rpc_xprt *xprt = clnt->cl_xprt;
+	struct rpc_xprt *xprt;
+
+	xprt = rcu_dereference(clnt->cl_xprt);
 
 	if (xprt->address_strings[format] != NULL)
 		return xprt->address_strings[format];
@@ -881,14 +900,51 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
 void
 rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize)
 {
-	struct rpc_xprt *xprt = clnt->cl_xprt;
+	struct rpc_xprt *xprt;
+
+	rcu_read_lock();
+	xprt = rcu_dereference(clnt->cl_xprt);
 	if (xprt->ops->set_buffer_size)
 		xprt->ops->set_buffer_size(xprt, sndsize, rcvsize);
+	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(rpc_setbufsize);
 
-/*
- * Return size of largest payload RPC client can support, in bytes
+/**
+ * rpc_protocol - Get transport protocol number for an RPC client
+ * @clnt: RPC client to query
+ *
+ */
+int rpc_protocol(struct rpc_clnt *clnt)
+{
+	int protocol;
+
+	rcu_read_lock();
+	protocol = rcu_dereference(clnt->cl_xprt)->prot;
+	rcu_read_unlock();
+	return protocol;
+}
+EXPORT_SYMBOL_GPL(rpc_protocol);
+
+/**
+ * rpc_max_reqs - Get the maximum number of outstanding requests
+ * @clnt: RPC client to query
+ *
+ */
+unsigned int rpc_max_reqs(struct rpc_clnt *clnt)
+{
+	unsigned int max_reqs;
+
+	rcu_read_lock();
+	max_reqs = rcu_dereference(clnt->cl_xprt)->max_reqs;
+	rcu_read_unlock();
+	return max_reqs;
+}
+EXPORT_SYMBOL_GPL(rpc_max_reqs);
+
+/**
+ * rpc_max_payload - Get maximum payload size for a transport, in bytes
+ * @clnt: RPC client to query
  *
  * For stream transports, this is one RPC record fragment (see RFC
  * 1831), as we don't support multi-record requests yet.  For datagram
@@ -897,7 +953,12 @@ EXPORT_SYMBOL_GPL(rpc_setbufsize);
  */
 size_t rpc_max_payload(struct rpc_clnt *clnt)
 {
-	return clnt->cl_xprt->max_payload;
+	size_t ret;
+
+	rcu_read_lock();
+	ret = rcu_dereference(clnt->cl_xprt)->max_payload;
+	rcu_read_unlock();
+	return ret;
 }
 EXPORT_SYMBOL_GPL(rpc_max_payload);
 
@@ -908,8 +969,11 @@ EXPORT_SYMBOL_GPL(rpc_max_payload);
  */
 void rpc_force_rebind(struct rpc_clnt *clnt)
 {
-	if (clnt->cl_autobind)
-		xprt_clear_bound(clnt->cl_xprt);
+	if (clnt->cl_autobind) {
+		rcu_read_lock();
+		xprt_clear_bound(rcu_dereference(clnt->cl_xprt));
+		rcu_read_unlock();
+	}
 }
 EXPORT_SYMBOL_GPL(rpc_force_rebind);
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 63a7a7a..e8d212d 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,7 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/rcupdate.h>
 
 #include <asm/ioctls.h>
 #include <linux/fs.h>
@@ -378,12 +379,14 @@ rpc_show_info(struct seq_file *m, void *v)
 {
 	struct rpc_clnt *clnt = m->private;
 
+	rcu_read_lock();
 	seq_printf(m, "RPC server: %s\n", clnt->cl_server);
 	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
 			clnt->cl_prog, clnt->cl_vers);
 	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
 	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
 	seq_printf(m, "port: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PORT));
+	rcu_read_unlock();
 	return 0;
 }
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8761bf8..848fe90 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -611,9 +611,10 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
 static struct rpc_clnt *rpcb_find_transport_owner(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *parent = clnt->cl_parent;
+	struct rpc_xprt *xprt = rcu_dereference(clnt->cl_xprt);
 
 	while (parent != clnt) {
-		if (parent->cl_xprt != clnt->cl_xprt)
+		if (rcu_dereference(parent->cl_xprt) != xprt)
 			break;
 		if (clnt->cl_autobind)
 			break;
@@ -644,8 +645,12 @@ void rpcb_getport_async(struct rpc_task *task)
 	size_t salen;
 	int status;
 
-	clnt = rpcb_find_transport_owner(task->tk_client);
-	xprt = clnt->cl_xprt;
+	rcu_read_lock();
+	do {
+		clnt = rpcb_find_transport_owner(task->tk_client);
+		xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
+	} while (xprt == NULL);
+	rcu_read_unlock();
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
@@ -658,6 +663,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (xprt_test_and_set_binding(xprt)) {
 		dprintk("RPC: %5u %s: waiting for another binder\n",
 			task->tk_pid, __func__);
+		xprt_put(xprt);
 		return;
 	}
 
@@ -725,7 +731,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	switch (bind_version) {
 	case RPCBVERS_4:
 	case RPCBVERS_3:
-		map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+		map->r_netid = xprt->address_strings[RPC_DISPLAY_NETID];
 		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_ATOMIC);
 		map->r_owner = "";
 		break;
@@ -754,6 +760,7 @@ bailout_release_client:
 bailout_nofree:
 	rpcb_wake_rpcbind_waiters(xprt, status);
 	task->tk_status = status;
+	xprt_put(xprt);
 }
 EXPORT_SYMBOL_GPL(rpcb_getport_async);
 
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 80df89d..4084255 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -22,6 +22,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcsock.h>
 #include <linux/sunrpc/metrics.h>
+#include <linux/rcupdate.h>
 
 #include "netns.h"
 
@@ -179,7 +180,7 @@ static void _print_name(struct seq_file *seq, unsigned int op,
 void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
 {
 	struct rpc_iostats *stats = clnt->cl_metrics;
-	struct rpc_xprt *xprt = clnt->cl_xprt;
+	struct rpc_xprt *xprt;
 	unsigned int op, maxproc = clnt->cl_maxproc;
 
 	if (!stats)
@@ -189,8 +190,11 @@ void rpc_print_iostats(struct seq_file *seq, struct rpc_clnt *clnt)
 	seq_printf(seq, "p/v: %u/%u (%s)\n",
 			clnt->cl_prog, clnt->cl_vers, clnt->cl_protname);
 
+	rcu_read_lock();
+	xprt = rcu_dereference(clnt->cl_xprt);
 	if (xprt)
 		xprt->ops->print_stats(xprt, seq);
+	rcu_read_unlock();
 
 	seq_printf(seq, "\tper-op statistics\n");
 	for (op = 0; op < maxproc; op++) {
-- 
1.7.8.3

