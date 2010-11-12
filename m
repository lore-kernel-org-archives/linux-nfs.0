From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs: trivial: remove unused nfs_wait_event macro
Date: Fri, 12 Nov 2010 09:23:04 -0500
Message-ID: <1289571784-26568-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.122]:63422 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014Ab0KLOYH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Nov 2010 09:24:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nothing uses this macro anymore.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/nfs_fs.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index bba2668..c66fdb7 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -593,12 +593,6 @@ nfs_fileid_to_ino_t(u64 fileid)
 	return ino;
 }
 
-#define nfs_wait_event(clnt, wq, condition)				\
-({									\
-	int __retval = wait_event_killable(wq, condition);		\
-	__retval;							\
-})
-
 #define NFS_JUKEBOX_RETRY_TIME (5 * HZ)
 
 #endif /* __KERNEL__ */
-- 
1.7.2.3

