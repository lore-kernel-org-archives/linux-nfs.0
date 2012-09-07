Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62753 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755560Ab2IGOSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Sep 2012 10:18:54 -0400
Received: by mail-yx0-f174.google.com with SMTP id l14so545956yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 07 Sep 2012 07:18:54 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v6 12/20] vfs: fix renameat to retry on ESTALE errors
Date: Fri,  7 Sep 2012 10:18:19 -0400
Message-Id: <1347027507-20956-13-git-send-email-jlayton@redhat.com>
In-Reply-To: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
References: <1347027507-20956-1-git-send-email-jlayton@redhat.com>
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
index 77c2b1055..010d428 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3847,15 +3847,18 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	struct nameidata oldnd, newnd;
 	struct getname_info *from;
 	struct getname_info *to;
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
@@ -3927,11 +3930,17 @@ exit3:
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
1.7.11.4

