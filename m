From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: [PATCH 2/3 2.6.9-rc2] remove broken_suid mount option
Date: Thu, 16 Sep 2004 01:50:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040915235034.GB23903@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C7jXn-00071o-SY
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 16:50:35 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C7jXm-0002qH-Pm
	for nfs@lists.sourceforge.net; Wed, 15 Sep 2004 16:50:35 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Subject says it all. One final bit gave me some more thinking
so I'll send it as the third, final patch in this sequence.

Signed-off-by: Frank van Maarseveen <frankvm@xs4all.nl>

--- d/fs/nfs/inode.c.orig	2004-09-14 23:03:09.000000000 +0200
+++ d/fs/nfs/inode.c	2004-09-15 22:28:36.000000000 +0200
@@ -362,7 +362,10 @@
 
 	clnt->cl_intr     = (server->flags & NFS_MOUNT_INTR) ? 1 : 0;
 	clnt->cl_softrtry = (server->flags & NFS_MOUNT_SOFT) ? 1 : 0;
-	clnt->cl_droppriv = (server->flags & NFS_MOUNT_BROKEN_SUID) ? 1 : 0;
+	if (server->flags & NFS_MOUNT_BROKEN_SUID) {
+		printk(KERN_WARNING "NFS: mount option \"broken_suid\" ignored.\n");
+		server->flags &= ~NFS_MOUNT_BROKEN_SUID;
+	}
 	clnt->cl_chatty   = 1;
 
 	return clnt;
@@ -519,7 +522,6 @@
 		{ NFS_MOUNT_NOCTO, ",nocto", "" },
 		{ NFS_MOUNT_NOAC, ",noac", "" },
 		{ NFS_MOUNT_NONLM, ",nolock", ",lock" },
-		{ NFS_MOUNT_BROKEN_SUID, ",broken_suid", "" },
 		{ 0, NULL, NULL }
 	};
 	struct proc_nfs_info *nfs_infop;
--- d/fs/nfs/nfsroot.c.orig	2004-05-10 04:32:54.000000000 +0200
+++ d/fs/nfs/nfsroot.c	2004-09-15 22:21:10.000000000 +0200
@@ -124,7 +124,6 @@
 	Opt_soft, Opt_hard, Opt_intr,
 	Opt_nointr, Opt_posix, Opt_noposix, Opt_cto, Opt_nocto, Opt_ac, 
 	Opt_noac, Opt_lock, Opt_nolock, Opt_v2, Opt_v3, Opt_udp, Opt_tcp,
-	Opt_broken_suid,
 	/* Error token */
 	Opt_err
 };
@@ -159,7 +158,6 @@
 	{Opt_udp, "udp"},
 	{Opt_tcp, "proto=tcp"},
 	{Opt_tcp, "tcp"},
-	{Opt_broken_suid, "broken_suid"},
 	{Opt_err, NULL}
 	
 };
@@ -268,9 +266,6 @@
 			case Opt_tcp:
 				nfs_data.flags |= NFS_MOUNT_TCP;
 				break;
-			case Opt_broken_suid:
-				nfs_data.flags |= NFS_MOUNT_BROKEN_SUID;
-				break;
 			default : 
 				return 0;
 		}
--- d/include/linux/sunrpc/auth.h.orig	2004-05-10 04:32:37.000000000 +0200
+++ d/include/linux/sunrpc/auth.h	2004-09-15 21:53:07.000000000 +0200
@@ -99,7 +99,7 @@
 	void			(*crdestroy)(struct rpc_cred *);
 
 	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
-	u32 *			(*crmarshal)(struct rpc_task *, u32 *, int);
+	u32 *			(*crmarshal)(struct rpc_task *, u32 *);
 	int			(*crrefresh)(struct rpc_task *);
 	u32 *			(*crvalidate)(struct rpc_task *, u32 *);
 	int			(*crwrap_req)(struct rpc_task *, kxdrproc_t,
--- d/include/linux/sunrpc/sched.h.orig	2004-09-14 23:03:15.000000000 +0200
+++ d/include/linux/sunrpc/sched.h	2004-09-15 22:46:49.000000000 +0200
@@ -45,9 +45,8 @@
 	struct rpc_message	tk_msg;		/* RPC call info */
 	__u32 *			tk_buffer;	/* XDR buffer */
 	size_t			tk_bufsize;
-	__u8			tk_garb_retry,
-				tk_cred_retry,
-				tk_suid_retry;
+	__u8			tk_garb_retry;
+	__u8			tk_cred_retry;
 
 	unsigned long		tk_cookie;	/* Cookie for batching tasks */
 
@@ -105,9 +104,7 @@
  */
 #define RPC_TASK_ASYNC		0x0001		/* is an async task */
 #define RPC_TASK_SWAPPER	0x0002		/* is swapping in/out */
-#define RPC_TASK_SETUID		0x0004		/* is setuid process */
 #define RPC_TASK_CHILD		0x0008		/* is child of other task */
-#define RPC_CALL_REALUID	0x0010		/* try using real uid */
 #define RPC_CALL_MAJORSEEN	0x0020		/* major timeout seen */
 #define RPC_TASK_ROOTCREDS	0x0040		/* force root creds */
 #define RPC_TASK_DYNAMIC	0x0080		/* task was kmalloc'ed */
@@ -116,7 +113,6 @@
 #define RPC_TASK_NOINTR		0x0400		/* uninterruptible task */
 
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
-#define RPC_IS_SETUID(t)	((t)->tk_flags & RPC_TASK_SETUID)
 #define RPC_IS_CHILD(t)		((t)->tk_flags & RPC_TASK_CHILD)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
--- d/include/linux/sunrpc/clnt.h.orig	2004-05-10 04:32:39.000000000 +0200
+++ d/include/linux/sunrpc/clnt.h	2004-09-15 22:08:37.000000000 +0200
@@ -51,7 +51,6 @@
 				cl_intr     : 1,/* interruptible */
 				cl_chatty   : 1,/* be verbose */
 				cl_autobind : 1,/* use getport() */
-				cl_droppriv : 1,/* enable NFS suid hack */
 				cl_oneshot  : 1,/* dispose after use */
 				cl_dead     : 1;/* abandoned */
 
--- d/net/sunrpc/auth_gss/auth_gss.c.orig	2004-09-14 23:20:20.000000000 +0200
+++ d/net/sunrpc/auth_gss/auth_gss.c	2004-09-15 21:52:42.000000000 +0200
@@ -685,7 +685,7 @@
 * Maybe we should keep a cached credential for performance reasons.
 */
 static u32 *
-gss_marshal(struct rpc_task *task, u32 *p, int ruid)
+gss_marshal(struct rpc_task *task, u32 *p)
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
 	struct gss_cred	*gss_cred = container_of(cred, struct gss_cred,
--- d/net/sunrpc/auth_unix.c.orig	2004-09-14 23:20:20.000000000 +0200
+++ d/net/sunrpc/auth_unix.c	2004-09-15 21:54:27.000000000 +0200
@@ -142,7 +142,7 @@
  * Maybe we should keep a cached credential for performance reasons.
  */
 static u32 *
-unx_marshal(struct rpc_task *task, u32 *p, int ruid)
+unx_marshal(struct rpc_task *task, u32 *p)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct unx_cred	*cred = (struct unx_cred *) task->tk_msg.rpc_cred;
@@ -158,14 +158,8 @@
 	 */
 	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
 
-	/* Note: we don't use real uid if it involves raising privilege */
-	if (ruid && cred->uc_puid != 0 && cred->uc_pgid != 0) {
-		*p++ = htonl((u32) cred->uc_puid);
-		*p++ = htonl((u32) cred->uc_pgid);
-	} else {
-		*p++ = htonl((u32) cred->uc_uid);
-		*p++ = htonl((u32) cred->uc_gid);
-	}
+	*p++ = htonl((u32) cred->uc_uid);
+	*p++ = htonl((u32) cred->uc_gid);
 	hold = p++;
 	for (i = 0; i < RPC_MAXGROUPS && cred->uc_gids[i] != (gid_t) NOGROUP; i++)
 		*p++ = htonl((u32) cred->uc_gids[i]);
--- d/net/sunrpc/auth_null.c.orig	2004-05-10 04:33:22.000000000 +0200
+++ d/net/sunrpc/auth_null.c	2004-09-15 21:56:39.000000000 +0200
@@ -84,7 +84,7 @@
  * Marshal credential.
  */
 static u32 *
-nul_marshal(struct rpc_task *task, u32 *p, int ruid)
+nul_marshal(struct rpc_task *task, u32 *p)
 {
 	*p++ = htonl(RPC_AUTH_NULL);
 	*p++ = 0;
--- d/net/sunrpc/auth.c.orig	2004-09-14 23:20:20.000000000 +0200
+++ d/net/sunrpc/auth.c	2004-09-15 21:58:10.000000000 +0200
@@ -340,8 +340,7 @@
 
 	dprintk("RPC: %4d marshaling %s cred %p\n",
 		task->tk_pid, auth->au_ops->au_name, cred);
-	return cred->cr_ops->crmarshal(task, p,
-				task->tk_flags & RPC_CALL_REALUID);
+	return cred->cr_ops->crmarshal(task, p);
 }
 
 u32 *
--- d/net/sunrpc/clnt.c.orig	2004-09-14 23:03:19.000000000 +0200
+++ d/net/sunrpc/clnt.c	2004-09-15 22:07:32.000000000 +0200
@@ -871,21 +871,6 @@
 		goto out_retry;
 	}
 
-	/*
-	 * The following is an NFS-specific hack to cater for setuid
-	 * processes whose uid is mapped to nobody on the server.
-	 */
-	if (task->tk_client->cl_droppriv && 
-            (ntohl(*p) == NFSERR_ACCES || ntohl(*p) == NFSERR_PERM)) {
-		if (RPC_IS_SETUID(task) && task->tk_suid_retry) {
-			dprintk("RPC: %4d retry squashed uid\n", task->tk_pid);
-			task->tk_flags ^= RPC_CALL_REALUID;
-			task->tk_action = call_bind;
-			task->tk_suid_retry--;
-			goto out_retry;
-		}
-	}
-
 	task->tk_action = NULL;
 
 	if (decode)
--- d/net/sunrpc/sched.c.orig	2004-09-14 23:03:19.000000000 +0200
+++ d/net/sunrpc/sched.c	2004-09-15 22:44:41.000000000 +0200
@@ -863,13 +863,10 @@
 	task->tk_flags  = flags;
 	task->tk_exit   = callback;
 	init_waitqueue_head(&task->tk_wait);
-	if (current->uid != current->fsuid || current->gid != current->fsgid)
-		task->tk_flags |= RPC_TASK_SETUID;
 
 	/* Initialize retry counters */
 	task->tk_garb_retry = 2;
 	task->tk_cred_retry = 2;
-	task->tk_suid_retry = 1;
 
 	task->tk_priority = RPC_PRIORITY_NORMAL;
 	task->tk_cookie = (unsigned long)current;
-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
