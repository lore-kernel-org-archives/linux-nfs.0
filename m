Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f174.google.com ([209.85.213.174]:61085 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab2KEPWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:23 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so1017195yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:22 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 01/34] vfs: add a retry_estale helper function to handle retries on ESTALE
Date: Mon,  5 Nov 2012 10:21:40 -0500
Message-Id: <1352128933-28526-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
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
 include/linux/fs.h | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index b33cfc9..3e42289 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2023,6 +2023,26 @@ extern int finish_open(struct file *file, struct dentry *dentry,
 			int *opened);
 extern int finish_no_open(struct file *file, struct dentry *dentry);
 
+/**
+ * retry_estale - determine whether the caller should retry an operation
+ * @error: the error that would currently be returned
+ * @try: number of tries already performed
+ *
+ * Check to see if the error code was -ESTALE, and then determine whether
+ * to retry the call based on the number of tries so far. Currently, we only
+ * retry the call once.
+ *
+ * Returns true if the caller should try the operation again.
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
1.7.11.7

