From: Mike Waychison <michael.waychison@sun.com>
Subject: [PATCH 2/2] Allow FORCEINTR override for signal masking
Date: Thu, 9 Dec 2004 16:23:37 -0500
Message-ID: <1102627417985@sun.com>
References: <11026273562@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcVlO-0008Ko-S5
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:23:50 -0800
Received: from ip22-176.tor.istop.com
	([66.11.176.22] helo=crlf.tor.istop.com ident=postfix)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcVlO-0005Ao-7F
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 13:23:50 -0800
Received: from localhost (belle.christiehouse.net [127.0.0.1])
	by crlf.tor.istop.com (Postfix) with ESMTP id 3C9FFD379
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 16:34:13 -0500 (EST)
Received: from crlf.tor.istop.com ([127.0.0.1])
	by localhost (belle [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 23560-03 for <nfs@lists.sourceforge.net>;
	Thu, 9 Dec 2004 16:34:08 -0500 (EST)
Received: from lapdance (unknown [192.168.4.103])
	by crlf.tor.istop.com (Postfix) with SMTP id 1D9D8D36A
	for <nfs@lists.sourceforge.net>; Thu,  9 Dec 2004 16:34:08 -0500 (EST)
In-Reply-To: <11026273562@sun.com>
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Add a new flags parameter to rpc_clnt_sigmask. Flags are meant to be task flags.
This allows us to specify RPC_TASK_FORCEINTR when masking signals, which keeps
rpc_clnt_sigmask from blocking SIGINT and SIGQUIT as if clnt->cl_intr had been
set.

Signed-off-by: Mike Waychison <michael.waychison@sun.com>
Index: linux-2.6.9-quilt/fs/nfs/file.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/file.c	2004-10-18 14:54:38.000000000 -0700
+++ linux-2.6.9-quilt/fs/nfs/file.c	2004-12-03 11:02:27.000000000 -0800
@@ -309,7 +309,7 @@ static int do_unlk(struct file *filp, in
 	sigset_t oldset;
 	int status;
 
-	rpc_clnt_sigmask(NFS_CLIENT(inode), &oldset);
+	rpc_clnt_sigmask(NFS_CLIENT(inode), &oldset, 0);
 	/*
 	 * Flush all pending writes before doing anything
 	 * with locks..
Index: linux-2.6.9-quilt/fs/nfs/nfs3proc.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/nfs3proc.c	2004-11-18 18:00:29.000000000 -0800
+++ linux-2.6.9-quilt/fs/nfs/nfs3proc.c	2004-12-03 11:06:35.000000000 -0800
@@ -28,7 +28,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, 
 {
 	sigset_t oldset;
 	int res;
-	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_clnt_sigmask(clnt, &oldset, flags);
 	do {
 		res = rpc_call_sync(clnt, msg, flags);
 		if (res != -EJUKEBOX)
Index: linux-2.6.9-quilt/fs/nfs/nfs4proc.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/nfs4proc.c	2004-12-03 11:07:16.000000000 -0800
+++ linux-2.6.9-quilt/fs/nfs/nfs4proc.c	2004-12-03 11:07:57.000000000 -0800
@@ -2086,7 +2086,7 @@ int nfs4_wait_clnt_recover(struct rpc_cl
 
 	might_sleep();
 
-	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_clnt_sigmask(clnt, &oldset, 0);
 	interruptible = TASK_UNINTERRUPTIBLE;
 	if (clnt->cl_intr)
 		interruptible = TASK_INTERRUPTIBLE;
@@ -2112,7 +2112,7 @@ static int nfs4_delay(struct rpc_clnt *c
 		*timeout = NFS4_POLL_RETRY_MIN;
 	if (*timeout > NFS4_POLL_RETRY_MAX)
 		*timeout = NFS4_POLL_RETRY_MAX;
-	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_clnt_sigmask(clnt, &oldset, 0);
 	if (clnt->cl_intr) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(*timeout);
Index: linux-2.6.9-quilt/fs/nfs/read.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/read.c	2004-11-11 13:01:03.000000000 -0800
+++ linux-2.6.9-quilt/fs/nfs/read.c	2004-12-03 11:05:07.000000000 -0800
@@ -268,7 +268,7 @@ static void nfs_execute_read(struct nfs_
 	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
 	sigset_t oldset;
 
-	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_clnt_sigmask(clnt, &oldset, 0);
 	lock_kernel();
 	rpc_execute(&data->task);
 	unlock_kernel();
Index: linux-2.6.9-quilt/fs/nfs/write.c
===================================================================
--- linux-2.6.9-quilt.orig/fs/nfs/write.c	2004-11-22 12:48:22.000000000 -0800
+++ linux-2.6.9-quilt/fs/nfs/write.c	2004-12-03 11:06:03.000000000 -0800
@@ -603,7 +603,7 @@ static int nfs_wait_on_write_congestion(
 		struct rpc_clnt *clnt = NFS_CLIENT(mapping->host);
 		sigset_t oldset;
 
-		rpc_clnt_sigmask(clnt, &oldset);
+		rpc_clnt_sigmask(clnt, &oldset, RPC_TASK_FORCEINTR);
 		prepare_to_wait(&nfs_write_congestion, &wait, TASK_INTERRUPTIBLE);
 		if (bdi_write_congested(bdi)) {
 			if (signalled())
@@ -903,7 +903,7 @@ static void nfs_execute_write(struct nfs
 	struct rpc_clnt *clnt = NFS_CLIENT(data->inode);
 	sigset_t oldset;
 
-	rpc_clnt_sigmask(clnt, &oldset);
+	rpc_clnt_sigmask(clnt, &oldset, 0);
 	lock_kernel();
 	rpc_execute(&data->task);
 	unlock_kernel();
Index: linux-2.6.9-quilt/include/linux/nfs_fs.h
===================================================================
--- linux-2.6.9-quilt.orig/include/linux/nfs_fs.h	2004-11-11 13:01:03.000000000 -0800
+++ linux-2.6.9-quilt/include/linux/nfs_fs.h	2004-12-03 11:04:40.000000000 -0800
@@ -476,7 +476,7 @@ extern void * nfs_root_data(void);
 	int __retval = 0;						\
 	if (clnt->cl_intr) {						\
 		sigset_t oldmask;					\
-		rpc_clnt_sigmask(clnt, &oldmask);			\
+		rpc_clnt_sigmask(clnt, &oldmask, 0);			\
 		__retval = wait_event_interruptible(wq, condition);	\
 		rpc_clnt_sigunmask(clnt, &oldmask);			\
 	} else								\
Index: linux-2.6.9-quilt/include/linux/sunrpc/clnt.h
===================================================================
--- linux-2.6.9-quilt.orig/include/linux/sunrpc/clnt.h	2004-12-03 10:46:18.000000000 -0800
+++ linux-2.6.9-quilt/include/linux/sunrpc/clnt.h	2004-12-03 10:47:01.000000000 -0800
@@ -126,7 +126,7 @@ int		rpc_call_async(struct rpc_clnt *cln
 int		rpc_call_sync(struct rpc_clnt *clnt, struct rpc_message *msg,
 			      int flags);
 void		rpc_restart_call(struct rpc_task *);
-void		rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset);
+void		rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset, int flags);
 void		rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset);
 void		rpc_setbufsize(struct rpc_clnt *, unsigned int, unsigned int);
 
Index: linux-2.6.9-quilt/net/sunrpc/clnt.c
===================================================================
--- linux-2.6.9-quilt.orig/net/sunrpc/clnt.c	2004-11-22 12:36:48.000000000 -0800
+++ linux-2.6.9-quilt/net/sunrpc/clnt.c	2004-12-03 11:15:54.000000000 -0800
@@ -308,13 +308,13 @@ rpc_default_callback(struct rpc_task *ta
  *	sleeps on RPC calls
  */
  
-void rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset)
+void rpc_clnt_sigmask(struct rpc_clnt *clnt, sigset_t *oldset, int flags)
 {
 	unsigned long	sigallow = sigmask(SIGKILL);
 	unsigned long	irqflags;
 	
 	/* Turn off various signals */
-	if (clnt->cl_intr) {
+	if (clnt->cl_intr || flags & RPC_TASK_FORCEINTR) {
 		struct k_sigaction *action = current->sighand->action;
 		if (action[SIGINT-1].sa.sa_handler == SIG_DFL)
 			sigallow |= sigmask(SIGINT);
@@ -353,7 +353,7 @@ int rpc_call_sync(struct rpc_clnt *clnt,
 
 	BUG_ON(flags & RPC_TASK_ASYNC);
 
-	rpc_clnt_sigmask(clnt, &oldset);		
+	rpc_clnt_sigmask(clnt, &oldset, flags);		
 
 	status = -ENOMEM;
 	task = rpc_new_task(clnt, NULL, flags);
@@ -393,7 +393,7 @@ rpc_call_async(struct rpc_clnt *clnt, st
 
 	flags |= RPC_TASK_ASYNC;
 
-	rpc_clnt_sigmask(clnt, &oldset);		
+	rpc_clnt_sigmask(clnt, &oldset, flags);		
 
 	/* Create/initialize a new RPC task */
 	if (!callback)



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
