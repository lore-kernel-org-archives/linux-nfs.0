Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:64114 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820Ab2J0MeB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:01 -0400
Received: by mail-gh0-f174.google.com with SMTP id g15so699683ghb.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:01 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 07/32] vfs: fix symlinkat to retry on ESTALE errors
Date: Sat, 27 Oct 2012 08:33:14 -0400
Message-Id: <1351341219-17837-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 6e8db3d..7def44b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3525,21 +3525,25 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
 	struct filename *from;
 	struct dentry *dentry;
 	struct path path;
+	unsigned int try = 0;
 
 	from = getname(oldname);
 	if (IS_ERR(from))
 		return PTR_ERR(from);
 
-	dentry = user_path_create(newdfd, newname, &path, false, false);
-	error = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		goto out_putname;
+	do {
+		dentry = user_path_create(newdfd, newname, &path, false, false);
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			break;
+		}
 
-	error = security_path_symlink(&path, dentry, from->name);
-	if (!error)
-		error = vfs_symlink(path.dentry->d_inode, dentry, from->name);
-	done_path_create(&path, dentry);
-out_putname:
+		error = security_path_symlink(&path, dentry, from->name);
+		if (!error)
+			error = vfs_symlink(path.dentry->d_inode, dentry,
+						from->name);
+		done_path_create(&path, dentry);
+	} while (retry_estale(error, try++));
 	putname(from);
 	return error;
 }
-- 
1.7.11.7

