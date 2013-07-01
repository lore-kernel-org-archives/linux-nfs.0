Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f176.google.com ([209.85.217.176]:58227 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656Ab3GAQnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jul 2013 12:43:09 -0400
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v7 7/7] locks: Disable LOCK_MAND support for MS_SHARELOCK mounts
Date: Mon,  1 Jul 2013 20:49:59 +0400
Message-Id: <1372697399-21361-8-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1372697399-21361-1-git-send-email-piastry@etersoft.ru>
References: <1372697399-21361-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/locks.c b/fs/locks.c
index 60f3ce8..86f3a93 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1758,6 +1758,12 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, unsigned int, cmd)
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
1.8.1.5

