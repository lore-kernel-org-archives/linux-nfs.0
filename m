Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f42.google.com ([209.85.215.42]:48879 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbaAQKHe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 05:07:34 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 3/7] locks: Disable LOCK_MAND support for MS_SHARELOCK mounts
Date: Fri, 17 Jan 2014 14:07:08 +0400
Message-Id: <1389953232-9428-4-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
References: <1389953232-9428-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 7ecc511..c7e780a 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1904,6 +1904,12 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
 		goto out;
 	}
 
+	/* Disable LOCK_MAND support for FS mounted with MS_SHARELOCK */
+	if ((cmd & LOCK_MAND) && IS_SHARELOCK(f.file->f_path.dentry->d_inode)) {
+		error = -EPERM;
+		goto out;
+	}
+
 	can_sleep = !(cmd & LOCK_NB);
 	cmd &= ~LOCK_NB;
 	unlock = (cmd == LOCK_UN);
-- 
1.7.10.4

