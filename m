Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:39317 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758484Ab2HHNWH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:07 -0400
Received: by mail-gg0-f174.google.com with SMTP id k6so15227ggd.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:07 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 14/19] vfs: fix renameat to retry on ESTALE errors
Date: Wed,  8 Aug 2012 09:21:37 -0400
Message-Id: <1344432102-22312-15-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...as always, rename is the messiest of the bunch. We have to track
whether to retry or not via a separate flag since the error handling
is already quite complex.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 0c112c3..936591f 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3817,12 +3817,25 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
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
 
@@ -3891,13 +3904,21 @@ exit4:
 exit3:
 	unlock_rename(new_dir, old_dir);
 	mnt_drop_write(oldnd.path.mnt);
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
1.7.11.2

