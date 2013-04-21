Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:65120 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238Ab3DUWOO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Apr 2013 18:14:14 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Marc Eshel <eshel@us.ibm.com>, Chuck Lever <chuck.lever@oracle.com>,
        Malahal Naineni <naineni@us.ibm.com>, Manoj Naik <mnaik@us.ibm.com>,
        Shuzheng Liu <liuszmi@us.ibm.com>, Steve Dickson <SteveD@redhat.com>,
        Tomer Perry <TOMP@il.ibm.com>
Subject: [PATCH] LOCKD: Ensure that nlmclnt_block resets block->b_status after a server reboot
Date: Sun, 21 Apr 2013 18:14:09 -0400
Message-Id: <1366582449-25569-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After a server reboot, the reclaimer thread will recover all the existing
locks. For locks that are blocked, however, it will change the value
of block->b_status to nlm_lck_denied_grace_period in order to signal that
they need to wake up and resend the original blocking lock request.

Due to a bug, however, the block->b_status never gets reset after the
blocked locks have been woken up, and so the process goes into an
infinite loop of resends until the blocked lock is satisfied.

Reported-by: Marc Eshel <eshel@us.ibm.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/lockd/clntlock.c | 3 +++
 fs/lockd/clntproc.c | 3 ---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 0796c45..01bfe76 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -144,6 +144,9 @@ int nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout)
 			timeout);
 	if (ret < 0)
 		return -ERESTARTSYS;
+	/* Reset the lock status after a server reboot so we resend */
+	if (block->b_status == nlm_lck_denied_grace_period)
+		block->b_status = nlm_lck_blocked;
 	req->a_res.status = block->b_status;
 	return 0;
 }
diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 7e529c3..9760ecb 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -550,9 +550,6 @@ again:
 		status = nlmclnt_block(block, req, NLMCLNT_POLL_TIMEOUT);
 		if (status < 0)
 			break;
-		/* Resend the blocking lock request after a server reboot */
-		if (resp->status ==  nlm_lck_denied_grace_period)
-			continue;
 		if (resp->status != nlm_lck_blocked)
 			break;
 	}
-- 
1.8.1.4

