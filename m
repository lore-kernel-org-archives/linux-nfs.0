From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NFS: Fix do_vfs_lock warning (again)
Date: Fri, 21 Mar 2008 19:02:02 -0400
Message-ID: <20080321230202.23627.23942.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:12314 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764942AbYCUXCc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Mar 2008 19:02:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Commit 46bae1a9 changed this printk to a dprintk but didn't
remove the KERN_WARNING, which is no longer needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/file.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 10e8b80..3438cd4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -520,9 +520,8 @@ static int do_vfs_lock(struct file *file, struct file_lock *fl)
 			BUG();
 	}
 	if (res < 0)
-		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
-			" - error %d!\n",
-				__FUNCTION__, res);
+		dprintk("NFS: VFS is out of sync with lock manager "
+			"(error %d)\n", res);
 	return res;
 }
 

