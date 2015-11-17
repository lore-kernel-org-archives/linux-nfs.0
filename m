Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:32992 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378AbbKQLxX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:23 -0500
Received: by qkas77 with SMTP id s77so1711469qka.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:22 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 05/38] fs: add fput_global
Date: Tue, 17 Nov 2015 06:52:27 -0500
Message-Id: <1447761180-4250-6-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When nfsd caches a file, we want to be able to close it down in advance
of setlease attempts. Setting a lease is generally done at the behest of
userland, so we need a mechanism to ensure that a userland task can
completely close a file without having to return back to userspace.

To do this, we borrow the global delayed_fput infrastructure that
kthreads use. fput_global will queue to the global_fput list if
the last reference was put. The caller can then use fput_global_flush
to force the final __fput to run.

While we're at it, export fput_global_flush as nfsd will need to use
that as well.

Cc: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c      | 33 +++++++++++++++++++++++++++++++++
 include/linux/file.h |  1 +
 2 files changed, 34 insertions(+)

diff --git a/fs/file_table.c b/fs/file_table.c
index 0bf8ddc680ab..d214c45765e6 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -262,6 +262,7 @@ void fput_global_flush(void)
 {
 	flush_delayed_work(&global_fput_work);
 }
+EXPORT_SYMBOL(fput_global_flush);
 
 /**
  * fput - put a struct file reference
@@ -304,6 +305,38 @@ void fput(struct file *file)
 }
 EXPORT_SYMBOL(fput);
 
+/**
+ * fput_global - do an fput without using task_work
+ * @file: file of which to put the reference
+ *
+ * When fput is called in the context of a userland process, it'll queue the
+ * actual work (__fput()) to be done just before returning to userland. In some
+ * cases however, we need to ensure that the __fput runs before that point.
+ *
+ * There is no safe way to flush work that has been queued via task_work_add
+ * however, so to do this we borrow the global_fput infrastructure that
+ * kthreads use. The userland process can use fput_global() on one or more
+ * struct files and then call fput_global_flush() to ensure that they are
+ * completely closed before proceeding.
+ *
+ * The main user is nfsd, which uses this to ensure that all cached but
+ * otherwise unused files are closed to allow a userland request for a lease
+ * to proceed.
+ *
+ * Returns true if the final fput was done, false otherwise. The caller can
+ * use this to determine whether to fput_global_flush afterward.
+ */
+bool fput_global(struct file *file)
+{
+	if (atomic_long_dec_and_test(&file->f_count)) {
+		if (llist_add(&file->f_u.fu_llist, &global_fput_list))
+			schedule_delayed_work(&global_fput_work, 1);
+		return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL(fput_global);
+
 /*
  * synchronous analog of fput(); for kernel threads that might be needed
  * in some umount() (and thus can't use fput_global_flush() without
diff --git a/include/linux/file.h b/include/linux/file.h
index 73bb7cee57e9..7803aed00271 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -12,6 +12,7 @@
 struct file;
 
 extern void fput(struct file *);
+extern bool fput_global(struct file *);
 
 struct file_operations;
 struct vfsmount;
-- 
2.4.3

