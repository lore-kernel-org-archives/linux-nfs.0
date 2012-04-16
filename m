Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62861 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab2DPQ4G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 12:56:06 -0400
Received: by yenl12 with SMTP id l12so2582820yen.19
        for <linux-nfs@vger.kernel.org>; Mon, 16 Apr 2012 09:56:05 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        miklos@szeredi.hu, viro@ZenIV.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com, malahal@us.ibm.com,
        bfields@fieldses.org, trond.myklebust@fys.uio.no, rees@umich.edu
Subject: [PATCH RFC v2] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Mon, 16 Apr 2012 12:55:59 -0400
Message-Id: <1334595359-27080-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's another RFC patch that incorporates some of the suggestions so
far:

1) it converts the "goto" construct into a do-while loop

2) This patch drops the FS_* flag so all filesystems would be affected.

3) It adds a backoff timeout mechanism to the loop with an arbitrary 5s cap
on the sleep between attempts (this is certainly negotiable).

4) Also, if the process catches a fatal signal, then we'd break out of the
loop and return the ESTALE to userspace. Not that it would care at that
point since the program is going to die anyway.

Clearly this inlined function will need to go to a header and the cap on
the sleep is probably negotiable. This is just a proof of concept thing
at this point.

Also note that this patch still doesn't incorporate any hard cap on the
number of retries. I could add that too, but perhaps that's not
necessary since we're handling the fatal_signal case here?

Opinions welcome...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/stat.c |   35 +++++++++++++++++++++++++++++------
 1 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index c733dc5..71f2f5b 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -68,12 +68,25 @@ int vfs_fstat(unsigned int fd, struct kstat *stat)
 }
 EXPORT_SYMBOL(vfs_fstat);
 
+/* max retry timeout of 5s */
+#define MAX_ESTALE_RETRY_TIMEOUT	(5 * HZ)
+
+static inline bool
+estale_retry(int error, long timeout)
+{
+	if (likely(error != -ESTALE))
+		return false;
+
+	return !schedule_timeout_killable(timeout);
+}
+
 int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 		int flag)
 {
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	long timeout = 1;
+	unsigned int lookup_flags = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -84,12 +97,22 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
-	error = user_path_at(dfd, filename, lookup_flags, &path);
-	if (error)
-		goto out;
+	do {
+		/*
+		 * if lookup fails with ESTALE, then that implies that the
+		 * root of the mount went stale. Give up at that point...
+		 */
+		error = user_path_at(dfd, filename, lookup_flags, &path);
+		if (error)
+			break;
 
-	error = vfs_getattr(path.mnt, path.dentry, stat);
-	path_put(&path);
+		error = vfs_getattr(path.mnt, path.dentry, stat);
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+		timeout <<= 1;
+		if (timeout > MAX_ESTALE_RETRY_TIMEOUT)
+			timeout = MAX_ESTALE_RETRY_TIMEOUT;
+	} while (estale_retry(error, timeout));
 out:
 	return error;
 }
-- 
1.7.7.6

