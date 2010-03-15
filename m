Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:62813 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab0COVjP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 17:39:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH] vfs: pass struct file to do_truncate on O_TRUNC opens
Date: Mon, 15 Mar 2010 17:39:12 -0400
Message-Id: <1268689152-19168-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

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
index 1c0fca6..965a3bb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1472,8 +1472,9 @@ int may_open(struct path *path, int acc_mode, int flag)
 	return break_lease(inode, flag);
 }
 
-static int handle_truncate(struct path *path)
+static int handle_truncate(struct file *filp)
 {
+	struct path *path = &filp->f_path;
 	struct inode *inode = path->dentry->d_inode;
 	int error = get_write_access(inode);
 	if (error)
@@ -1488,7 +1489,7 @@ static int handle_truncate(struct path *path)
 	if (!error) {
 		error = do_truncate(path->dentry, 0,
 				    ATTR_MTIME|ATTR_CTIME|ATTR_OPEN,
-				    NULL);
+				    filp);
 	}
 	put_write_access(inode);
 	return error;
@@ -1585,7 +1586,7 @@ static struct file *finish_open(struct nameidata *nd,
 	}
 	if (!IS_ERR(filp)) {
 		if (will_truncate) {
-			error = handle_truncate(&nd->path);
+			error = handle_truncate(filp);
 			if (error) {
 				fput(filp);
 				filp = ERR_PTR(error);
-- 
1.6.6.1

