Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36175 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbJELC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Oct 2015 07:02:57 -0400
Received: by qgx61 with SMTP id 61so145873463qgx.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2015 04:02:55 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v5 07/20] locks: create a new notifier chain for lease attempts
Date: Mon,  5 Oct 2015 07:02:29 -0400
Message-Id: <1444042962-6947-8-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the new file caching infrastructure in nfsd, we can end up holding
files open for an indefinite period of time, even when they are still
idle. This may prevent the kernel from handing out leases on the file,
which is something we don't want to block.

Fix this by running a SRCU notifier call chain whenever on any
lease attempt. nfsd can then purge the cache for that inode before
returning.

Since SRCU is only conditionally compiled in, we must only define the
new chain if it's enabled, and users of the chain must ensure that
SRCU is enabled.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/locks.c         | 37 +++++++++++++++++++++++++++++++++++++
 include/linux/fs.h |  1 +
 2 files changed, 38 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 2a54c800a223..a2d5794d713a 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -166,6 +166,7 @@ int lease_break_time = 45;
 DEFINE_STATIC_LGLOCK(file_lock_lglock);
 static DEFINE_PER_CPU(struct hlist_head, file_lock_list);
 
+
 /*
  * The blocked_hash is used to find POSIX lock loops for deadlock detection.
  * It is protected by blocked_lock_lock.
@@ -1780,6 +1781,40 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp,
 }
 EXPORT_SYMBOL(generic_setlease);
 
+#if IS_ENABLED(CONFIG_SRCU)
+/*
+ * Kernel subsystems can register to be notified on any attempt to set
+ * a new lease with the lease_notifier_chain. This is used by (e.g.) nfsd
+ * to close files that it may have cached when there is an attempt to set a
+ * conflicting lease.
+ */
+struct srcu_notifier_head lease_notifier_chain;
+EXPORT_SYMBOL_GPL(lease_notifier_chain);
+
+static inline void
+lease_notifier_chain_init(void)
+{
+	srcu_init_notifier_head(&lease_notifier_chain);
+}
+
+static inline void
+setlease_notifier(long arg, struct file_lock *lease)
+{
+	if (arg != F_UNLCK)
+		srcu_notifier_call_chain(&lease_notifier_chain, arg, lease);
+}
+#else /* !IS_ENABLED(CONFIG_SRCU) */
+static inline void
+lease_notifier_chain_init(void)
+{
+}
+
+static inline void
+setlease_notifier(long arg, struct file_lock *lease)
+{
+}
+#endif /* IS_ENABLED(CONFIG_SRCU) */
+
 /**
  * vfs_setlease        -       sets a lease on an open file
  * @filp:	file pointer
@@ -1800,6 +1835,7 @@ EXPORT_SYMBOL(generic_setlease);
 int
 vfs_setlease(struct file *filp, long arg, struct file_lock **lease, void **priv)
 {
+	setlease_notifier(arg, *lease);
 	if (filp->f_op->setlease)
 		return filp->f_op->setlease(filp, arg, lease, priv);
 	else
@@ -2696,6 +2732,7 @@ static int __init filelock_init(void)
 	for_each_possible_cpu(i)
 		INIT_HLIST_HEAD(per_cpu_ptr(&file_lock_list, i));
 
+	lease_notifier_chain_init();
 	return 0;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 72d8a844c692..c0df75909dd4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1042,6 +1042,7 @@ extern int fcntl_setlease(unsigned int fd, struct file *filp, long arg);
 extern int fcntl_getlease(struct file *filp);
 
 /* fs/locks.c */
+extern struct srcu_notifier_head	lease_notifier_chain;
 void locks_free_lock_context(struct file_lock_context *ctx);
 void locks_free_lock(struct file_lock *fl);
 extern void locks_init_lock(struct file_lock *);
-- 
2.4.3

