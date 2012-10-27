Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:65280 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755868Ab2J0MeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:23 -0400
Received: by mail-yh0-f46.google.com with SMTP id m54so690985yhm.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:23 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 18/32] vfs: make fchownat retry once on ESTALE errors
Date: Sat, 27 Oct 2012 08:33:25 -0400
Message-Id: <1351341219-17837-19-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/open.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 06f04bd..abb52b9 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -564,24 +564,29 @@ SYSCALL_DEFINE5(fchownat, int, dfd, const char __user *, filename, uid_t, user,
 	struct path path;
 	int error = -EINVAL;
 	int lookup_flags;
+	unsigned int try = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) != 0)
-		goto out;
+		return error;
 
 	lookup_flags = (flag & AT_SYMLINK_NOFOLLOW) ? 0 : LOOKUP_FOLLOW;
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
-	error = user_path_at(dfd, filename, lookup_flags, &path);
-	if (error)
-		goto out;
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto out_release;
-	error = chown_common(&path, user, group);
-	mnt_drop_write(path.mnt);
-out_release:
-	path_put(&path);
-out:
+
+	do {
+		error = user_path_at(dfd, filename, lookup_flags, &path);
+		if (error)
+			break;
+
+		error = mnt_want_write(path.mnt);
+		if (!error) {
+			error = chown_common(&path, user, group);
+			mnt_drop_write(path.mnt);
+		}
+
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

