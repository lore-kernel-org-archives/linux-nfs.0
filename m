Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:48417 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932915Ab2KEPWn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:43 -0500
Received: by mail-yh0-f46.google.com with SMTP id m54so972001yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:43 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 12/34] vfs: fix renameat to retry on ESTALE errors
Date: Mon,  5 Nov 2012 10:21:51 -0500
Message-Id: <1352128933-28526-13-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...as always, rename is the messiest of the bunch. We have to track
whether to retry or not via a separate flag since the error handling
is already quite complex.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index fb5a084..39adf1b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3856,15 +3856,18 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	struct nameidata oldnd, newnd;
 	struct filename *from;
 	struct filename *to;
+	unsigned int try = 0;
+	bool should_retry = false;
 	int error;
 
-	from = user_path_parent(olddfd, oldname, &oldnd, 0);
+retry:
+	from = user_path_parent(olddfd, oldname, &oldnd, try);
 	if (IS_ERR(from)) {
 		error = PTR_ERR(from);
 		goto exit;
 	}
 
-	to = user_path_parent(newdfd, newname, &newnd, 0);
+	to = user_path_parent(newdfd, newname, &newnd, try);
 	if (IS_ERR(to)) {
 		error = PTR_ERR(to);
 		goto exit1;
@@ -3936,11 +3939,17 @@ exit3:
 	unlock_rename(new_dir, old_dir);
 	mnt_drop_write(oldnd.path.mnt);
 exit2:
+	if (retry_estale(error, try++))
+		should_retry = true;
 	path_put(&newnd.path);
 	putname(to);
 exit1:
 	path_put(&oldnd.path);
 	putname(from);
+	if (should_retry) {
+		should_retry = false;
+		goto retry;
+	}
 exit:
 	return error;
 }
-- 
1.7.11.7

