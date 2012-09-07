Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f46.google.com ([209.85.212.46]:42139 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760685Ab2IGOSp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:18:45 -0400
Received: by vbbff1 with SMTP id ff1so3363913vbb.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:18:45 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 01/20] vfs: add a retry_estale helper function to handle retries on ESTALE
Date: Fri,  7 Sep 2012 10:18:08 -0400
Message-Id: <1347027507-20956-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This function is expected to be called from path-based syscalls to help
them decide whether to try the lookup and call again in the event that
they got an -ESTALE return back on an earier try.

Currently, we only retry the call once on an ESTALE error, but in the
event that we decide that that's not enough in the future, we should be
able to change the logic in this helper without too much effort.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/fs.h | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index a3c2c17..78e8639 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2221,6 +2221,27 @@ extern int finish_open(struct file *file, struct dentry *dentry,
 			int *opened);
 extern int finish_no_open(struct file *file, struct dentry *dentry);
 
+/**
+ * retry_estale - determine whether the caller should retry an operation
+ *
+ * @error: the error we'll be returning
+ * @try: number of retries already performed
+ *
+ * Check to see if the error code was -ESTALE, and then determine whether
+ * to retry the call based on the number of retries so far. Currently, we only
+ * retry the call once.
+ *
+ * Returns true if the caller should try again.
+ */
+static inline bool
+retry_estale(const long error, const unsigned int try)
+{
+	if (likely(error != -ESTALE))
+		return false;
+
+	return !try;
+}
+
 /* fs/ioctl.c */
 
 extern int ioctl_preallocate(struct file *filp, void __user *argp);
-- 
1.7.11.4

