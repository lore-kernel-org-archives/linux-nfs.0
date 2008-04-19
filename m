From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/33] NFS: Remove the buggy lock-if-signalled case from
	do_setlk()
Date: Sat, 19 Apr 2008 16:40:51 -0400
Message-ID: <20080419204051.14124.47142.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53673 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757603AbYDSUuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Apr 2008 16:50:37 -0400
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m3JKoXDB026109
	for <linux-nfs@vger.kernel.org>; Sat, 19 Apr 2008 13:50:36 -0700 (PDT)
In-Reply-To: <20080419204047.14124.49490.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both NLM and NFSv4 should be able to clean up adequately in the case where
the user interrupts the RPC call...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/file.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 8312b0f..3536b01 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -570,17 +570,9 @@ static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 
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

