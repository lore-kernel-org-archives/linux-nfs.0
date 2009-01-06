From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 4/4] Represent RPC Callers
Date: Mon, 05 Jan 2009 17:13:18 -0800
Message-ID: <20090106011315.229045829@us.ibm.com>
References: <20090106011314.534653345@us.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
To: Linux Containers <containers@lists.linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:38475 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbZAFBNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 20:13:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently RPC needs to know the nodename (often the same as the hostname) which
should be used for UNIX-style authentication and file-lock tracking. Because
hostname can change between RPC calls and some sequences of RPC calls may
require consistent names between calls RPC currently saves the nodename with
the RPC client structure.

This is doesn't always work because RPC clients may be discarded over the
lifetime of a higher level service -- like those that compose NFS. Specifically
this is known to happen during shutdown.

Hence RPC should expect the nodename to be saved by the caller when sequences
of RPC calls requiring consistent nodenames may be needed (e.g. NFS). To enable
this we introduce an RPC caller structure that allows RPC to query the caller
for this information.

This patch is not complete but is meant to indicate the direction I'm planning
on going. I'd like to know if there are any objections or if anyone sees a
better way to handle this.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>

---
 fs/lockd/clntproc.c         |   24 ++++++---------
 fs/nfs/client.c             |    6 ---
 fs/nfs/super.c              |    8 +----
 include/linux/lockd/xdr.h   |    3 -
 include/linux/nfs_fs.h      |    2 -
 include/linux/nfs_fs_sb.h   |    3 -
 include/linux/sunrpc/clnt.h |   13 +++++---
 net/sunrpc/auth_unix.c      |   17 ++--------
 net/sunrpc/clnt.c           |   70 +++++++++++++++++++++++++++++++++++++-------
 9 files changed, 88 insertions(+), 58 deletions(-)

Index: linux-2.6.28/include/linux/sunrpc/clnt.h
===================================================================
--- linux-2.6.28.orig/include/linux/sunrpc/clnt.h
+++ linux-2.6.28/include/linux/sunrpc/clnt.h
@@ -19,7 +19,14 @@
 #include <asm/signal.h>
 
 struct rpc_inode;
-struct nfs_server;
+
+struct rpc_caller {
+	struct kref	caller_kref;	/* Number of references from rpc_clnt */
+	void		(*fill_nodename) (struct rpc_caller *caller,
+			     		  char nodename[UNX_MAXNODENAME],
+			     		  int *nodelen);
+	void		(*destroy) (struct kref *caller_kref);
+};
 
 /*
  * The high-level client handle
@@ -49,9 +56,7 @@ struct rpc_clnt {
 	struct rpc_rtt *	cl_rtt;		/* RTO estimator data */
 	const struct rpc_timeout *cl_timeout;	/* Timeout strategy */
 
-	int			cl_nodelen;	/* nodename length */
-	char 			cl_nodename[UNX_MAXNODENAME];
-	struct nfs_server	*cl_nfs_server;
+	struct rpc_caller	*cl_local_caller;
 	char			cl_pathname[30];/* Path in rpc_pipe_fs */
 	struct vfsmount *	cl_vfsmnt;
 	struct dentry *		cl_dentry;	/* inode */
Index: linux-2.6.28/net/sunrpc/clnt.c
===================================================================
--- linux-2.6.28.orig/net/sunrpc/clnt.c
+++ linux-2.6.28/net/sunrpc/clnt.c
@@ -122,13 +122,63 @@ rpc_setup_pipedir(struct rpc_clnt *clnt,
 	}
 }
 
-static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
+/* This RPC caller does not supply a means for RPC to query it. */
+struct rpc_anonymous_caller {
+	struct rpc_caller caller;
+	int nodelen;
+	char nodename[UNX_MAXNODENAME]
+};
+
+static void rpc_anonymous_nodename(struct rpc_caller *caller,
+			  	   char nodename[UNX_MAXNODENAME],
+				   int *nodelen)
+{
+	struct rpc_anonymous_caller *anon;
+
+	anon = container_of(caller, struct rpc_anonymous, caller);
+	memcpy(nodename, anon->nodename, anon->nodelen);
+	*nodelen = anon->nodelen;
+}
+
+static void rpc_anon_caller_destroy(struct kref *caller_ref)
+{
+	struct rpc_anonymous_caller *anon;
+	struct rpc_caller *caller = container_of(caller_ref, struct rpc_caller,
+					 	 caller_ref);
+
+	anon = container_of(caller, struct rpc_anonymous_caller, caller);
+	kfree(anon);
+}
+
+static struct rpc_caller *rpc_new_anon_caller(void)
+{
+	struct rpc_anonymous_caller	*anon;
+	struct new_utsname		*uts_ns;
+
+       	anon = kmalloc(GFP_KERNEL, sizeof(*anon));
+	if (anon == NULL)
+		return NULL;
+	uts_ns = init_utsname();
+	if (current->nsproxy != NULL)
+		uts_ns = utsname();
+	anon->nodelen = strlen(uts_ns->nodename);
+	if (anon->nodelen > UNX_MAXNODENAME)
+		anon->nodelen = UNX_MAXNODENAME;
+	memcpy(anon->nodename, uts_ns->nodename, anon->nodelen);
+	anon->caller.nodename = rpc_anonymous_nodename;
+	anon->caller.destroy = rpc_anon_caller_destroy;
+	kref_init(&anon->caller.caller_kref);
+	return &anon->caller;
+}
+
+static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
+					struct rpc_xprt *xprt,
+					struct rpc_caller *local_caller)
 {
 	struct rpc_program	*program = args->program;
 	struct rpc_version	*version;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
-	struct new_utsname	*uts_ns = init_utsname();
 	int err;
 	size_t len;
 
@@ -213,13 +263,8 @@ static struct rpc_clnt * rpc_new_client(
 		goto out_no_auth;
 	}
 
-	/* save the nodename */
-	if (current->nsproxy != NULL)
-		uts_ns = utsname();
-	clnt->cl_nodelen = strlen(uts_ns->nodename);
-	if (clnt->cl_nodelen > UNX_MAXNODENAME)
-		clnt->cl_nodelen = UNX_MAXNODENAME;
-	memcpy(clnt->cl_nodename, uts_ns->nodename, clnt->cl_nodelen);
+	kref_get(&local_caller->caller_kref);
+	clnt->local_caller = local_caller;
 	rpc_register_client(clnt);
 	return clnt;
 
@@ -252,7 +297,8 @@ out_no_rpciod:
  * it supports this program and version.  RPC_CLNT_CREATE_NOPING disables
  * this behavior so asynchronous tasks can also use rpc_create.
  */
-struct rpc_clnt *rpc_create(struct rpc_create_args *args)
+struct rpc_clnt *rpc_create(struct rpc_create_args *args,
+			    struct rpc_caller *local_caller)
 {
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *clnt;
@@ -307,7 +353,7 @@ struct rpc_clnt *rpc_create(struct rpc_c
 	if (args->flags & RPC_CLNT_CREATE_NONPRIVPORT)
 		xprt->resvport = 0;
 
-	clnt = rpc_new_client(args, xprt);
+	clnt = rpc_new_client(args, xprt, local_caller);
 	if (IS_ERR(clnt))
 		return clnt;
 
@@ -365,6 +411,7 @@ rpc_clone_client(struct rpc_clnt *clnt)
 		atomic_inc(&new->cl_auth->au_count);
 	xprt_get(clnt->cl_xprt);
 	kref_get(&clnt->cl_kref);
+	kref_get(&clnt->local_caller->caller_kref);
 	rpc_register_client(new);
 	rpciod_up();
 	return new;
@@ -422,6 +469,7 @@ out_free:
 	rpc_free_iostats(clnt->cl_metrics);
 	clnt->cl_metrics = NULL;
 	xprt_put(clnt->cl_xprt);
+	kref_put(&clnt->local_caller->caller_kref, clnt->local_caller->destroy);
 	rpciod_down();
 	kfree(clnt);
 }
Index: linux-2.6.28/net/sunrpc/auth_unix.c
===================================================================
--- linux-2.6.28.orig/net/sunrpc/auth_unix.c
+++ linux-2.6.28/net/sunrpc/auth_unix.c
@@ -12,13 +12,6 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
 
-#include <linux/nfs.h>
-#include <linux/nfs2.h>
-#include <linux/nfs3.h>
-#include <linux/nfs4.h>
-#include <linux/nfs_xdr.h>
-#include <linux/nfs_fs_sb.h>
-
 #define NFS_NGROUPS	16
 
 struct unx_cred {
@@ -150,6 +143,8 @@ unx_marshal(struct rpc_task *task, __be3
 	struct unx_cred	*cred = container_of(task->tk_msg.rpc_cred, struct unx_cred, uc_base);
 	__be32		*base, *hold;
 	int		i;
+	int cl_nodelen;
+	char cl_nodename[UNX_MAXNODENAME]
 
 	*p++ = htonl(RPC_AUTH_UNIX);
 	base = p++;
@@ -158,12 +153,8 @@ unx_marshal(struct rpc_task *task, __be3
 	/*
 	 * Copy the UTS nodename captured when the client was created.
 	 */
-	if (clnt->cl_nfs_server)
-		p = xdr_encode_array(p, clnt->cl_nfs_server->nodename,
-				     clnt->cl_nfs_server->nodelen);
-	else
-		p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
-
+	clnt->caller->nodename(cl_nodename, &cl_nodelen);
+	p = xdr_encode_array(p, cl_nodename, cl_nodelen);
 	*p++ = htonl((u32) cred->uc_uid);
 	*p++ = htonl((u32) cred->uc_gid);
 	hold = p++;
Index: linux-2.6.28/fs/nfs/super.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/super.c
+++ linux-2.6.28/fs/nfs/super.c
@@ -1831,11 +1831,9 @@ static void nfs_fill_super(struct super_
 		sb->s_time_gran = 1;
 	}
 
-	server->nodelen = strlen(utsname()->nodename);
-	if (server->nodelen > UNX_MAXNODENAME)
-		server->nodelen = UNX_MAXNODENAME;
-	memcpy(server->nodename, utsname()->nodename, server->nodelen);
-
+	server->rpc_caller = rpc_new_anon_caller();
+	if (server->rpc_caller)
+		kref_get(&server->rpc_caller->caller_kref);
 	sb->s_op = &nfs_sops;
  	nfs_initialise_sb(sb);
 }
Index: linux-2.6.28/fs/lockd/clntproc.c
===================================================================
--- linux-2.6.28.orig/fs/lockd/clntproc.c
+++ linux-2.6.28/fs/lockd/clntproc.c
@@ -118,11 +118,6 @@ static struct nlm_lockowner *nlm_find_lo
 	return res;
 }
 
-struct nfs_server *fl_nfs_server(struct file_lock *fl)
-{
-	return NFS_SB(fl->fl_file->f_path.mnt->mnt_sb);
-}
-
 /*
  * Initialize arguments for TEST/LOCK/UNLOCK/CANCEL calls
  */
@@ -130,18 +125,23 @@ static void nlmclnt_setlockargs(struct n
 {
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_lock	*lock = &argp->lock;
-	char *nodename;
+	struct rpc_clnt *clp;
+	unsigned int nodename_len;
 
 	nlmclnt_next_cookie(&argp->cookie);
 	argp->state   = nsm_local_state;
 	memcpy(&lock->fh, NFS_FH(fl->fl_file->f_path.dentry->d_inode), sizeof(struct nfs_fh));
 
-	nodename = fl_nfs_server(fl)->nodename;
-	lock->caller  = nodename;
 	lock->oh.data = req->a_owner;
-	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
-				(unsigned int)fl->fl_u.nfs_fl.owner->pid,
-				nodename);
+	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@",
+				 (unsigned int)fl->fl_u.nfs_fl.owner->pid);
+	lock->caller = &lock->oh.data[lock->oh.len];
+	clp = req->a_host->h_rpcclnt;
+	clp->cl_local_caller->nodename(clp->cl_local_caller, lock->caller,
+	   			       &nodename_len);
+	lock->oh.len += nodename_len;
+	lock->oh.data[lock->oh.len] = '\0';
+
 	lock->svid = fl->fl_u.nfs_fl.owner->pid;
 	lock->fl.fl_start = fl->fl_start;
 	lock->fl.fl_end = fl->fl_end;
@@ -280,7 +280,6 @@ nlmclnt_call(struct rpc_cred *cred, stru
 		/* If we have no RPC client yet, create one. */
 		if ((clnt = nlm_bind_host(host)) == NULL)
 			return -ENOLCK;
-		clnt->cl_nfs_server = fl_nfs_server(&argp->lock.fl);
 		msg.rpc_proc = &clnt->cl_procinfo[proc];
 
 		/* Perform the RPC call. If an error occurs, try again */
@@ -353,7 +352,6 @@ static struct rpc_task *__nlm_async_call
 	clnt = nlm_bind_host(host);
 	if (clnt == NULL)
 		goto out_err;
-	clnt->cl_nfs_server = fl_nfs_server(&req->a_args.lock.fl);
 	msg->rpc_proc = &clnt->cl_procinfo[proc];
 	task_setup_data.rpc_client = clnt;
 
Index: linux-2.6.28/fs/nfs/client.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/client.c
+++ linux-2.6.28/fs/nfs/client.c
@@ -25,12 +25,10 @@
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/xprtrdma.h>
-#include <linux/sunrpc/svc.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
-#include <linux/lockd/lockd.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
@@ -49,7 +47,6 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
-#define NLMDBG_FACILITY		NLMDBG_CLIENT
 
 static DEFINE_SPINLOCK(nfs_client_lock);
 static LIST_HEAD(nfs_client_list);
@@ -558,7 +555,6 @@ static void nfs_init_server_aclclient(st
 
 	/* No errors! Assume that Sun nfsacls are supported */
 	server->caps |= NFS_CAP_ACLS;
-	server->client_acl->cl_nfs_server = server;
 	return;
 
 out_noacl:
@@ -677,7 +673,6 @@ static int nfs_init_server(struct nfs_se
 		goto error;
 
 	server->nfs_client = clp;
- 	clp->cl_rpcclient->cl_nfs_server = server;
 
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
@@ -1040,7 +1035,6 @@ static int nfs4_set_client(struct nfs_se
 		goto error_put;
 
 	server->nfs_client = clp;
-	clp->cl_rpcclient->cl_nfs_server = server;
 	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
 	return 0;
 
Index: linux-2.6.28/include/linux/lockd/xdr.h
===================================================================
--- linux-2.6.28.orig/include/linux/lockd/xdr.h
+++ linux-2.6.28/include/linux/lockd/xdr.h
@@ -28,8 +28,7 @@ struct svc_rqst;
 
 /* Lock info passed via NLM */
 struct nlm_lock {
-	char *			caller;
-	unsigned int		len; 	/* length of "caller" */
+	struct rpc_caller	*caller;
 	struct nfs_fh		fh;
 	struct xdr_netobj	oh;
 	u32			svid;
Index: linux-2.6.28/include/linux/nfs_fs.h
===================================================================
--- linux-2.6.28.orig/include/linux/nfs_fs.h
+++ linux-2.6.28/include/linux/nfs_fs.h
@@ -262,8 +262,6 @@ static inline __u64 NFS_FILEID(const str
 	return NFS_I(inode)->fileid;
 }
 
-struct nfs_server *fl_nfs_server(struct file_lock *fl);
-
 static inline void set_nfs_fileid(struct inode *inode, __u64 fileid)
 {
 	NFS_I(inode)->fileid = fileid;
Index: linux-2.6.28/include/linux/nfs_fs_sb.h
===================================================================
--- linux-2.6.28.orig/include/linux/nfs_fs_sb.h
+++ linux-2.6.28/include/linux/nfs_fs_sb.h
@@ -127,8 +127,7 @@ struct nfs_server {
 	unsigned short		mountd_port;
 	unsigned short		mountd_protocol;
 
-	int			nodelen;	/* nodename length */
-	char 			nodename[UNX_MAXNODENAME];
+	struct rpc_caller	*rpc_caller;
 };
 
 /* Server capabilities */

-- 
