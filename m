Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:39504 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172Ab1IKRRw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2011 13:17:52 -0400
Date: Sun, 11 Sep 2011 13:17:49 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <benny@tonian.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@tonian.com>
Subject: Re: [PATCH 1/2] SQUASHME: pnfs: simplify and clean up pnfsiod
 workqueue
Message-ID: <20110911171749.GA5195@merit.edu>
References: <4E6CD076.6050607@tonian.com>
 <1315755100-31204-1-git-send-email-benny@tonian.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1315755100-31204-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Jim Rees <rees@umich.edu>
Date: Sun, 11 Sep 2011 13:11:15 -0400
Subject: [PATCH] SQUASHME: pnfs: whitespace

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/pnfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0ef4361..e5e11b4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1488,13 +1488,13 @@ out:
 int pnfsiod_start(void)
 {
 	struct workqueue_struct *wq;
-	
+
 	dprintk("NFS:       creating workqueue pnfsiod\n");
 	atomic_inc(&pnfsiod_users);
 	if (pnfsiod_workqueue == NULL) {
 		wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
 		if (wq == NULL) {
-			pnfsiod_stop();	
+			pnfsiod_stop();
 			return -ENOMEM;
 		}
 		spin_lock(&pnfs_spinlock);
-- 
1.7.4.1
