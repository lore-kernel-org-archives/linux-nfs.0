Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44810 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753269AbcIISry (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 14:47:54 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/10] nfs: use safe, interruptible sleeps when waiting to retry LOCK
Date: Fri,  9 Sep 2016 14:47:45 -0400
Message-Id: <1473446870-1831-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
References: <1473446870-1831-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We actually want to use TASK_INTERRUPTIBLE sleeps when we're in the
process of polling for a NFSv4 lock. If there is a signal pending when
the task wakes up, then we'll be returning an error anyway. So, we might
as well wake up immediately for non-fatal signals as well. That allows
us to return to userland more quickly in that case, but won't change the
error that userland sees.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e3bf95369daf..90e8ded0ef82 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5537,7 +5537,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 static unsigned long
 nfs4_set_lock_task_retry(unsigned long timeout)
 {
-	freezable_schedule_timeout_killable_unsafe(timeout);
+	freezable_schedule_timeout_interruptible(timeout);
 	timeout <<= 1;
 	if (timeout > NFS4_LOCK_MAXTIMEOUT)
 		return NFS4_LOCK_MAXTIMEOUT;
-- 
2.7.4

