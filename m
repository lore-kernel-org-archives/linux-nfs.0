Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45862 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbdG1QjA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 12:39:00 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Fix a race where CB_NOTIFY_LOCK fails to wake a waiter
Date: Fri, 28 Jul 2017 12:33:54 -0400
Message-Id: <14a33c6c2f7502313c7c46a0b1fd977b0b9ccad2.1501258923.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_retry_setlk() sets the task's state to TASK_INTERRUPTIBLE within the
same region protected by the wait_queue's lock after checking for a
notification from CB_NOTIFY_LOCK callback.  However, after releasing that
lock, a wakeup for that task may race in before the call to
freezable_schedule_timeout_interruptible() and set TASK_WAKING, then
freezable_schedule_timeout_interruptible() will set the state back to
TASK_INTERRUPTIBLE before the task will sleep.  The result is that the task
will sleep for the entire duration of the timeout.

Since we've already set TASK_INTERRUPTIBLE in the locked section, just use
freezable_schedule_timout() instead.

Fixes: a1d617d8f134 ("nfs: allow blocking locks to be awoken by lock callbacks")
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dbfa18900e25..f5a7faac39a7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6441,7 +6441,7 @@ nfs4_retry_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
 		set_current_state(TASK_INTERRUPTIBLE);
 		spin_unlock_irqrestore(&q->lock, flags);
 
-		freezable_schedule_timeout_interruptible(NFS4_LOCK_MAXTIMEOUT);
+		freezable_schedule_timeout(NFS4_LOCK_MAXTIMEOUT);
 	}
 
 	finish_wait(q, &wait);
-- 
2.9.3

