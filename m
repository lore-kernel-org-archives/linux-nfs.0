Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:34175 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbbKQLxV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:21 -0500
Received: by qkfo3 with SMTP id o3so1683771qkf.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:20 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 03/38] fs: add a kerneldoc header to fput
Date: Tue, 17 Nov 2015 06:52:25 -0500
Message-Id: <1447761180-4250-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
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

