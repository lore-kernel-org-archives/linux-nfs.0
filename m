Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53780 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965224AbcIPU1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 16 Sep 2016 16:27:14 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH v3 3/9] nfs: use safe, interruptible sleeps when waiting to retry LOCK
Date: Fri, 16 Sep 2016 16:27:05 -0400
Message-Id: <1474057631-31209-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We actually want to use TASK_INTERRUPTIBLE sleeps when we're in the
process of polling for a NFSv4 lock. If there is a signal pending when
the task wakes up, then we'll be returning an error anyway. So, we might
as well wake up immediately for non-fatal signals as well. That allows
us to return to userland more quickly in that case, but won't change the
error that userland sees.

Also, there is no need to use the *_unsafe sleep variants here, as no
vfs-layer locks should be held at this point.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a0f25185c78c..253b0c09fb02 100644
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

