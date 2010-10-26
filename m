Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:57690 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631Ab0JZUzo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Oct 2010 16:55:44 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: nfsd changes for 2.6.37
Date: Tue, 26 Oct 2010 22:55:40 +0200
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20101026164549.GD19445@fieldses.org> <201010262218.36940.arnd@arndb.de> <4CC73BA6.1090407@netapp.com>
In-Reply-To: <4CC73BA6.1090407@netapp.com>
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201010262255.40481.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tuesday 26 October 2010 22:35:50 Bryan Schumaker wrote:
> Hi
> 
> I left the one call because I was unable to figure out what
> was being protected with the BKL in that section of the code.
> I figured I would leave it for the maintainers, since they
> know more about the code than I do.

My guess is that we need something like the patch below.

This moves the lock_flocks() call into the places where it
is needed and can be safely converted into a spinlock because
that code does not sleep.

Finally, we can build fs/locks.c, nfs and nfsd with CONFIG_BKL
disabled.

*not tested*

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 Kconfig         |    1 -
 lockd/svc.c     |   11 -----------
 lockd/svcsubs.c |    9 ++++++++-
 locks.c         |    5 +++--
 nfs/Kconfig     |    1 -
 nfsd/Kconfig    |    1 -
 6 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 65781de..3d18530 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -50,7 +50,6 @@ endif # BLOCK
 config FILE_LOCKING
 	bool "Enable POSIX file locking API" if EMBEDDED
 	default y
-	select BKL # while lockd still uses it.
 	help
 	  This option enables standard file locking support, required
           for filesystems like NFS and for the flock() system
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index b13aabc..abfff9d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -22,7 +22,6 @@
 #include <linux/in.h>
 #include <linux/uio.h>
 #include <linux/smp.h>
-#include <linux/smp_lock.h>
 #include <linux/mutex.h>
 #include <linux/kthread.h>
 #include <linux/freezer.h>
@@ -130,15 +129,6 @@ lockd(void *vrqstp)
 
 	dprintk("NFS locking service started (ver " LOCKD_VERSION ").\n");
 
-	/*
-	 * FIXME: it would be nice if lockd didn't spend its entire life
-	 * running under the BKL. At the very least, it would be good to
-	 * have someone clarify what it's intended to protect here. I've
-	 * seen some handwavy posts about posix locking needing to be
-	 * done under the BKL, but it's far from clear.
-	 */
-	lock_kernel();
-
 	if (!nlm_timeout)
 		nlm_timeout = LOCKD_DFLT_TIMEO;
 	nlmsvc_timeout = nlm_timeout * HZ;
@@ -195,7 +185,6 @@ lockd(void *vrqstp)
 	if (nlmsvc_ops)
 		nlmsvc_invalidate_all();
 	nlm_shutdown_hosts();
-	unlock_kernel();
 	return 0;
 }
 
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index d0ef94c..1ca0679 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -170,6 +170,7 @@ nlm_traverse_locks(struct nlm_host *host, struct nlm_file *file,
 
 again:
 	file->f_locks = 0;
+	lock_flocks(); /* protects i_flock list */
 	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
 		if (fl->fl_lmops != &nlmsvc_lock_operations)
 			continue;
@@ -181,6 +182,7 @@ again:
 		if (match(lockhost, host)) {
 			struct file_lock lock = *fl;
 
+			unlock_flocks();
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
@@ -192,6 +194,7 @@ again:
 			goto again;
 		}
 	}
+	unlock_flocks();
 
 	return 0;
 }
@@ -226,10 +229,14 @@ nlm_file_inuse(struct nlm_file *file)
 	if (file->f_count || !list_empty(&file->f_blocks) || file->f_shares)
 		return 1;
 
+	lock_flocks();
 	for (fl = inode->i_flock; fl; fl = fl->fl_next) {
-		if (fl->fl_lmops == &nlmsvc_lock_operations)
+		if (fl->fl_lmops == &nlmsvc_lock_operations) {
+			unlock_flocks();
 			return 1;
+		}
 	}
+	unlock_flocks();
 	file->f_locks = 0;
 	return 0;
 }
diff --git a/fs/locks.c b/fs/locks.c
index 8b2b6ad..a417901 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -142,6 +142,7 @@ int lease_break_time = 45;
 
 static LIST_HEAD(file_lock_list);
 static LIST_HEAD(blocked_list);
+static DEFINE_SPINLOCK(file_lock_lock);
 
 /*
  * Protects the two list heads above, plus the inode->i_flock list
@@ -149,13 +150,13 @@ static LIST_HEAD(blocked_list);
  */
 void lock_flocks(void)
 {
-	lock_kernel();
+	spin_lock(&file_lock_lock);
 }
 EXPORT_SYMBOL_GPL(lock_flocks);
 
 void unlock_flocks(void)
 {
-	unlock_kernel();
+	spin_unlock(&file_lock_lock);
 }
 EXPORT_SYMBOL_GPL(unlock_flocks);
 
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index fd66765..ba30665 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -1,7 +1,6 @@
 config NFS_FS
 	tristate "NFS client support"
 	depends on INET && FILE_LOCKING
-	depends on BKL # fix as soon as lockd is done
 	select LOCKD
 	select SUNRPC
 	select NFS_ACL_SUPPORT if NFS_V3_ACL
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 31a78fc..18b3e89 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -2,7 +2,6 @@ config NFSD
 	tristate "NFS server support"
 	depends on INET
 	depends on FILE_LOCKING
-	depends on BKL # fix as soon as lockd is done
 	select LOCKD
 	select SUNRPC
 	select EXPORTFS
