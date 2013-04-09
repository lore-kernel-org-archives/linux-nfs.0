Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:59843 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964846Ab3DIMgq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Apr 2013 08:36:46 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v5 7/7] locks: Disable LOCK_MAND support for MS_SHARELOCK mounts
Date: Tue,  9 Apr 2013 16:40:27 +0400
Message-Id: <1365511227-17626-8-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1365511227-17626-1-git-send-email-piastry@etersoft.ru>
References: <1365511227-17626-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 1402a43..a67857c 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1719,6 +1719,12 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 	if (!f.file)
 		goto out;
 
+	/* Disable LOCK_MAND support for FS mounted with MS_SHARELOCK */
+	if (IS_SHARELOCK(f.file->f_path.dentry->d_inode)) {
+		error = -EPERM;
+		goto out;
+	}
+
 	can_sleep = !(cmd & LOCK_NB);
 	cmd &= ~LOCK_NB;
 	unlock = (cmd == LOCK_UN);
-- 
1.8.1.5

