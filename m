From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] nfs4: remove BKL from nfs_callback_up and nfs_callback_down
Date: Wed, 11 Jun 2008 10:03:10 -0400
Message-ID: <1213192992-7635-2-git-send-email-jlayton@redhat.com>
References: <1213192992-7635-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	linux-kernel@vger.kernel.org
To: trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50944 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbYFKODU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 10:03:20 -0400
In-Reply-To: <1213192992-7635-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs_callback_mutex is sufficient protection.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index c1e7c83..9e713d2 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -105,7 +105,6 @@ int nfs_callback_up(void)
 	struct svc_rqst *rqstp;
 	int ret = 0;
 
-	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
 	if (nfs_callback_info.users++ || nfs_callback_info.task != NULL)
 		goto out;
@@ -149,7 +148,6 @@ out:
 	if (serv)
 		svc_destroy(serv);
 	mutex_unlock(&nfs_callback_mutex);
-	unlock_kernel();
 	return ret;
 out_err:
 	dprintk("Couldn't create callback socket or server thread; err = %d\n",
@@ -163,13 +161,11 @@ out_err:
  */
 void nfs_callback_down(void)
 {
-	lock_kernel();
 	mutex_lock(&nfs_callback_mutex);
 	nfs_callback_info.users--;
 	if (nfs_callback_info.users == 0 && nfs_callback_info.task != NULL)
 		kthread_stop(nfs_callback_info.task);
 	mutex_unlock(&nfs_callback_mutex);
-	unlock_kernel();
 }
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
-- 
1.5.3.6

