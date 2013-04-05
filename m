Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f50.google.com ([209.85.215.50]:63891 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422657Ab3DEQyS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:54:18 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v4 7/7] locks: Disable LOCK_MAND support for MS_SHARELOCK mounts
Date: Fri,  5 Apr 2013 20:57:55 +0400
Message-Id: <1365181075-22540-8-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
References: <1365181075-22540-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index ea5813c..8a59afb 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1722,6 +1722,12 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
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

