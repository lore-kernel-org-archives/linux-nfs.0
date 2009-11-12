From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [PATCH] Fix bug at nlmclnt_lock()
Date: Thu, 12 Nov 2009 17:40:19 +0800
Message-ID: <4AFBD803.9080204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62259 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751736AbZKLJjA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2009 04:39:00 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing NLM, i found a bug.

Test process:
step1: client open file.
step2: keep network partition.
step3: client call fcntl with SETLKW to get lock.
       (it will timeout and return -1)
step4: recover network.
step5: client try to get lock again, but it always fail.

At nlmclnt_lock(), resp->status is set to "nlm_lck_blocked" 
by default before call nlmclnt_call().

So at step3, when nlmclnt_call return error because network partition,
client will think the nlm_lck_blocked was replied from server, and it
just send cancel request not unlock.

Signed-off-by: mijinlong@cn.fujitsu.com
---
 fs/lockd/clntproc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index c81249f..a631582 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -535,7 +535,7 @@ again:
 	 * Initialise resp->status to a valid non-zero value,
 	 * since 0 == nlm_lck_granted
 	 */
-	resp->status = nlm_lck_blocked;
+	resp->status = nlm_lck_denied_nolocks;
 	for(;;) {
 		/* Reboot protection */
 		fl->fl_u.nfs_fl.state = host->h_state;
-- 
1.6.2

thanks,
Mi Jinlong

