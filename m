From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] VFS: Busy inodes after unmount on 2 way SMP
Date: Thu, 25 Sep 2003 17:24:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16243.34641.819894.763746@charged.uio.no>
References: <shsd6dyabju.fsf@charged.uio.no>
	<Pine.LNX.4.44.0309251614290.22478-100000@fubar.phlinux.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    Olaf Hering <olh@suse.de>,
    "H. Peter Anvin" <hpa@zytor.com>,
    Arun Sharma <arun.sharma@intel.com>,
    <autofs@linux.kernel.org>,
    <nfs@lists.sourceforge.net>,
    Ian Kent <raven@themaw.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2gQa-00051L-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 17:25:44 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2gQZ-0001bV-Gx
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 17:25:43 -0700
To: Matt C <wago@phlinux.com>
In-Reply-To: <Pine.LNX.4.44.0309251614290.22478-100000@fubar.phlinux.com>
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

>>>>> " " == Matt C <Matt> writes:

     > Hi All- We've been having the 'VFS: Busy inodes after unmount'
     > problems like crazy on our desktop and server linux boxes
     > running autofs under 2.4.21 (vanilla). We're using the
     > autofs-3.1.7 userspace tools, but with the autofs4 kernel
     > module.

     > I applied the patch that was attached earlier in this thread to
     > our kernel and have been running it for the past few days on my
     > desktop. These errors have completely disappeared, and autofs
     > is behaving as expected so far.

     > So, while it might be the wrong thing to do, it does fix our
     > problems.

That changes nothing. It is still not a "fix" that I want to see go
into the main kernel.

The problem here is that sillyrename needs to hold onto the parent
directory's inode until it is done, and yet it cannot know which
vfsmount struct to hold onto because that information is not passed
down by the VFS.

I would rather then have something like the appended patch go in to
which force the last process to close the file to actually wait on
completion (unless someone signals it with a 'kill -9' - in which case
they are knowingly breaking things).

Cheers,
  Trond

diff -u --recursive --new-file linux-2.4.22-03-soft2/fs/nfs/dir.c linux-2.4.22-04-fix_unlink/fs/nfs/dir.c
--- linux-2.4.22-03-soft2/fs/nfs/dir.c	2002-10-15 06:59:27.000000000 +0200
+++ linux-2.4.22-04-fix_unlink/fs/nfs/dir.c	2003-07-03 12:29:28.000000000 +0200
@@ -994,7 +994,7 @@
 	struct inode *old_inode = old_dentry->d_inode;
 	struct inode *new_inode = new_dentry->d_inode;
 	struct dentry *dentry = NULL, *rehash = NULL;
-	int error = -EBUSY;
+	int error;
 
 	/*
 	 * To prevent any new references to the target during the rename,
@@ -1020,6 +1020,12 @@
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
diff -u --recursive --new-file linux-2.4.22-03-soft2/fs/nfs/unlink.c linux-2.4.22-04-fix_unlink/fs/nfs/unlink.c
--- linux-2.4.22-03-soft2/fs/nfs/unlink.c	2002-08-11 13:34:02.000000000 +0200
+++ linux-2.4.22-04-fix_unlink/fs/nfs/unlink.c	2003-07-03 12:29:28.000000000 +0200
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
@@ -133,6 +137,8 @@
 	put_rpccred(data->cred);
 	data->cred = NULL;
 	dput(dir);
+	data->completed = 1;
+	wake_up(&data->waitq);
 }
 
 /**
@@ -175,6 +181,8 @@
 	nfs_deletes = data;
 	data->count = 1;
 
+	init_waitqueue_head(&data->waitq);
+
 	task = &data->task;
 	rpc_init_task(task, clnt, nfs_async_unlink_done , RPC_TASK_ASYNC);
 	task->tk_calldata = data;
@@ -212,7 +220,10 @@
 	data->count++;
 	nfs_copy_dname(dentry, data);
 	dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
-	if (data->task.tk_rpcwait == &nfs_delete_queue)
+	if (data->task.tk_rpcwait == &nfs_delete_queue) {
+		struct rpc_clnt *clnt = data->task.tk_client;
 		rpc_wake_up_task(&data->task);
+		nfs_wait_event(clnt, data->waitq, data->completed == 1);
+	}
 	nfs_put_unlinkdata(data);
 }


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
