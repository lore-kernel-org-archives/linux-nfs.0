From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] -o intr  mount option prevents core dumps on 2.4
 kernel
Date: Wed, 12 Jan 2005 13:18:11 -0500
Message-ID: <41E569E3.20206@RedHat.com>
References: <41DD8403.7030601@RedHat.com>	 <1105118040.10979.70.camel@lade.trondhjem.org>	 <41E42AD7.3030303@RedHat.com> <1105474246.11430.1.camel@lade.trondhjem.org>	 <41E43DE1.5080703@RedHat.com> <1105480745.11430.56.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070407050203090706010806"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Con4U-0001WH-Io
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 10:18:18 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Con4T-0004ap-N6
	for nfs@lists.sourceforge.net; Wed, 12 Jan 2005 10:18:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105480745.11430.56.camel@lade.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------070407050203090706010806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Trond Myklebust wrote:

>Yes, but I'm not sure that it makes sense to mask off SIGKILL as that
>makes core dumping completely uninterruptible. People do expect "kill
>-9" to always work when the "intr" flag is set.
>  
>
True... and it will continue to work...

>You should, however, mask off all other signals, including SIGINT and
>SIGQUIT. The latter two (+ sigkill) are the only ones that
>rpc_clnt_sigmask() does not currently mask out when "intr" is set.
>  
>
Good point... that attached patch does just that....

steved



--------------070407050203090706010806
Content-Type: text/x-patch;
 name="linux-2.4.28-nfs-dropcore2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.28-nfs-dropcore2.patch"

--- linux-2.4.28/fs/nfs/pagelist.c.orig	2005-01-12 12:37:13.100184000 -0500
+++ linux-2.4.28/fs/nfs/pagelist.c	2005-01-12 12:40:43.770864000 -0500
@@ -94,8 +94,13 @@ nfs_create_request(struct rpc_cred *cred
 		 */
 		if (nfs_try_to_free_pages(server))
 			continue;
-		if (signalled() && (server->flags & NFS_MOUNT_INTR))
+
+		if (signalled() && (server->flags & NFS_MOUNT_INTR)) {
+			if (task_core_dumping())
+				printk(KERN_WARNING \
+					"NFS: Core Dump Aborted due to lack of resources\n");
 			return ERR_PTR(-ERESTARTSYS);
+		}
 		yield();
 	}
 
--- linux-2.4.28/fs/nfs/nfs3proc.c.orig	2005-01-12 12:37:13.110184000 -0500
+++ linux-2.4.28/fs/nfs/nfs3proc.c	2005-01-12 12:40:43.786864000 -0500
@@ -31,6 +31,9 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, 
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
+		if (signalled() && task_core_dumping())
+			printk(KERN_WARNING \
+				"NFS: Core Dump Aborted due to lack of resources\n");
 	} while (!signalled());
 	rpc_clnt_sigunmask(clnt, &oldset);
 	return res;
--- linux-2.4.28/fs/exec.c.orig	2005-01-12 12:37:13.120184000 -0500
+++ linux-2.4.28/fs/exec.c	2005-01-12 12:40:43.798864000 -0500
@@ -1125,6 +1125,7 @@ int do_coredump(long signr, struct pt_re
 	if (current->rlim[RLIMIT_CORE].rlim_cur < binfmt->min_coredump)
 		goto fail;
 
+	current->flags |= PF_DUMPCORE;
  	format_corename(corename, core_pattern, signr);
 	file = filp_open(corename, O_CREAT | 2 | O_NOFOLLOW, 0600);
 	if (IS_ERR(file))
--- linux-2.4.28/include/linux/sunrpc/clnt.h.orig	2005-01-12 12:37:13.129184000 -0500
+++ linux-2.4.28/include/linux/sunrpc/clnt.h	2005-01-12 12:40:43.804865000 -0500
@@ -108,6 +108,8 @@ struct rpc_procinfo {
 
 #ifdef __KERNEL__
 
+#define task_core_dumping() (current->flags & PF_DUMPCORE)
+
 struct rpc_clnt *rpc_create_client(struct rpc_xprt *xprt, char *servname,
 				struct rpc_program *info,
 				u32 version, int authflavor);
--- linux-2.4.28/include/linux/nfs_fs.h.orig	2005-01-12 12:37:13.137184000 -0500
+++ linux-2.4.28/include/linux/nfs_fs.h	2005-01-12 12:40:43.823864000 -0500
@@ -345,7 +345,7 @@ extern void * nfs_root_data(void);
 #define nfs_wait_event(clnt, wq, condition)				\
 ({									\
 	int __retval = 0;						\
-	if (clnt->cl_intr) {						\
+	if (clnt->cl_intr && !task_core_dumping()) { \
 		sigset_t oldmask;					\
 		rpc_clnt_sigmask(clnt, &oldmask);			\
 		__retval = wait_event_interruptible(wq, condition);	\
--- linux-2.4.28/net/sunrpc/sched.c.orig	2005-01-12 12:37:13.145184000 -0500
+++ linux-2.4.28/net/sunrpc/sched.c	2005-01-12 12:40:43.834864000 -0500
@@ -498,7 +498,7 @@ __rpc_atrun(struct rpc_task *task)
 static int
 __rpc_execute(struct rpc_task *task)
 {
-	int		status = 0;
+	int		status = 0, core_retry = 0;
 
 	dprintk("RPC: %4d rpc_execute flgs %x\n",
 				task->tk_pid, task->tk_flags);
@@ -572,9 +572,20 @@ __rpc_execute(struct rpc_task *task)
 			 * -ERESTARTSYS. In order to catch any callbacks that
 			 * clean up after sleeping on some queue, we don't
 			 * break the loop here, but go around once more.
-			 */
+			 */	
 			if (task->tk_client->cl_intr && signalled()) {
 				dprintk("RPC: %4d got signal\n", task->tk_pid);
+				/*
+				 * If we are dropping a core and 'intr' is set,
+				 * we want to make an attempted at writting
+				 * out the core, but not get hung up in it.
+				 */
+				if (task_core_dumping()) {
+					dprintk("RPC: %4d dropping core retries %d\n", 
+						task->tk_pid, core_retry);
+					if (++core_retry < 3)
+						continue;
+				}
 				task->tk_flags |= RPC_TASK_KILLED;
 				rpc_exit(task, -ERESTARTSYS);
 				rpc_wake_up_task(task);
--- linux-2.4.28/net/sunrpc/clnt.c.orig	2003-11-28 13:26:21.000000000 -0500
+++ linux-2.4.28/net/sunrpc/clnt.c	2005-01-12 12:41:25.647200000 -0500
@@ -209,7 +209,7 @@ void rpc_clnt_sigmask(struct rpc_clnt *c
 	unsigned long	irqflags;
 	
 	/* Turn off various signals */
-	if (clnt->cl_intr) {
+	if (clnt->cl_intr && !task_core_dumping()) {
 		struct k_sigaction *action = current->sig->action;
 		if (action[SIGINT-1].sa.sa_handler == SIG_DFL)
 			sigallow |= sigmask(SIGINT);

--------------070407050203090706010806--


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
