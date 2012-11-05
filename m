Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:58921 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933148Ab2KEPXZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:23:25 -0500
Received: by mail-gg0-f174.google.com with SMTP id k5so1002120ggd.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:23:24 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 34/34] vfs: add a sliding backoff delay between ESTALE retries
Date: Mon,  5 Nov 2012 10:22:13 -0500
Message-Id: <1352128933-28526-35-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...with a hard, arbitrary cap on the amount of time that it will sleep
between tries. If we have a case where we're doing a lot of retries on
an ESTALE, then this should help keep us from hammering the fs as badly.

With this change, retry_estale has probably outgrown being an inline.
Make the check for ESTALE error an inline, and turn the rest of the
actual handling into a regular function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c         | 33 +++++++++++++++++++++++++++++++++
 include/linux/fs.h |  7 ++++---
 2 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 70592ec..ae61487 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -112,6 +112,39 @@
 
 unsigned int estale_retries __read_mostly = 1;
 
+/**
+ * __retry_estale - determine whether the caller should retry an operation
+ * @try: number of tries already performed
+ *
+ * Determine whether to retry a call based on the number of retries so far.
+ * It's expected that the caller has already determined that the error is
+ * estale.
+ *
+ * In the event that we're retrying multiple times, we also add an exponential
+ * backoff to allow things to stabilize before trying again. We do however add
+ * an arbitrary cap to that sleep.
+ *
+ * Returns true if the caller should try again.
+ */
+#define MAX_RETRY_ESTALE_DELAY	(3 * HZ)
+bool
+__retry_estale(const unsigned int try)
+{
+	bool should_retry = (try <= estale_retries);
+
+	/*
+	 * If we're retrying multiple times, then do a small, sliding delay to
+	 * cut down on the amount that we hammer the fs with requests. In
+	 * principle this gives things time to "settle down" before retrying.
+	 */
+	if (should_retry) {
+		long timeout = min_t(long, try * 2, MAX_RETRY_ESTALE_DELAY);
+		if (timeout)
+			schedule_timeout_killable(timeout);
+	}
+	return should_retry;
+}
+
 /* In order to reduce some races, while at the same time doing additional
  * checking and hopefully speeding things up, we copy filenames to the
  * kernel data space before using them..
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1789199..6a16b09 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2024,14 +2024,15 @@ extern int finish_open(struct file *file, struct dentry *dentry,
 extern int finish_no_open(struct file *file, struct dentry *dentry);
 
 extern unsigned int estale_retries;
+extern bool __retry_estale(const unsigned int try);
 
 /**
  * retry_estale - determine whether the caller should retry an operation
  * @error: the error that would currently be returned
  * @try: number of tries already performed
  *
- * Check to see if the error code was -ESTALE, and then determine whether
- * to retry the call based on the number of tries so far.
+ * Check to see if the error code was -ESTALE, and then call a separate routine
+ * to handle the situation if it is.
  *
  * Returns true if the caller should try the operation again.
  */
@@ -2041,7 +2042,7 @@ retry_estale(const long error, const unsigned int try)
 	if (likely(error != -ESTALE))
 		return false;
 
-	return (try <= estale_retries);
+	return __retry_estale(try);
 }
 
 /* fs/ioctl.c */
-- 
1.7.11.7

