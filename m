Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:39883 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758151Ab2EVOMt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:49 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so778011ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:49 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 14/15] vfs: fix renameat to retry on ESTALE errors
Date: Tue, 22 May 2012 10:12:18 -0400
Message-Id: <1337695939-2741-15-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...as always, rename is the messiest of the bunch. We have to track
whether to retry or not via a separate flag since the error handling
is already quite complex.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   31 ++++++++++++++++++++++++++-----
 1 files changed, 26 insertions(+), 5 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 486a60a..4d2b810 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3325,12 +3325,25 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	char *from;
 	char *to;
 	int error;
+	unsigned int try = 0;
+	bool should_retry = false;
+	unsigned int lookup_flags = LOOKUP_PARENT;
 
-	error = user_path_parent(olddfd, oldname, &oldnd, &from);
-	if (error)
+	from = getname(oldname);
+	if (IS_ERR(from))
+		return PTR_ERR(from);
+
+	to = getname(newname);
+	if (IS_ERR(to)) {
+		error = PTR_ERR(to);
 		goto exit;
+	}
+retry:
+	error = do_path_lookup(olddfd, from, lookup_flags, &oldnd);
+	if (error)
+		goto exit0;
 
-	error = user_path_parent(newdfd, newname, &newnd, &to);
+	error = do_path_lookup(newdfd, to, lookup_flags, &newnd);
 	if (error)
 		goto exit1;
 
@@ -3399,13 +3412,21 @@ exit4:
 	dput(old_dentry);
 exit3:
 	unlock_rename(new_dir, old_dir);
+	if (retry_estale(error, try++))
+		should_retry = true;
 exit2:
 	path_put(&newnd.path);
-	putname(to);
 exit1:
 	path_put(&oldnd.path);
-	putname(from);
+	if (should_retry) {
+		should_retry = false;
+		lookup_flags |= LOOKUP_REVAL;
+		goto retry;
+	}
+exit0:
+	putname(to);
 exit:
+	putname(from);
 	return error;
 }
 
-- 
1.7.7.6

