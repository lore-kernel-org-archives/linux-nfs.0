Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:33160 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706Ab0LGVT4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 16:19:56 -0500
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH] vfs: pass struct file to do_truncate on O_TRUNC opens (try #2)
Date: Tue,  7 Dec 2010 16:19:50 -0500
Message-Id: <1291756790-6030-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

I originally sent this patch back in March of this year, but it
apparently fell through the cracks...

When a file is opened with O_TRUNC, the truncate processing is handled
by handle_truncate(). This function however doesn't receive any info
about the newly instantiated filp, and therefore can't pass that info
along so that the setattr can use it.

This makes NFSv4 misbehave. The client does an open and gets a valid
stateid, and then doesn't use that stateid on the subsequent truncate.
It uses the zero-stateid instead. Most servers ignore this fact and
just do the truncate anyway, but some don't like it (notably, RHEL4).

It seems more correct that since we have a fully instantiated file at
the time that handle_truncate is called, that we pass that along so
that the truncate operation can properly use it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 5362af9..ad844eb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1448,8 +1448,9 @@ int may_open(struct path *path, int acc_mode, int flag)
 	return break_lease(inode, flag);
 }
 
-static int handle_truncate(struct path *path)
+static int handle_truncate(struct file *filp)
 {
+	struct path *path = &filp->f_path;
 	struct inode *inode = path->dentry->d_inode;
 	int error = get_write_access(inode);
 	if (error)
@@ -1463,7 +1464,7 @@ static int handle_truncate(struct path *path)
 	if (!error) {
 		error = do_truncate(path->dentry, 0,
 				    ATTR_MTIME|ATTR_CTIME|ATTR_OPEN,
-				    NULL);
+				    filp);
 	}
 	put_write_access(inode);
 	return error;
@@ -1560,7 +1561,7 @@ static struct file *finish_open(struct nameidata *nd,
 	}
 	if (!IS_ERR(filp)) {
 		if (will_truncate) {
-			error = handle_truncate(&nd->path);
+			error = handle_truncate(filp);
 			if (error) {
 				fput(filp);
 				filp = ERR_PTR(error);
-- 
1.7.3.2

