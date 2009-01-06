From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 3/4] sunrpc: Improve UTS namespace workaround
Date: Mon, 05 Jan 2009 17:13:17 -0800
Message-ID: <20090106011315.100081168@us.ibm.com>
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
Received: from e34.co.us.ibm.com ([32.97.110.152]:45678 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbZAFBNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 20:13:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can improve upon a workaround applied in commit 
63ffc23d307c9534c732edd87895e37b223004a3 ( http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=63ffc23d307c9534c732edd87895e37b223004a3 )

The original problem was:

"On a system with nfs mounts, if a task unshares its mount namespace,
a oops can occur when the system is rebooted if the task is the last
to unreference the nfs mount. It will try to create a rpc request
using utsname() which has been invalidated by free_nsproxy()."

Cedric worked around this by always using the initial uts namespace for RPC.
Critically this workaround meant that RPC clients in uts namespaces can never
report the changed nodename when utilizing RPC. 

Fix that by storing the nodename in the NFS server structure (part of the NFS
super block) and, when an RPC client is operating on behalf of NFS, reporting
that nodename. This solves the problem for NFS clients but leaves any other
RPC users out in the cold.

Rather than caching the nodename in the client structure RPC should obtain the
nodename from RPC callers. It would then be up to those services making RPC
calls to cache the nodename for as long as necessary -- somewhat like this patch
does with NFS.

NOTE: Part of Cedric's workaround -- use of the initial uts namespace -- is
still necessary because non-NFS RPC callers still rely on the nodename cached
with the RPC client struct.

Thoughts?

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>

---
 fs/lockd/clntproc.c         |   16 +++++++++++++---
 fs/nfs/client.c             |    6 ++++++
 fs/nfs/super.c              |    6 ++++++
 include/linux/nfs_fs.h      |    2 ++
 include/linux/nfs_fs_sb.h   |    3 +++
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/auth_unix.c      |   13 ++++++++++++-
 7 files changed, 44 insertions(+), 4 deletions(-)

Index: linux-2.6.28/include/linux/sunrpc/clnt.h
===================================================================
--- linux-2.6.28.orig/include/linux/sunrpc/clnt.h
+++ linux-2.6.28/include/linux/sunrpc/clnt.h
@@ -19,6 +19,7 @@
 #include <asm/signal.h>
 
 struct rpc_inode;
+struct nfs_server;
 
 /*
  * The high-level client handle
@@ -50,6 +51,7 @@ struct rpc_clnt {
 
 	int			cl_nodelen;	/* nodename length */
 	char 			cl_nodename[UNX_MAXNODENAME];
+	struct nfs_server	*cl_nfs_server;
 	char			cl_pathname[30];/* Path in rpc_pipe_fs */
 	struct vfsmount *	cl_vfsmnt;
 	struct dentry *		cl_dentry;	/* inode */
Index: linux-2.6.28/net/sunrpc/auth_unix.c
===================================================================
--- linux-2.6.28.orig/net/sunrpc/auth_unix.c
+++ linux-2.6.28/net/sunrpc/auth_unix.c
@@ -12,6 +12,13 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
 
+#include <linux/nfs.h>
+#include <linux/nfs2.h>
+#include <linux/nfs3.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_xdr.h>
+#include <linux/nfs_fs_sb.h>
+
 #define NFS_NGROUPS	16
 
 struct unx_cred {
@@ -151,7 +158,11 @@ unx_marshal(struct rpc_task *task, __be3
 	/*
 	 * Copy the UTS nodename captured when the client was created.
 	 */
-	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
+	if (clnt->cl_nfs_server)
+		p = xdr_encode_array(p, clnt->cl_nfs_server->nodename,
+				     clnt->cl_nfs_server->nodelen);
+	else
+		p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
 
 	*p++ = htonl((u32) cred->uc_uid);
 	*p++ = htonl((u32) cred->uc_gid);
Index: linux-2.6.28/include/linux/nfs_fs_sb.h
===================================================================
--- linux-2.6.28.orig/include/linux/nfs_fs_sb.h
+++ linux-2.6.28/include/linux/nfs_fs_sb.h
@@ -126,6 +126,9 @@ struct nfs_server {
 	u32			mountd_version;
 	unsigned short		mountd_port;
 	unsigned short		mountd_protocol;
+
+	int			nodelen;	/* nodename length */
+	char 			nodename[UNX_MAXNODENAME];
 };
 
 /* Server capabilities */
Index: linux-2.6.28/fs/nfs/super.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/super.c
+++ linux-2.6.28/fs/nfs/super.c
@@ -51,6 +51,7 @@
 #include <linux/nfs_xdr.h>
 #include <linux/magic.h>
 #include <linux/parser.h>
+#include <linux/utsname.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -1830,6 +1831,11 @@ static void nfs_fill_super(struct super_
 		sb->s_time_gran = 1;
 	}
 
+	server->nodelen = strlen(utsname()->nodename);
+	if (server->nodelen > UNX_MAXNODENAME)
+		server->nodelen = UNX_MAXNODENAME;
+	memcpy(server->nodename, utsname()->nodename, server->nodelen);
+
 	sb->s_op = &nfs_sops;
  	nfs_initialise_sb(sb);
 }
Index: linux-2.6.28/fs/nfs/client.c
===================================================================
--- linux-2.6.28.orig/fs/nfs/client.c
+++ linux-2.6.28/fs/nfs/client.c
@@ -25,10 +25,12 @@
 #include <linux/sunrpc/metrics.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/xprtrdma.h>
+#include <linux/sunrpc/svc.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/lockd/bind.h>
+#include <linux/lockd/lockd.h>
 #include <linux/seq_file.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
@@ -47,6 +49,7 @@
 #include "internal.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
+#define NLMDBG_FACILITY		NLMDBG_CLIENT
 
 static DEFINE_SPINLOCK(nfs_client_lock);
 static LIST_HEAD(nfs_client_list);
@@ -555,6 +558,7 @@ static void nfs_init_server_aclclient(st
 
 	/* No errors! Assume that Sun nfsacls are supported */
 	server->caps |= NFS_CAP_ACLS;
+	server->client_acl->cl_nfs_server = server;
 	return;
 
 out_noacl:
@@ -673,6 +677,7 @@ static int nfs_init_server(struct nfs_se
 		goto error;
 
 	server->nfs_client = clp;
+ 	clp->cl_rpcclient->cl_nfs_server = server;
 
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
@@ -1035,6 +1040,7 @@ static int nfs4_set_client(struct nfs_se
 		goto error_put;
 
 	server->nfs_client = clp;
+	clp->cl_rpcclient->cl_nfs_server = server;
 	dprintk("<-- nfs4_set_client() = 0 [new %p]\n", clp);
 	return 0;
 
Index: linux-2.6.28/fs/lockd/clntproc.c
===================================================================
--- linux-2.6.28.orig/fs/lockd/clntproc.c
+++ linux-2.6.28/fs/lockd/clntproc.c
@@ -10,8 +10,8 @@
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
+#include <linux/mount.h>
 #include <linux/nfs_fs.h>
-#include <linux/utsname.h>
 #include <linux/freezer.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc.h>
@@ -118,6 +118,11 @@ static struct nlm_lockowner *nlm_find_lo
 	return res;
 }
 
+struct nfs_server *fl_nfs_server(struct file_lock *fl)
+{
+	return NFS_SB(fl->fl_file->f_path.mnt->mnt_sb);
+}
+
 /*
  * Initialize arguments for TEST/LOCK/UNLOCK/CANCEL calls
  */
@@ -125,15 +130,18 @@ static void nlmclnt_setlockargs(struct n
 {
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_lock	*lock = &argp->lock;
+	char *nodename;
 
 	nlmclnt_next_cookie(&argp->cookie);
 	argp->state   = nsm_local_state;
 	memcpy(&lock->fh, NFS_FH(fl->fl_file->f_path.dentry->d_inode), sizeof(struct nfs_fh));
-	lock->caller  = utsname()->nodename;
+
+	nodename = fl_nfs_server(fl)->nodename;
+	lock->caller  = nodename;
 	lock->oh.data = req->a_owner;
 	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
 				(unsigned int)fl->fl_u.nfs_fl.owner->pid,
-				utsname()->nodename);
+				nodename);
 	lock->svid = fl->fl_u.nfs_fl.owner->pid;
 	lock->fl.fl_start = fl->fl_start;
 	lock->fl.fl_end = fl->fl_end;
@@ -272,6 +280,7 @@ nlmclnt_call(struct rpc_cred *cred, stru
 		/* If we have no RPC client yet, create one. */
 		if ((clnt = nlm_bind_host(host)) == NULL)
 			return -ENOLCK;
+		clnt->cl_nfs_server = fl_nfs_server(&argp->lock.fl);
 		msg.rpc_proc = &clnt->cl_procinfo[proc];
 
 		/* Perform the RPC call. If an error occurs, try again */
@@ -344,6 +353,7 @@ static struct rpc_task *__nlm_async_call
 	clnt = nlm_bind_host(host);
 	if (clnt == NULL)
 		goto out_err;
+	clnt->cl_nfs_server = fl_nfs_server(&req->a_args.lock.fl);
 	msg->rpc_proc = &clnt->cl_procinfo[proc];
 	task_setup_data.rpc_client = clnt;
 
Index: linux-2.6.28/include/linux/nfs_fs.h
===================================================================
--- linux-2.6.28.orig/include/linux/nfs_fs.h
+++ linux-2.6.28/include/linux/nfs_fs.h
@@ -262,6 +262,8 @@ static inline __u64 NFS_FILEID(const str
 	return NFS_I(inode)->fileid;
 }
 
+struct nfs_server *fl_nfs_server(struct file_lock *fl);
+
 static inline void set_nfs_fileid(struct inode *inode, __u64 fileid)
 {
 	NFS_I(inode)->fileid = fileid;

-- 
