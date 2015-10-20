Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34087 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbbJTReB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:01 -0400
Received: by qgem9 with SMTP id m9so21698579qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:00 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 03/19] fs: add a kerneldoc header to fput
Date: Tue, 20 Oct 2015 13:33:36 -0400
Message-Id: <1445362432-18869-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and move its EXPORT_SYMBOL just below the function.

Cc: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 52cc6803c07a..8cfeaee6323f 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -261,6 +261,25 @@ void flush_delayed_fput(void)
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
+ * a delayed workqueue job to do the final cleanup work.
+ *
+ * Why not just do it synchronously? __fput can involve taking locks of all
+ * sorts, and doing it synchronously means that the callers must take extra care
+ * not to deadlock. That can be very difficult to ensure, so by deferring it
+ * until just before return to userland or to the workqueue, we sidestep that
+ * nastiness. Also, __fput can be quite stack intensive, so doing a final fput
+ * has the possibility of blowing up if we don't take steps to ensure that we
+ * have enough stack space to make it work.
+ */
 void fput(struct file *file)
 {
 	if (atomic_long_dec_and_test(&file->f_count)) {
@@ -281,6 +300,7 @@ void fput(struct file *file)
 			schedule_delayed_work(&delayed_fput_work, 1);
 	}
 }
+EXPORT_SYMBOL(fput);
 
 /*
  * synchronous analog of fput(); for kernel threads that might be needed
@@ -299,7 +319,6 @@ void __fput_sync(struct file *file)
 	}
 }
 
-EXPORT_SYMBOL(fput);
 
 void put_filp(struct file *file)
 {
-- 
2.4.3

