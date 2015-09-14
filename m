Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:32948 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbbINNqE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 09:46:04 -0400
Received: by ykft14 with SMTP id t14so867459ykf.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 06:46:03 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 2/4] fs: add a kerneldoc header to fput
Date: Mon, 14 Sep 2015 09:45:53 -0400
Message-Id: <1442238355-8203-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
References: <1442238355-8203-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and move its EXPORT_SYMBOL just below the function.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index f4833af62eae..d63f4a399d39 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -260,6 +260,21 @@ void flush_delayed_fput(void)
 	flush_delayed_work(&delayed_fput_work);
 }
 
+/**
+ * fput - put a struct file reference
+ * @file: file of which to put the reference
+ *
+ * This function decrements the reference count for the struct file reference,
+ * and queues it up for destruction if the count goes to zero. In the case of
+ * most tasks we queue it to the task_work infrastructure, which will be run
+ * just before the task returns back to userspace. kthreads however never
+ * return to userspace, so for those we add them to a global list and schedule
+ * a delayed workqueue job to do the work of putting them.
+ *
+ * Why not just do it synchronously? __fput can be quite stack intensive, so
+ * doing a final fput has the possibility of blowing up if we don't take steps
+ * to ensure that we have enough stack space to make it work.
+ */
 void fput(struct file *file)
 {
 	if (atomic_long_dec_and_test(&file->f_count)) {
@@ -280,6 +295,7 @@ void fput(struct file *file)
 			schedule_delayed_work(&delayed_fput_work, 1);
 	}
 }
+EXPORT_SYMBOL(fput);
 
 /*
  * synchronous analog of fput(); for kernel threads that might be needed
@@ -298,7 +314,6 @@ void __fput_sync(struct file *file)
 	}
 }
 
-EXPORT_SYMBOL(fput);
 
 void put_filp(struct file *file)
 {
-- 
2.4.3

