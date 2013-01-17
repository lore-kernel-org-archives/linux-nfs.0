Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f53.google.com ([209.85.215.53]:37705 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752708Ab3AQRBf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 12:01:35 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v2 5/8] CIFS: Use NT_CREATE_ANDX command for forcemand mounts
Date: Thu, 17 Jan 2013 20:53:01 +0400
Message-Id: <1358441584-8783-5-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
References: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

forcemand mount option now lets us use Windows mandatory style of
byte-range locks even if server supports posix ones - switches on
Windows locking mechanism. Share flags is another locking mehanism
provided by Windows semantic that can be used by NT_CREATE_ANDX
command. This patch combines all Windows locking mechanism in one
mount option by using NT_CREATE_ANDX to open files if forcemand is on.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/cifs/dir.c  | 1 +
 fs/cifs/file.c | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/cifs/dir.c b/fs/cifs/dir.c
index 12ee773..06be419 100644
--- a/fs/cifs/dir.c
+++ b/fs/cifs/dir.c
@@ -185,6 +185,7 @@ cifs_do_create(struct inode *inode, struct dentry *direntry, unsigned int xid,
 	}
 
 	if (tcon->unix_ext && cap_unix(tcon->ses) && !tcon->broken_posix_open &&
+	    ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NOPOSIXBRL) == 0) &&
 	    (CIFS_UNIX_POSIX_PATH_OPS_CAP &
 			le64_to_cpu(tcon->fsUnixInfo.Capability))) {
 		rc = cifs_posix_open(full_path, &newinode, inode->i_sb, mode,
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 4ddf450..bb10486 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -426,8 +426,9 @@ int cifs_open(struct inode *inode, struct file *file)
 	else
 		oplock = 0;
 
-	if (!tcon->broken_posix_open && tcon->unix_ext &&
-	    cap_unix(tcon->ses) && (CIFS_UNIX_POSIX_PATH_OPS_CAP &
+	if (!tcon->broken_posix_open && tcon->unix_ext && cap_unix(tcon->ses)
+	    && ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NOPOSIXBRL) == 0) &&
+	    (CIFS_UNIX_POSIX_PATH_OPS_CAP &
 				le64_to_cpu(tcon->fsUnixInfo.Capability))) {
 		/* can not refresh inode info since size could be stale */
 		rc = cifs_posix_open(full_path, &inode, inode->i_sb,
@@ -575,6 +576,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 		oplock = 0;
 
 	if (tcon->unix_ext && cap_unix(tcon->ses) &&
+	    ((cifs_sb->mnt_cifs_flags & CIFS_MOUNT_NOPOSIXBRL) == 0) &&
 	    (CIFS_UNIX_POSIX_PATH_OPS_CAP &
 				le64_to_cpu(tcon->fsUnixInfo.Capability))) {
 		/*
-- 
1.8.1.1

