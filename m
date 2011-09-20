Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:36249 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759Ab1ITDS4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Sep 2011 23:18:56 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 3/3] SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
Date: Mon, 19 Sep 2011 23:18:48 -0400
Message-Id: <1316488728-24912-4-git-send-email-rees@umich.edu>
In-Reply-To: <1316488728-24912-1-git-send-email-rees@umich.edu>
References: <1316488728-24912-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@tonian.com>

[whitespace]
Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/pnfs.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5ac7a78..e38b91a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -38,7 +38,7 @@
 /* Locking:
  *
  * pnfs_spinlock:
- *      protects pnfs_modules_tbl, pnfsiod_workqueue and pnfsiod_users.
+ *      protects pnfs_modules_tbl, pnfsiod_workqueue.
  */
 static DEFINE_SPINLOCK(pnfs_spinlock);
 
@@ -48,7 +48,7 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
 static LIST_HEAD(pnfs_modules_tbl);
 
 static struct workqueue_struct *pnfsiod_workqueue;
-static int pnfsiod_users = 0;
+static atomic_t pnfsiod_users;
 
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
@@ -1488,18 +1488,22 @@ out:
 int pnfsiod_start(void)
 {
 	struct workqueue_struct *wq;
-	dprintk("RPC:       creating workqueue pnfsiod\n");
-	wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
-	if (wq == NULL)
-		return -ENOMEM;
-	spin_lock(&pnfs_spinlock);
-	pnfsiod_users++;
+
+	dprintk("NFS:       creating workqueue pnfsiod\n");
+	atomic_inc(&pnfsiod_users);
 	if (pnfsiod_workqueue == NULL) {
-		pnfsiod_workqueue = wq;
-	} else {
-		destroy_workqueue(wq);
+		wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
+		if (wq == NULL) {
+			pnfsiod_stop();
+			return -ENOMEM;
+		}
+		spin_lock(&pnfs_spinlock);
+		if (pnfsiod_workqueue == NULL)
+			pnfsiod_workqueue = wq;
+		else
+			destroy_workqueue(wq);
+		spin_unlock(&pnfs_spinlock);
 	}
-	spin_unlock(&pnfs_spinlock);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(pnfsiod_start);
@@ -1511,13 +1515,11 @@ void pnfsiod_stop(void)
 {
 	struct workqueue_struct *wq = NULL;
 
-	spin_lock(&pnfs_spinlock);
-	pnfsiod_users--;
-	if (pnfsiod_users == 0) {
+	if (atomic_dec_and_lock(&pnfsiod_users, &pnfs_spinlock)) {
 		wq = pnfsiod_workqueue;
 		pnfsiod_workqueue = NULL;
+		spin_unlock(&pnfs_spinlock);
 	}
-	spin_unlock(&pnfs_spinlock);
 	if (wq)
 		destroy_workqueue(wq);
 }
-- 
1.7.4.1

