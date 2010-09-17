Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:64405 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809Ab0IQMiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 08:38:16 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Subject: sunrpc: remove the big kernel lock
Date: Fri, 17 Sep 2010 14:38:02 +0200
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, David Miller <davem@davemloft.net>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201009171438.02313.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The sunrpc cache_ioctl function does not need the big kernel lock
because it uses its own queue_lock already.

rpc_pipe_ioctl apparently should be using i_lock like the other
operations on the pipe file descriptor do.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
I missed this one because I considered the use of the BKL to
be part of nfs/nfsd, but in this is really an unrelated usage.
Please apply to an appropriate tree.

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 5b7b56f..9e4827c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -28,7 +28,6 @@
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
 #include <linux/pagemap.h>
-#include <linux/smp_lock.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -1426,15 +1425,10 @@ static unsigned int cache_poll_procfs(struct file *filp, poll_table *wait)
 static long cache_ioctl_procfs(struct file *filp,
 			       unsigned int cmd, unsigned long arg)
 {
-	long ret;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct cache_detail *cd = PDE(inode)->data;
 
-	lock_kernel();
-	ret = cache_ioctl(inode, filp, cmd, arg, cd);
-	unlock_kernel();
-
-	return ret;
+	return cache_ioctl(inode, filp, cmd, arg, cd);
 }
 
 static int cache_open_procfs(struct inode *inode, struct file *filp)
@@ -1634,13 +1628,8 @@ static long cache_ioctl_pipefs(struct file *filp,
 {
 	struct inode *inode = filp->f_dentry->d_inode;
 	struct cache_detail *cd = RPC_I(inode)->private;
-	long ret;
 
-	lock_kernel();
-	ret = cache_ioctl(inode, filp, cmd, arg, cd);
-	unlock_kernel();
-
-	return ret;
+	return cache_ioctl(inode, filp, cmd, arg, cd);
 }
 
 static int cache_open_pipefs(struct inode *inode, struct file *filp)
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 8c8eef2..28bcd52 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -27,7 +27,6 @@
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
-#include <linux/smp_lock.h>
 
 static struct vfsmount *rpc_mount __read_mostly;
 static int rpc_mount_count;
@@ -309,40 +308,33 @@ rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
 	return mask;
 }
 
-static int
-rpc_pipe_ioctl_unlocked(struct file *filp, unsigned int cmd, unsigned long arg)
+static long
+rpc_pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 {
-	struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct rpc_inode *rpci = RPC_I(inode);
 	int len;
 
 	switch (cmd) {
 	case FIONREAD:
-		if (rpci->ops == NULL)
+		spin_lock(&inode->i_lock);
+		if (rpci->ops == NULL) {
+			spin_unlock(&inode->i_lock);
 			return -EPIPE;
+		}
 		len = rpci->pipelen;
 		if (filp->private_data) {
 			struct rpc_pipe_msg *msg;
 			msg = (struct rpc_pipe_msg *)filp->private_data;
 			len += msg->len - msg->copied;
 		}
+		spin_unlock(&inode->i_lock);
 		return put_user(len, (int __user *)arg);
 	default:
 		return -EINVAL;
 	}
 }
 
-static long
-rpc_pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
-{
-	long ret;
-
-	lock_kernel();
-	ret = rpc_pipe_ioctl_unlocked(filp, cmd, arg);
-	unlock_kernel();
-
-	return ret;
-}
-
 static const struct file_operations rpc_pipe_fops = {
 	.owner		= THIS_MODULE,
 	.llseek		= no_llseek,
