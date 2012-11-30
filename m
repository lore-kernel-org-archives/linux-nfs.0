Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:43174 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503Ab2K3KUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 05:20:53 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] fcntl: Introduce new O_DENY* open flags for network filesystems
Date: Fri, 30 Nov 2012 14:20:38 +0400
Message-Id: <1354270840-7272-2-git-send-email-piastry@etersoft.ru>
In-Reply-To: <1354270840-7272-1-git-send-email-piastry@etersoft.ru>
References: <1354270840-7272-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds 3 flags:
1) O_DENYREAD that doesn't permit read access
2) O_DENYWRITE that doesn't permit write access
3) O_DENYDELETE that doesn't permit delete or rename

Network filesystems CIFS, SMB2.0, SMB3.0 and NFSv4 have such flags -
this change can benefit cifs and nfs modules. While this change is ok
for network filesystems, itsn't not targeted for local filesystems due
to security problems (e.g. when a user process can deny root to delete
a file).

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/fcntl.c                       |    5 +++--
 include/uapi/asm-generic/fcntl.h |   11 +++++++++++
 2 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 71a600a..7abce5a 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -730,14 +730,15 @@ static int __init fcntl_init(void)
 	 * Exceptions: O_NONBLOCK is a two bit define on parisc; O_NDELAY
 	 * is defined as O_NONBLOCK on some platforms and not on others.
 	 */
-	BUILD_BUG_ON(19 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
+	BUILD_BUG_ON(22 - 1 /* for O_RDONLY being 0 */ != HWEIGHT32(
 		O_RDONLY	| O_WRONLY	| O_RDWR	|
 		O_CREAT		| O_EXCL	| O_NOCTTY	|
 		O_TRUNC		| O_APPEND	| /* O_NONBLOCK	| */
 		__O_SYNC	| O_DSYNC	| FASYNC	|
 		O_DIRECT	| O_LARGEFILE	| O_DIRECTORY	|
 		O_NOFOLLOW	| O_NOATIME	| O_CLOEXEC	|
-		__FMODE_EXEC	| O_PATH
+		__FMODE_EXEC	| O_PATH	| O_DENYREAD	|
+		O_DENYWRITE	| O_DENYDELETE
 		));
 
 	fasync_cache = kmem_cache_create("fasync_cache",
diff --git a/include/uapi/asm-generic/fcntl.h b/include/uapi/asm-generic/fcntl.h
index a48937d..5ac0d49 100644
--- a/include/uapi/asm-generic/fcntl.h
+++ b/include/uapi/asm-generic/fcntl.h
@@ -84,6 +84,17 @@
 #define O_PATH		010000000
 #endif
 
+#ifndef O_DENYREAD
+#define O_DENYREAD	020000000	/* Do not permit read access */
+#endif
+#ifndef O_DENYWRITE
+#define O_DENYWRITE	040000000	/* Do not permit write access */
+#endif
+/* FMODE_NONOTIFY	0100000000 */
+#ifndef O_DENYDELETE
+#define O_DENYDELETE	0200000000	/* Do not permit delete or rename */
+#endif
+
 #ifndef O_NDELAY
 #define O_NDELAY	O_NONBLOCK
 #endif
-- 
1.7.10.4

