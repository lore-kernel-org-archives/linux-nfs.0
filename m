From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] -o intr  mount option prevents core dumps on 2.4 kernel
Date: Thu, 06 Jan 2005 13:31:31 -0500
Message-ID: <41DD8403.7030601@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060607020405060101060107"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CmcQ7-0007JY-Fy
	for nfs@lists.sourceforge.net; Thu, 06 Jan 2005 10:31:39 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CmcQ6-0001jj-N4
	for nfs@lists.sourceforge.net; Thu, 06 Jan 2005 10:31:39 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j06IVWIb017975
	for <nfs@lists.sourceforge.net>; Thu, 6 Jan 2005 13:31:32 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j06IVWr07484
	for <nfs@lists.sourceforge.net>; Thu, 6 Jan 2005 13:31:32 -0500
Received: from [172.16.80.110] (IDENT:U2FsdGVkX1+2G5MWlJoTb1+Sz+MOFYjVG+oebr7aJHk@dickson.boston.redhat.com [172.16.80.110])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j06IVVa04770
	for <nfs@lists.sourceforge.net>; Thu, 6 Jan 2005 13:31:31 -0500
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

This is a multi-part message in MIME format.
--------------060607020405060101060107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here is a 2.4.28 patch that allows core dumps to be written on
fileystems mounted with the 'intr' option.

By setting the PF_DUMPCORE bit in the current->flags (via
do_coredump()), I was able to signal the RPC and NFS code that
the current task is trying to dump a core. So the trick was to have
the rpc code (temporarily) ignore the fact  the task got signalled()
and let the write/commit path complete....

I do this by checking the PF_DUMPCORE bit in both  __rpc_execute()
and  nfs_wait_event(). One side effect is the dropping core process
becomes uninterruptable.... I combat this by only allowing the process
three retries before giving up...

Finally there are two placing in the NFS code where I don't ignore
the signal and do fail the writing of the core. One, is in 
nfs_create_request()
when there are no available pages and in nfs3_rpc_wrapper() when
the server returns EJUKEBOX. But I did place printks so it will be clear
as to why it failed....

Comments... Suggestions... Crimes against humanity that I'm committing???

steved.

--------------060607020405060101060107
Content-Type: text/x-patch;
 name="linux-2.4.28-nfs-dropcore.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.28-nfs-dropcore.patch"

--- linux-2.4.28/fs/nfs/pagelist.c.orig	2004-04-14 09:05:40.000000000 -0400
+++ linux-2.4.28/fs/nfs/pagelist.c	2005-01-06 12:27:21.053600000 -0500
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
 
--- linux-2.4.28/fs/nfs/nfs3proc.c.orig	2003-11-28 13:26:21.000000000 -0500
+++ linux-2.4.28/fs/nfs/nfs3proc.c	2005-01-06 12:27:21.063600000 -0500
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
--- linux-2.4.28/fs/exec.c.orig	2004-02-18 08:36:31.000000000 -0500
+++ linux-2.4.28/fs/exec.c	2005-01-06 12:27:21.082600000 -0500
@@ -1125,6 +1125,7 @@ int do_coredump(long signr, struct pt_re
 	if (current->rlim[RLIMIT_CORE].rlim_cur < binfmt->min_coredump)
 		goto fail;
 
+	current->flags |= PF_DUMPCORE;
  	format_corename(corename, core_pattern, signr);
 	file = filp_open(corename, O_CREAT | 2 | O_NOFOLLOW, 0600);
 	if (IS_ERR(file))
--- linux-2.4.28/include/linux/sunrpc/clnt.h.orig	2002-11-28 18:53:15.000000000 -0500
+++ linux-2.4.28/include/linux/sunrpc/clnt.h	2005-01-06 12:35:12.701368000 -0500
@@ -108,6 +108,8 @@ struct rpc_procinfo {
 
 #ifdef __KERNEL__
 
+#define task_core_dumping() (current->flags & PF_DUMPCORE)
+
 struct rpc_clnt *rpc_create_client(struct rpc_xprt *xprt, char *servname,
 				struct rpc_program *info,
 				u32 version, int authflavor);
--- linux-2.4.28/include/linux/nfs_fs.h.orig	2004-04-14 09:05:40.000000000 -0400
+++ linux-2.4.28/include/linux/nfs_fs.h	2005-01-06 12:35:12.718369000 -0500
@@ -345,7 +345,7 @@ extern void * nfs_root_data(void);
 #define nfs_wait_event(clnt, wq, condition)				\
 ({									\
 	int __retval = 0;						\
-	if (clnt->cl_intr) {						\
+	if (clnt->cl_intr && !task_core_dumping()) { \
 		sigset_t oldmask;					\
 		rpc_clnt_sigmask(clnt, &oldmask);			\
 		__retval = wait_event_interruptible(wq, condition);	\
--- linux-2.4.28/net/sunrpc/sched.c.orig	2003-06-13 10:51:39.000000000 -0400
+++ linux-2.4.28/net/sunrpc/sched.c	2005-01-06 12:27:21.137600000 -0500
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

--------------060607020405060101060107--


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
