Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:36745 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775AbbIKKy4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 06:54:56 -0400
Received: by ykdt18 with SMTP id t18so66772259ykd.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2015 03:54:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v4 03/16] fs: allow __fput_sync to be used by non-kthreads and in modules
Date: Fri, 11 Sep 2015 06:54:29 -0400
Message-Id: <1441968882-7851-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
References: <1441968882-7851-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want nfsd to keep a cache of open files, but that would potentially
block userland callers from obtaining leases on them. To fix this,
we'll be adding a new notifier chain to the lease code that will call
back into nfsd on any attempt to set a FL_LEASE. nfsd can then close
any open files for that inode in advance of that.

The problem however is that since that notifier will run in normal
process context, the final __fput will be delayed a'la task_work and we
are still unable to set a lease. What we need to do is to put the struct
file synchronously so that the __fput runs before returning from the
notifier call.

The comments over __fput_sync and the BUG_ON in there mandate that it
should only be used in kthread context, but I see no reason why that
should be so. As long as the caller avoids holding locks that may be
problematic, it should be OK to use it from normal process context as
well.

Remove the __ prefix and the BUG_ON from that function and update the
comments over it. Also export it so that it can be used from nfsd code,
and move the export of fput just below the function definition.

Cc: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c      | 27 ++++++++++++++-------------
 include/linux/file.h |  2 +-
 kernel/acct.c        |  2 +-
 3 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index f4833af62eae..6769ed45c35f 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -280,25 +280,26 @@ void fput(struct file *file)
 			schedule_delayed_work(&delayed_fput_work, 1);
 	}
 }
+EXPORT_SYMBOL(fput);
 
 /*
- * synchronous analog of fput(); for kernel threads that might be needed
- * in some umount() (and thus can't use flush_delayed_fput() without
- * risking deadlocks), need to wait for completion of __fput() and know
- * for this specific struct file it won't involve anything that would
- * need them.  Use only if you really need it - at the very least,
- * don't blindly convert fput() by kernel thread to that.
+ * synchronous analog of fput(); this is necessary for tasks
+ * that might be needed in some umount() (and thus can't use
+ * flush_delayed_fput() without risking deadlocks), need to wait for
+ * completion of __fput() and know for this specific struct file it
+ * won't involve anything that would need them. It's also necessary
+ * for nfsd, which needs to be able to synchronously close files
+ * on which userspace programs are trying to set leases.
+ *
+ * Use only if you really need it - at the very least, don't blindly
+ * convert fput() to this.
  */
-void __fput_sync(struct file *file)
+void fput_sync(struct file *file)
 {
-	if (atomic_long_dec_and_test(&file->f_count)) {
-		struct task_struct *task = current;
-		BUG_ON(!(task->flags & PF_KTHREAD));
+	if (atomic_long_dec_and_test(&file->f_count))
 		__fput(file);
-	}
 }
-
-EXPORT_SYMBOL(fput);
+EXPORT_SYMBOL(fput_sync);
 
 void put_filp(struct file *file)
 {
diff --git a/include/linux/file.h b/include/linux/file.h
index f87d30882a24..046a8c477b9a 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -71,6 +71,6 @@ extern void put_unused_fd(unsigned int fd);
 extern void fd_install(unsigned int fd, struct file *file);
 
 extern void flush_delayed_fput(void);
-extern void __fput_sync(struct file *);
+extern void fput_sync(struct file *);
 
 #endif /* __LINUX_FILE_H */
diff --git a/kernel/acct.c b/kernel/acct.c
index 74963d192c5d..b58300ebd819 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -183,7 +183,7 @@ static void close_work(struct work_struct *work)
 	struct file *file = acct->file;
 	if (file->f_op->flush)
 		file->f_op->flush(file, NULL);
-	__fput_sync(file);
+	fput_sync(file);
 	complete(&acct->done);
 }
 
-- 
2.4.3

