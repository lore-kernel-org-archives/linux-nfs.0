Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f42.google.com ([209.85.213.42]:40749 "EHLO
	mail-yw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285Ab2F2S6I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:08 -0400
Received: by yhfq11 with SMTP id q11so4407178yhf.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:07 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 01/17] vfs: add a retry_estale helper function to handle retries on ESTALE
Date: Fri, 29 Jun 2012 14:57:44 -0400
Message-Id: <1340996280-27123-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
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
 include/linux/fs.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 17fd887..4a2aa04 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2062,6 +2062,27 @@ extern struct file * dentry_open(struct dentry *, struct vfsmount *, int,
 extern int filp_close(struct file *, fl_owner_t id);
 extern char * getname(const char __user *);
 
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
1.7.7.6

