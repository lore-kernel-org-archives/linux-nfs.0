From: Olaf Kirch <okir@suse.de>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Tue, 30 Sep 2003 14:50:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030930125005.GI11571@suse.de>
References: <Pine.LNX.4.44.0309290757580.21173-100000@guppy.limebrokerage.com> <shsr81z8q73.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="M9NhX3UHpAaciwkO"
Cc: Ion Badulescu <lists@news.cs.columbia.edu>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4JyI-0005VQ-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 05:51:18 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A4JyG-0002EX-Pm
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 05:51:17 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsr81z8q73.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Mon, Sep 29, 2003 at 10:22:40AM -0700, Trond Myklebust wrote:
> You'd have to be extremely unlucky to kill the process and hit the
> window for the Oops. I defy you to come up with an exploit for it.
> 
> That said, I agree that a full fix would be preferable. I'm working on
> other projects right now, that's why I'm being slow about this issue
> (plus the fact that it's not exactly easy to reproduce). I'll get onto
> it soon...

I've had no luck reproducing it either in a controlled environment.
However the bug is common enough to crash a few of our build machines
over a weekend...

I took your patch, Trond, and modified it a little to not crash if
the user ctrl-c's the unlink. Still not pretty - maybe it should
zap the cached attributes:

@@ -212,7 +222,15 @@
        data->count++;
        nfs_copy_dname(dentry, data);
        dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
-       if (data->task.tk_rpcwait == &nfs_delete_queue)
+       if (data->task.tk_rpcwait == &nfs_delete_queue) {
+               struct rpc_clnt *clnt = data->task.tk_client;
                rpc_wake_up_task(&data->task);
+               nfs_wait_event(clnt, data->waitq, data->completed == 1);
+               /* This is safe as we hold the BKL */
+               if (!data->completed) {
+                       dput(data->dir);
+                       data->dir = NULL;
+               }
+       }
        nfs_put_unlinkdata(data);
 }

Olaf
-- 
Olaf Kirch     |  Anyone who has had to work with X.509 has probably
okir@suse.de   |  experienced what can best be described as
---------------+  ISO water torture. -- Peter Gutmann

--M9NhX3UHpAaciwkO
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=nfs-autofs-umount-crash

diff -ur linux-2.4.21/fs/nfs/dir.c nfs/fs/nfs/dir.c
--- linux-2.4.21/fs/nfs/dir.c	2003-09-29 10:33:41.000000000 +0200
+++ nfs/fs/nfs/dir.c	2003-09-29 12:34:36.000000000 +0200
@@ -1144,7 +1144,7 @@
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct dentry *dentry = NULL, *rehash = NULL;
-	int error = -EBUSY;
+	int error;
 
 	/*
 	 * To prevent any new references to the target during the rename,
@@ -1170,6 +1170,12 @@
 	 */
 	if (!new_inode)
 		goto go_ahead;
+	/* If target is a hard link to the source, then noop */
+	error = 0;
+	if (NFS_FILEID(new_inode) == NFS_FILEID(old_inode))
+		goto out;
+
+	error = -EBUSY;
 	if (S_ISDIR(new_inode->i_mode))
 		goto out;
 	else if (atomic_read(&new_dentry->d_count) > 1) {
diff -ur linux-2.4.21/fs/nfs/unlink.c nfs/fs/nfs/unlink.c
--- linux-2.4.21/fs/nfs/unlink.c	2002-11-29 00:53:15.000000000 +0100
+++ nfs/fs/nfs/unlink.c	2003-09-29 13:38:49.000000000 +0200
@@ -12,6 +12,7 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
+#include <linux/wait.h>
 
 
 struct nfs_unlinkdata {
@@ -21,6 +22,9 @@
 	struct rpc_task	task;
 	struct rpc_cred	*cred;
 	unsigned int	count;
+
+	wait_queue_head_t waitq;
+	int completed;
 };
 
 static struct nfs_unlinkdata	*nfs_deletes;
@@ -54,6 +58,8 @@
 		nfs_detach_unlinkdata(data);
 		if (data->name.name != NULL)
 			kfree(data->name.name);
+		if (data->cred)
+			put_rpccred(data->cred);
 		kfree(data);
 	}
 }
@@ -133,6 +139,8 @@
 	put_rpccred(data->cred);
 	data->cred = NULL;
 	dput(dir);
+	data->completed = 1;
+	wake_up(&data->waitq);
 }
 
 /**
@@ -175,6 +183,8 @@
 	nfs_deletes = data;
 	data->count = 1;
 
+	init_waitqueue_head(&data->waitq);
+
 	task = &data->task;
 	rpc_init_task(task, clnt, nfs_async_unlink_done , RPC_TASK_ASYNC);
 	task->tk_calldata = data;
@@ -212,7 +222,15 @@
 	data->count++;
 	nfs_copy_dname(dentry, data);
 	dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
-	if (data->task.tk_rpcwait == &nfs_delete_queue)
+	if (data->task.tk_rpcwait == &nfs_delete_queue) {
+		struct rpc_clnt *clnt = data->task.tk_client;
 		rpc_wake_up_task(&data->task);
+		nfs_wait_event(clnt, data->waitq, data->completed == 1);
+		/* This is safe as we hold the BKL */
+		if (!data->completed) {
+			dput(data->dir);
+			data->dir = NULL;
+		}
+	}
 	nfs_put_unlinkdata(data);
 }

--M9NhX3UHpAaciwkO--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
