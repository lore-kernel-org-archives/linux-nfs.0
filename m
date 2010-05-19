From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 4/8] sunrpc: Pushdown the bkl from ioctl
Date: Wed, 19 May 2010 19:24:11 +0200
Message-ID: <1274289855-10001-5-git-send-regression-fweisbec@gmail.com>
References: <1274289855-10001-1-git-send-regression-fweisbec@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Nfs <linux-nfs@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Kacur <jkacur@redhat.com>, Arnd Bergmann <arnd@arndb.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274289855-10001-1-git-send-regression-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pushdown the bkl to rpc_pipe_ioctl.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Nfs <linux-nfs@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Kacur <jkacur@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 net/sunrpc/rpc_pipe.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 20e30c6..95ccbcf 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -27,6 +27,7 @@
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/sunrpc/cache.h>
+#include <linux/smp_lock.h>
 
 static struct vfsmount *rpc_mount __read_mostly;
 static int rpc_mount_count;
@@ -309,8 +310,7 @@ rpc_pipe_poll(struct file *filp, struct poll_table_struct *wait)
 }
 
 static int
-rpc_pipe_ioctl(struct inode *ino, struct file *filp,
-		unsigned int cmd, unsigned long arg)
+rpc_pipe_ioctl_unlocked(struct file *filp, unsigned int cmd, unsigned long arg)
 {
 	struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
 	int len;
@@ -331,13 +331,25 @@ rpc_pipe_ioctl(struct inode *ino, struct file *filp,
 	}
 }
 
+static long
+rpc_pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
+{
+	long ret;
+
+	lock_kernel();
+	ret = rpc_pipe_ioctl_unlocked(filp, cmd, arg);
+	unlock_kernel();
+
+	return ret;
+}
+
 static const struct file_operations rpc_pipe_fops = {
 	.owner		= THIS_MODULE,
 	.llseek		= no_llseek,
 	.read		= rpc_pipe_read,
 	.write		= rpc_pipe_write,
 	.poll		= rpc_pipe_poll,
-	.ioctl		= rpc_pipe_ioctl,
+	.unlocked_ioctl	= rpc_pipe_ioctl,
 	.open		= rpc_pipe_open,
 	.release	= rpc_pipe_release,
 };
-- 
1.6.2.3
