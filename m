Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:8957 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932803Ab1FBKpS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2011 06:45:18 -0400
Received: from [10.30.3.27] ([10.30.3.27])
	(authenticated bits=0)
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p52Al8TQ010591
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Jun 2011 14:47:09 +0400 (MSD)
Message-ID: <4DE769BB.7020105@parallels.com>
Date: Thu, 02 Jun 2011 14:45:15 +0400
From: Vasily Averin <vvs@parallels.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCHv2 2/2] lockd: properly convert be32 values in debug messages
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

lockd: server returns status 50331648
it's quite hard to understand that number in this message is 3 in big endian

Signed-off-by: Vasily Averin <vvs@sw.ru>
---
 fs/lockd/clntproc.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index adb45ec..d5619ca 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -302,7 +302,8 @@ nlmclnt_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 proc)
 				/* We appear to be out of the grace period */
 				wake_up_all(&host->h_gracewait);
 			}
-			dprintk("lockd: server returns status %d\n", resp->status);
+			dprintk("lockd: server returns status %d\n",
+				be32_to_cpu(resp->status));
 			return 0;	/* Okay, call complete */
 		}
 
@@ -690,7 +691,8 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 		goto out;
 
 	if (resp->status != nlm_lck_denied_nolocks)
-		printk("lockd: unexpected unlock status: %d\n", resp->status);
+		printk("lockd: unexpected unlock status: %d\n",
+			be32_to_cpu(resp->status));
 	/* What to do now? I'm out of my depth... */
 	status = -ENOLCK;
 out:
@@ -837,6 +839,7 @@ nlm_stat_to_errno(__be32 status)
 		return -ENOLCK;
 #endif
 	}
-	printk(KERN_NOTICE "lockd: unexpected server status %d\n", status);
+	printk(KERN_NOTICE "lockd: unexpected server status %d\n",
+		 be32_to_cpu(status));
 	return -ENOLCK;
 }
-- 
1.7.4.1

