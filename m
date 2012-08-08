Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36554 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758464Ab2HHNWC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:02 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so724654yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:02 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 10/19] vfs: fix symlinkat to retry on ESTALE errors
Date: Wed,  8 Aug 2012 09:21:33 -0400
Message-Id: <1344432102-22312-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 30 ++++++++++++++++++++----------
 1 file changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 9fd5163..9986117 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3468,24 +3468,34 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
 		int, newdfd, const char __user *, newname)
 {
 	int error;
-	char *from;
+	char *from, *to;
 	struct dentry *dentry;
 	struct path path;
+	unsigned int try = 0;
 
 	from = getname(oldname);
 	if (IS_ERR(from))
 		return PTR_ERR(from);
 
-	dentry = user_path_create(newdfd, newname, &path, 0);
-	error = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		goto out_putname;
+	to = getname(newname);
+	if (IS_ERR(to)) {
+		putname(from);
+		return PTR_ERR(to);
+	}
 
-	error = security_path_symlink(&path, dentry, from);
-	if (!error)
-		error = vfs_symlink(path.dentry->d_inode, dentry, from);
-	done_path_create(&path, dentry);
-out_putname:
+	do {
+		dentry = kern_path_create(newdfd, to, &path, 0, try);
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			break;
+		}
+
+		error = security_path_symlink(&path, dentry, from);
+		if (!error)
+			error = vfs_symlink(path.dentry->d_inode, dentry, from);
+		done_path_create(&path, dentry);
+	} while (retry_estale(error, try++));
+	putname(to);
 	putname(from);
 	return error;
 }
-- 
1.7.11.2

