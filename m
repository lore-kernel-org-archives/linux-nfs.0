Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45757 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758374Ab2CBV7H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Mar 2012 16:59:07 -0500
Received: by mail-iy0-f174.google.com with SMTP id z16so2853208iag.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Mar 2012 13:59:06 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/12] SUNRPC: Use RCU to dereference the rpc_clnt.cl_xprt
 field
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 02 Mar 2012 16:59:05 -0500
Message-ID: <20120302215904.12758.6625.stgit@degas.1015granger.net>
In-Reply-To: <20120302215559.12758.39526.stgit@degas.1015granger.net>
References: <20120302215559.12758.39526.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
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
[ cel: forward ported to 3.4 ]
[ cel: remove rpc_max_reqs(), add rpc_net_ns() ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback_proc.c         |    9 ++-
 fs/nfs/client.c                |   16 ++++--
 fs/nfs/nfs4namespace.c         |    2 -
 fs/nfs/nfs4proc.c              |   13 ++++-
 fs/nfs/nfs4state.c             |   25 ++++++---
 fs/nfs/super.c                 |    5 ++
 include/linux/sunrpc/clnt.h    |    4 +
 include/linux/sunrpc/debug.h   |   13 +++++
 net/sunrpc/auth_gss/auth_gss.c |    4 +
 net/sunrpc/clnt.c              |  110 ++++++++++++++++++++++++++++++++--------
 net/sunrpc/rpc_pipe.c          |    3 +
 net/sunrpc/rpcb_clnt.c         |   15 ++++-
 net/sunrpc/stats.c             |    6 ++
 13 files changed, 175 insertions(+), 50 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f71978d..2db26be 100644
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
@@ -537,7 +538,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
-	dprintk("NFS: RECALL_ANY callback request from %s\n",
+	dprintk_rcu("NFS: RECALL_ANY callback request from %s\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR));
 
 	status = cpu_to_be32(NFS4ERR_INVAL);
@@ -572,7 +573,7 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
-	dprintk("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
+	dprintk_rcu("NFS: CB_RECALL_SLOT request from %s target max slots %d\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR),
 		args->crsa_target_max_slots);
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8563585..994899d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1282,16 +1282,18 @@ static int nfs4_init_callback(struct nfs_client *clp)
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
@@ -1676,7 +1678,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addrlen,
 				parent_client->cl_ipaddr,
 				data->authflavor,
-				parent_server->client->cl_xprt->prot,
+				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
 				parent_client->cl_mvops->minor_version,
 				parent_client->net);
@@ -1903,12 +1905,14 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
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
@@ -1991,6 +1995,7 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
+	rcu_read_lock();
 	seq_printf(m, "v%u %s %s %-7s %-17s %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
@@ -1998,6 +2003,7 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		   dev,
 		   fsid,
 		   nfs_server_fscache_state(server));
+	rcu_read_unlock();
 
 	return 0;
 }
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 667ea74..9c8eca3 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -96,8 +96,8 @@ static int nfs4_validate_fspath(struct dentry *dentry,
 static size_t nfs_parse_server_name(char *string, size_t len,
 		struct sockaddr *sa, size_t salen, struct nfs_server *server)
 {
+	struct net *net = rpc_net_ns(server->client);
 	ssize_t ret;
-	struct net *net = server->client->cl_xprt->xprt_net;
 
 	ret = rpc_pton(net, string, len, sa, salen);
 	if (ret == 0) {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 53daab9..3ec09fb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3833,6 +3833,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 	*p = htonl((u32)clp->cl_boot_time.tv_nsec);
 
 	for(;;) {
+		rcu_read_lock();
 		setclientid.sc_name_len = scnprintf(setclientid.sc_name,
 				sizeof(setclientid.sc_name), "%s/%s %s %s %u",
 				clp->cl_ipaddr,
@@ -3849,6 +3850,7 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		setclientid.sc_uaddr_len = scnprintf(setclientid.sc_uaddr,
 				sizeof(setclientid.sc_uaddr), "%s.%u.%u",
 				clp->cl_ipaddr, port >> 8, port & 255);
+		rcu_read_unlock();
 
 		status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 		if (status != -NFS4ERR_CLID_INUSE)
@@ -5220,11 +5222,16 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 
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
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c1111a3..bae959e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1037,19 +1037,28 @@ static void nfs4_clear_state_manager_bit(struct nfs_client *clp)
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
index 6708f30..72c7f63 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -53,6 +53,7 @@
 #include <linux/magic.h>
 #include <linux/parser.h>
 #include <linux/nsproxy.h>
+#include <linux/rcupdate.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -679,8 +680,10 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
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
@@ -729,9 +732,11 @@ static int nfs_show_options(struct seq_file *m, struct dentry *root)
 
 	nfs_show_mount_options(m, nfss, 0);
 
+	rcu_read_lock();
 	seq_printf(m, ",addr=%s",
 			rpc_peeraddr2str(nfss->nfs_client->cl_rpcclient,
 							RPC_DISPLAY_ADDR));
+	rcu_read_unlock();
 
 	return 0;
 }
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a4c62e9..e3d12b4 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -35,7 +35,7 @@ struct rpc_clnt {
 	struct list_head	cl_clients;	/* Global list of clients */
 	struct list_head	cl_tasks;	/* List of tasks */
 	spinlock_t		cl_lock;	/* spinlock */
-	struct rpc_xprt *	cl_xprt;	/* transport */
+	struct rpc_xprt __rcu *	cl_xprt;	/* transport */
 	struct rpc_procinfo *	cl_procinfo;	/* procedure info */
 	u32			cl_prog,	/* RPC program number */
 				cl_vers,	/* RPC version number */
@@ -156,6 +156,8 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 int		rpc_restart_call_prepare(struct rpc_task *);
 int		rpc_restart_call(struct rpc_task *);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
+int		rpc_protocol(struct rpc_clnt *);
+struct net *	rpc_net_ns(struct rpc_clnt *);
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index b506936..6cb2517 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -50,19 +50,32 @@ extern unsigned int		nlm_debug;
 #endif
 
 #define dprintk(args...)	dfprintk(FACILITY, ## args)
+#define dprintk_rcu(args...)	dfprintk_rcu(FACILITY, ## args)
 
 #undef ifdebug
 #ifdef RPC_DEBUG			
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
+
 # define dfprintk(fac, args...)	\
 	do { \
 		ifdebug(fac) \
 			printk(KERN_DEFAULT args); \
 	} while (0)
+
+# define dfprintk_rcu(fac, args...)	\
+	do { \
+		ifdebug(fac) { \
+			rcu_read_lock(); \
+			printk(KERN_DEFAULT args); \
+			rcu_read_unlock(); \
+		} \
+	} while (0)
+
 # define RPC_IFDEBUG(x)		x
 #else
 # define ifdebug(fac)		if (0)
 # define dfprintk(fac, args...)	do ; while (0)
+# define dfprintk_rcu(fac, args...)	do ; while (0)
 # define RPC_IFDEBUG(x)
 #endif
 
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cb2e564..d3ad81f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -799,7 +799,7 @@ err_unlink_pipe_1:
 static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
 					   struct rpc_auth *auth)
 {
-	struct net *net = clnt->cl_xprt->xprt_net;
+	struct net *net = rpc_net_ns(clnt);
 	struct super_block *sb;
 
 	sb = rpc_get_sb_net(net);
@@ -813,7 +813,7 @@ static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
 static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
 					 struct rpc_auth *auth)
 {
-	struct net *net = clnt->cl_xprt->xprt_net;
+	struct net *net = rpc_net_ns(clnt);
 	struct super_block *sb;
 	int err = 0;
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bb7ed2f3..f043c7b 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -31,6 +31,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/un.h>
+#include <linux/rcupdate.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -81,7 +82,8 @@ static int	rpc_ping(struct rpc_clnt *clnt);
 
 static void rpc_register_client(struct rpc_clnt *clnt)
 {
-	struct sunrpc_net *sn = net_generic(clnt->cl_xprt->xprt_net, sunrpc_net_id);
+	struct net *net = rpc_net_ns(clnt);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	spin_lock(&sn->rpc_client_lock);
 	list_add(&clnt->cl_clients, &sn->all_clients);
@@ -90,7 +92,8 @@ static void rpc_register_client(struct rpc_clnt *clnt)
 
 static void rpc_unregister_client(struct rpc_clnt *clnt)
 {
-	struct sunrpc_net *sn = net_generic(clnt->cl_xprt->xprt_net, sunrpc_net_id);
+	struct net *net = rpc_net_ns(clnt);
+	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
 	spin_lock(&sn->rpc_client_lock);
 	list_del(&clnt->cl_clients);
@@ -109,12 +112,13 @@ static void __rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 
 static void rpc_clnt_remove_pipedir(struct rpc_clnt *clnt)
 {
+	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
 
-	pipefs_sb = rpc_get_sb_net(clnt->cl_xprt->xprt_net);
+	pipefs_sb = rpc_get_sb_net(net);
 	if (pipefs_sb) {
 		__rpc_clnt_remove_pipedir(clnt);
-		rpc_put_sb_net(clnt->cl_xprt->xprt_net);
+		rpc_put_sb_net(net);
 	}
 }
 
@@ -155,17 +159,18 @@ static struct dentry *rpc_setup_pipedir_sb(struct super_block *sb,
 static int
 rpc_setup_pipedir(struct rpc_clnt *clnt, const char *dir_name)
 {
+	struct net *net = rpc_net_ns(clnt);
 	struct super_block *pipefs_sb;
 	struct dentry *dentry;
 
 	clnt->cl_dentry = NULL;
 	if (dir_name == NULL)
 		return 0;
-	pipefs_sb = rpc_get_sb_net(clnt->cl_xprt->xprt_net);
+	pipefs_sb = rpc_get_sb_net(net);
 	if (!pipefs_sb)
 		return 0;
 	dentry = rpc_setup_pipedir_sb(pipefs_sb, clnt, dir_name);
-	rpc_put_sb_net(clnt->cl_xprt->xprt_net);
+	rpc_put_sb_net(net);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 	clnt->cl_dentry = dentry;
@@ -279,7 +284,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	if (clnt->cl_server == NULL)
 		goto out_no_server;
 
-	clnt->cl_xprt     = xprt;
+	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_protname = program->name;
@@ -294,7 +299,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	INIT_LIST_HEAD(&clnt->cl_tasks);
 	spin_lock_init(&clnt->cl_lock);
 
-	if (!xprt_bound(clnt->cl_xprt))
+	if (!xprt_bound(xprt))
 		clnt->cl_autobind = 1;
 
 	clnt->cl_timeout = xprt->timeout;
@@ -461,6 +466,7 @@ struct rpc_clnt *
 rpc_clone_client(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *new;
+	struct rpc_xprt *xprt;
 	int err = -ENOMEM;
 
 	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
@@ -483,18 +489,25 @@ rpc_clone_client(struct rpc_clnt *clnt)
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
 	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
 	if (err != 0)
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
@@ -574,7 +587,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 	rpc_free_iostats(clnt->cl_metrics);
 	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;
-	xprt_put(clnt->cl_xprt);
+	xprt_put(rcu_dereference_raw(clnt->cl_xprt));
 	rpciod_down();
 	kfree(clnt);
 }
@@ -863,13 +876,18 @@ EXPORT_SYMBOL_GPL(rpc_call_start);
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
 
@@ -878,11 +896,16 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr);
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
@@ -894,14 +917,51 @@ EXPORT_SYMBOL_GPL(rpc_peeraddr2str);
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
+ * rpc_net_ns - Get the network namespace for this RPC client
+ * @clnt: RPC client to query
+ *
+ */
+struct net *rpc_net_ns(struct rpc_clnt *clnt)
+{
+	struct net *ret;
+
+	rcu_read_lock();
+	ret = rcu_dereference(clnt->cl_xprt)->xprt_net;
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(rpc_net_ns);
+
+/**
+ * rpc_max_payload - Get maximum payload size for a transport, in bytes
+ * @clnt: RPC client to query
  *
  * For stream transports, this is one RPC record fragment (see RFC
  * 1831), as we don't support multi-record requests yet.  For datagram
@@ -910,7 +970,12 @@ EXPORT_SYMBOL_GPL(rpc_setbufsize);
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
 
@@ -921,8 +986,11 @@ EXPORT_SYMBOL_GPL(rpc_max_payload);
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
index 6873c9b..bbd636b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -16,6 +16,7 @@
 #include <linux/namei.h>
 #include <linux/fsnotify.h>
 #include <linux/kernel.h>
+#include <linux/rcupdate.h>
 
 #include <asm/ioctls.h>
 #include <linux/poll.h>
@@ -383,12 +384,14 @@ rpc_show_info(struct seq_file *m, void *v)
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
index b1f08bd..4f8af63 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -620,9 +620,10 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
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
@@ -653,8 +654,12 @@ void rpcb_getport_async(struct rpc_task *task)
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
@@ -667,6 +672,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	if (xprt_test_and_set_binding(xprt)) {
 		dprintk("RPC: %5u %s: waiting for another binder\n",
 			task->tk_pid, __func__);
+		xprt_put(xprt);
 		return;
 	}
 
@@ -734,7 +740,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	switch (bind_version) {
 	case RPCBVERS_4:
 	case RPCBVERS_3:
-		map->r_netid = rpc_peeraddr2str(clnt, RPC_DISPLAY_NETID);
+		map->r_netid = xprt->address_strings[RPC_DISPLAY_NETID];
 		map->r_addr = rpc_sockaddr2uaddr(sap, GFP_ATOMIC);
 		map->r_owner = "";
 		break;
@@ -763,6 +769,7 @@ bailout_release_client:
 bailout_nofree:
 	rpcb_wake_rpcbind_waiters(xprt, status);
 	task->tk_status = status;
+	xprt_put(xprt);
 }
 EXPORT_SYMBOL_GPL(rpcb_getport_async);
 
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index 1eb3304..bc2068e 100644
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

