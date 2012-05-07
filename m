Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:38192 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756963Ab2EGOMe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2012 10:12:34 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so4163244yhm.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 May 2012 07:12:34 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com
Subject: [PATCH v1 RESEND 12/12] vfs: fix renameat to retry on ESTALE errors
Date: Mon,  7 May 2012 10:12:11 -0400
Message-Id: <1336399931-20234-13-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
References: <1336399931-20234-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...as always, rename is the messiest of the bunch...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a40dcbb..3e15aea 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3274,12 +3274,15 @@ SYSCALL_DEFINE4(renameat, int, olddfd, const char __user *, oldname,
 	char *from;
 	char *to;
 	int error;
+	unsigned int try = 0;
+	bool should_retry = false;
 
-	error = user_path_parent(olddfd, oldname, &oldnd, &from, false);
+retry:
+	error = user_path_parent(olddfd, oldname, &oldnd, &from, try);
 	if (error)
 		goto exit;
 
-	error = user_path_parent(newdfd, newname, &newnd, &to, false);
+	error = user_path_parent(newdfd, newname, &newnd, &to, try);
 	if (error)
 		goto exit1;
 
@@ -3348,12 +3351,18 @@ exit4:
 	dput(old_dentry);
 exit3:
 	unlock_rename(new_dir, old_dir);
+	if (retry_estale(error, try++))
+		should_retry = true;
 exit2:
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
1.7.7.6

