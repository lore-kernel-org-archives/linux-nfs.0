From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 5/8] sunrpc: Pushdown the bkl from sunrpc cache ioctl
Date: Wed, 19 May 2010 19:24:12 +0200
Message-ID: <1274289855-10001-6-git-send-regression-fweisbec@gmail.com>
References: <1274289855-10001-1-git-send-regression-fweisbec@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Nfs <linux-nfs@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Kacur <jkacur@redhat.com>, Arnd Bergmann <arnd@arndb.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:53492 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463Ab0ESRYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 May 2010 13:24:21 -0400
In-Reply-To: <1274289855-10001-1-git-send-regression-fweisbec@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pushdown the bkl to cache_ioctl_pipefs.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Nfs <linux-nfs@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Kacur <jkacur@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 net/sunrpc/cache.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 39bddba..91b1ade 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -33,6 +33,7 @@
 #include <linux/sunrpc/cache.h>
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
+#include <linux/smp_lock.h>
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
@@ -1525,12 +1526,18 @@ static unsigned int cache_poll_pipefs(struct file *filp, poll_table *wait)
 	return cache_poll(filp, wait, cd);
 }
 
-static int cache_ioctl_pipefs(struct inode *inode, struct file *filp,
+static long cache_ioctl_pipefs(struct file *filp,
 			      unsigned int cmd, unsigned long arg)
 {
+	struct inode *inode = filp->f_dentry->d_inode;
 	struct cache_detail *cd = RPC_I(inode)->private;
+	long ret;
 
-	return cache_ioctl(inode, filp, cmd, arg, cd);
+	lock_kernel();
+	ret = cache_ioctl(inode, filp, cmd, arg, cd);
+	unlock_kernel();
+
+	return ret;
 }
 
 static int cache_open_pipefs(struct inode *inode, struct file *filp)
@@ -1553,7 +1560,7 @@ const struct file_operations cache_file_operations_pipefs = {
 	.read		= cache_read_pipefs,
 	.write		= cache_write_pipefs,
 	.poll		= cache_poll_pipefs,
-	.ioctl		= cache_ioctl_pipefs, /* for FIONREAD */
+	.unlocked_ioctl	= cache_ioctl_pipefs, /* for FIONREAD */
 	.open		= cache_open_pipefs,
 	.release	= cache_release_pipefs,
 };
-- 
1.6.2.3

