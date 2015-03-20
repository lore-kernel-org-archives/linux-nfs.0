Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:35482 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbbCTTPX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Mar 2015 15:15:23 -0400
Received: by yhim52 with SMTP id m52so15878328yhi.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2015 12:15:22 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: Anna.Schumaker@netapp.com, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: fix high load average due to callback thread sleeping
Date: Fri, 20 Mar 2015 15:15:14 -0400
Message-Id: <1426878914-15088-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck pointed out a problem that crept in with commit 6ffa30d3f734 (nfs:
don't call blocking operations while !TASK_RUNNING). Linux counts tasks
in uninterruptible sleep against the load average, so this caused the
system's load average to be pinned at at least 1 when there was a
NFSv4.1+ mount active.

Not a huge problem, but it's probably worth fixing before we get too
many complaints about it. This patch converts the code back to use
TASK_INTERRUPTIBLE sleep, simply has it flush any signals on each loop
iteration. In practice no one should really be signalling this thread at
all, so I think this is reasonably safe.

With this change, there's also no need to game the hung task watchdog so
we can also convert the schedule_timeout call back to a normal schedule.

Cc: <stable@vger.kernel.org>
Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/callback.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 351be9205bf8..8d129bb7355a 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -128,7 +128,7 @@ nfs41_callback_svc(void *vrqstp)
 		if (try_to_freeze())
 			continue;
 
-		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait(&serv->sv_cb_waitq, &wq, TASK_INTERRUPTIBLE);
 		spin_lock_bh(&serv->sv_cb_lock);
 		if (!list_empty(&serv->sv_cb_list)) {
 			req = list_first_entry(&serv->sv_cb_list,
@@ -142,10 +142,10 @@ nfs41_callback_svc(void *vrqstp)
 				error);
 		} else {
 			spin_unlock_bh(&serv->sv_cb_lock);
-			/* schedule_timeout to game the hung task watchdog */
-			schedule_timeout(60 * HZ);
+			schedule();
 			finish_wait(&serv->sv_cb_waitq, &wq);
 		}
+		flush_signals(current);
 	}
 	return 0;
 }
-- 
2.1.0

