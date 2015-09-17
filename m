Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33490 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbbIQMj5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 08:39:57 -0400
Received: by ykft14 with SMTP id t14so15186687ykf.0
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 05:39:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH v2 3/4] fs: add fput_queue
Date: Thu, 17 Sep 2015 08:39:46 -0400
Message-Id: <1442493587-32499-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1442493587-32499-1-git-send-email-jeff.layton@primarydata.com>
References: <1442493587-32499-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When nfsd caches a file, we want to be able to close it down in advance
of setlease attempts. Setting a lease is generally done at the behest of
userland, so we need a mechanism to ensure that a userland task can
completely close a file without having to return back to userspace.

To do this, we borrow the delayed_fput infrastructure that kthreads use.
fput_queue will queue to the delayed_fput list if the last reference was
put. The caller can then call flush_delayed_fput to ensure that the files
are completely closed before proceeding.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c      | 27 +++++++++++++++++++++++++++
 include/linux/file.h |  1 +
 2 files changed, 28 insertions(+)

diff --git a/fs/file_table.c b/fs/file_table.c
index 8cfeaee6323f..95361d2b8a08 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -302,6 +302,33 @@ void fput(struct file *file)
 }
 EXPORT_SYMBOL(fput);
 
+/**
+ * fput_queue - do an fput without using task_work
+ * @file: file of which to put the reference
+ *
+ * When fput is called in the context of a userland process, it'll queue the
+ * actual work (__fput()) to be done just before returning to userland. In some
+ * cases however, we need to ensure that the __fput runs before that point.
+ * There is no safe way to flush work that has been queued via task_work_add
+ * however, so to do this we borrow the delayed_fput infrastructure that
+ * kthreads use. The userland process can use fput_queue() on one or more
+ * struct files and then call flush_delayed_fput() to ensure that they are
+ * completely closed before proceeding.
+ *
+ * Returns true if the final fput was done, false otherwise. The caller can
+ * use this to determine whether to flush_delayed_fput afterward.
+ */
+bool fput_queue(struct file *file)
+{
+	if (atomic_long_dec_and_test(&file->f_count)) {
+		if (llist_add(&file->f_u.fu_llist, &delayed_fput_list))
+			schedule_delayed_work(&delayed_fput_work, 1);
+		return true;
+	}
+	return false;
+}
+EXPORT_SYMBOL(fput_queue);
+
 /*
  * synchronous analog of fput(); for kernel threads that might be needed
  * in some umount() (and thus can't use flush_delayed_fput() without
diff --git a/include/linux/file.h b/include/linux/file.h
index f87d30882a24..f9308c9a0746 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -12,6 +12,7 @@
 struct file;
 
 extern void fput(struct file *);
+extern bool fput_queue(struct file *);
 
 struct file_operations;
 struct vfsmount;
-- 
2.4.3

