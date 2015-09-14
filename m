Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:35425 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396AbbINNqF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 09:46:05 -0400
Received: by ykdu9 with SMTP id u9so153505943ykd.2
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 06:46:04 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 3/4] fs: add fput_queue
Date: Mon, 14 Sep 2015 09:45:54 -0400
Message-Id: <1442238355-8203-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c      | 18 ++++++++++++++++++
 include/linux/file.h |  1 +
 2 files changed, 19 insertions(+)

diff --git a/fs/file_table.c b/fs/file_table.c
index d63f4a399d39..1ad2e3fd2064 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -297,6 +297,24 @@ void fput(struct file *file)
 }
 EXPORT_SYMBOL(fput);
 
+/**
+ * fput_queue - do an fput without using task_work
+ * @file: file of which to put the reference
+ *
+ * If we need to ensure that the final __fput is done on a file before
+ * returning to userland, then we can't queue it to task_work. For that we
+ * borrow the infrastructure used by kthreads, and the task can then just
+ * called flush_delayed_fput to ensure that the final fput has completed.
+ */
+void fput_queue(struct file *file)
+{
+	if (atomic_long_dec_and_test(&file->f_count)) {
+		if (llist_add(&file->f_u.fu_llist, &delayed_fput_list))
+			schedule_delayed_work(&delayed_fput_work, 1);
+	}
+}
+EXPORT_SYMBOL(fput_queue);
+
 /*
  * synchronous analog of fput(); for kernel threads that might be needed
  * in some umount() (and thus can't use flush_delayed_fput() without
diff --git a/include/linux/file.h b/include/linux/file.h
index f87d30882a24..543b0e2faf2c 100644
--- a/include/linux/file.h
+++ b/include/linux/file.h
@@ -12,6 +12,7 @@
 struct file;
 
 extern void fput(struct file *);
+extern void fput_queue(struct file *);
 
 struct file_operations;
 struct vfsmount;
-- 
2.4.3

