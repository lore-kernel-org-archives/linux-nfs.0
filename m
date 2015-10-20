Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34105 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753009AbbJTReC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:02 -0400
Received: by qgem9 with SMTP id m9so21699029qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:01 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 04/19] fs: rename "delayed_fput" infrastructure to "fput_global"
Date: Tue, 20 Oct 2015 13:33:37 -0400
Message-Id: <1445362432-18869-5-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

delayed_fput work is only delayed until the workqueue job runs. It's
even possible that it will run immediately after you call it if the
workqueue job happens to be executing at the time. What it does
guarantee is that the final __fput will run in a different task than the
the one that queued it. It's this property that we want to use in the
NFSD code to close files in advance of a setlease attempt by userland.

Change the name of the "delayed_fput" infrastructure to "fput_global"
as that better describes what this code does.

Cc: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c      | 38 ++++++++++++++++++++------------------
 include/linux/file.h |  2 +-
 init/main.c          |  2 +-
 3 files changed, 22 insertions(+), 20 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 8cfeaee6323f..0bf8ddc680ab 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -227,10 +227,10 @@ static void __fput(struct file *file)
 	mntput(mnt);
 }
 
-static LLIST_HEAD(delayed_fput_list);
-static void delayed_fput(struct work_struct *unused)
+static LLIST_HEAD(global_fput_list);
+static void global_fput(struct work_struct *unused)
 {
-	struct llist_node *node = llist_del_all(&delayed_fput_list);
+	struct llist_node *node = llist_del_all(&global_fput_list);
 	struct llist_node *next;
 
 	for (; node; node = next) {
@@ -244,21 +244,23 @@ static void ____fput(struct callback_head *work)
 	__fput(container_of(work, struct file, f_u.fu_rcuhead));
 }
 
-static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
+static DECLARE_DELAYED_WORK(global_fput_work, global_fput);
 
-/*
- * If kernel thread really needs to have the final fput() it has done
- * to complete, call this.  The only user right now is the boot - we
- * *do* need to make sure our writes to binaries on initramfs has
- * not left us with opened struct file waiting for __fput() - execve()
- * won't work without that.  Please, don't add more callers without
- * very good reasons; in particular, never call that with locks
- * held and never call that from a thread that might need to do
- * some work on any kind of umount.
+/**
+ * fput_global_flush - ensure that all global_fput work is complete
+ *
+ * If a kernel thread really needs to have the final fput() it has done to
+ * complete, call this. One of the main users is the boot - we *do* need to
+ * make sure our writes to binaries on initramfs has not left us with opened
+ * struct file waiting for __fput() - execve() won't work without that.
+ *
+ * Please, don't add more callers without very good reasons; in particular,
+ * never call that with locks held and never from a thread that might need to
+ * do some work on any kind of umount.
  */
-void flush_delayed_fput(void)
+void fput_global_flush(void)
 {
-	flush_delayed_work(&delayed_fput_work);
+	flush_delayed_work(&global_fput_work);
 }
 
 /**
@@ -296,15 +298,15 @@ void fput(struct file *file)
 			 */
 		}
 
-		if (llist_add(&file->f_u.fu_llist, &delayed_fput_list))
-			schedule_delayed_work(&delayed_fput_work, 1);
+		if (llist_add(&file->f_u.fu_llist, &global_fput_list))
+			schedule_delayed_work(&global_fput_work, 1);
 	}
 }
 EXPORT_SYMBOL(fput);
 
 /*
  * synchronous analog of fput(); for kernel threads that might be needed
- * in some umount() (and thus can't use flush_delayed_fput() without
+ * in some umount() (and thus can't use fput_global_flush() without
  * risking deadlocks), need to wait for completion of __fput() and know
  * for this specific struct file it won't involve anything that would
  * need them.  Use only if you really need it - at the very least,
diff --git a/include/linux/file.h b/include/linux/file.h
index f87d30882a24..73bb7cee57e9 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -70,7 +70,7 @@ extern void put_unused_fd(unsigned int fd);
 
 extern void fd_install(unsigned int fd, struct file *file);
 
-extern void flush_delayed_fput(void);
+extern void fput_global_flush(void);
 extern void __fput_sync(struct file *);
 
 #endif /* __LINUX_FILE_H */
diff --git a/init/main.c b/init/main.c
index 9e64d7097f1a..6cb24a16ddd6 100644
--- a/init/main.c
+++ b/init/main.c
@@ -941,7 +941,7 @@ static int __ref kernel_init(void *unused)
 	system_state = SYSTEM_RUNNING;
 	numa_default_policy();
 
-	flush_delayed_fput();
+	fput_global_flush();
 
 	if (ramdisk_execute_command) {
 		ret = run_init_process(ramdisk_execute_command);
-- 
2.4.3

