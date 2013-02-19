Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9316 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238Ab3BSRgZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Feb 2013 12:36:25 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NLM: Ensure that we resend all pending blocking locks after a reclaim
Date: Tue, 19 Feb 2013 12:36:09 -0500
Message-Id: <1361295369-11804-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, nlmclnt_lock will break out of the for(;;) loop when
the reclaimer wakes up the blocking lock thread by setting
nlm_lck_denied_grace_period. This causes the lock request to fail
with an ENOLCK error.
The intention was always to ensure that we resend the lock request
after the grace period has expired.

Reported-by: Wangyuan Zhang <Wangyuan.Zhang@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/lockd/clntproc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 54f9e6c..52e5120 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -550,6 +550,9 @@ again:
 		status = nlmclnt_block(block, req, NLMCLNT_POLL_TIMEOUT);
 		if (status < 0)
 			break;
+		/* Resend the blocking lock request after a server reboot */
+		if (resp->status ==  nlm_lck_denied_grace_period)
+			continue;
 		if (resp->status != nlm_lck_blocked)
 			break;
 	}
-- 
1.8.1.2

