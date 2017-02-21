Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43566 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752033AbdBUPjZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 21 Feb 2017 10:39:25 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] NFS: Always send an unlock for FL_CLOSE
Date: Tue, 21 Feb 2017 10:39:17 -0500
Message-Id: <72fa3f2a37146d153722d842e9b0d166fe11f1ad.1487691345.git.bcodding@redhat.com>
In-Reply-To: <cover.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
In-Reply-To: <cover.1487691345.git.bcodding@redhat.com>
References: <cover.1487691345.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS attempts to wait for read and write completion before unlocking in
order to ensure that the data returned was protected by the lock.  When
this waiting is interrupted by a signal, the unlock may be skipped, and
messages similar to the following are seen in the kernel ring buffer:

[20.167876] Leaked locks on dev=0x0:0x2b ino=0x8dd4c3:
[20.168286] POSIX: fl_owner=ffff880078b06940 fl_flags=0x1 fl_type=0x0 fl_pid=20183
[20.168727] POSIX: fl_owner=ffff880078b06680 fl_flags=0x1 fl_type=0x0 fl_pid=20185

For NFSv3, the missing unlock will cause the server to refuse conflicting
locks indefinitely.  For NFSv4, the leftover lock will be removed by the
server after the lease timeout.

This patch fixes this issue by skipping the wait in order to immediately send
the unlock if the FL_CLOSE flag is set when signaled.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/file.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index a490f45df4db..df695f52bb9d 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -697,14 +697,14 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	if (!IS_ERR(l_ctx)) {
 		status = nfs_iocounter_wait(l_ctx);
 		nfs_put_lock_context(l_ctx);
-		if (status < 0)
+		/*  NOTE: special case
+		 * 	If we're signalled while cleaning up locks on process exit, we
+		 * 	still need to complete the unlock.
+		 */
+		if (status < 0 && !(fl->fl_flags & FL_CLOSE))
 			return status;
 	}
 
-	/* NOTE: special case
-	 * 	If we're signalled while cleaning up locks on process exit, we
-	 * 	still need to complete the unlock.
-	 */
 	/*
 	 * Use local locking if mounted with "-onolock" or with appropriate
 	 * "-olocal_lock="
-- 
2.9.3

