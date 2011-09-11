Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:62036 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114Ab1IKPbr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 11:31:47 -0400
Received: by pzk37 with SMTP id 37so5445781pzk.1
        for <linux-nfs@vger.kernel.org>; Sun, 11 Sep 2011 08:31:47 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: Jim Rees <rees@umich.edu>, Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 1/2] SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
Date: Sun, 11 Sep 2011 08:31:40 -0700
Message-Id: <1315755100-31204-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E6CD076.6050607@tonian.com>
References: <4E6CD076.6050607@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/pnfs.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5ac7a78..0bed5fc 100644
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
1.7.6

