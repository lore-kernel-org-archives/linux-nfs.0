From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 7/8] NFS: Remove the buggy lock-if-signalled case from
	do_setlk()
Date: Thu, 03 Apr 2008 18:39:22 -0400
Message-ID: <20080403223922.12713.49272.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13124 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbYDCW6E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:58:04 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both NLM and NFSv4 should be able to clean up adequately in the case where
the user interrupts the RPC call...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 10e8b80..742cb74 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -566,17 +566,9 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 
 	lock_kernel();
 	/* Use local locking if mounted with "-onolock" */
-	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)) {
+	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
 		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
-		/* If we were signalled we still need to ensure that
-		 * we clean up any state on the server. We therefore
-		 * record the lock call as having succeeded in order to
-		 * ensure that locks_remove_posix() cleans it out when
-		 * the process exits.
-		 */
-		if (status == -EINTR || status == -ERESTARTSYS)
-			do_vfs_lock(filp, fl);
-	} else
+	else
 		status = do_vfs_lock(filp, fl);
 	unlock_kernel();
 	if (status < 0)

