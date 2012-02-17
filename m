Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2576 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010Ab2BQSFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Feb 2012 13:05:47 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/2] NFSv4.1 set highest_used_slotid to NFS4_NO_SLOT
Date: Fri, 17 Feb 2012 13:05:23 -0500
Message-Id: <1329501923-3999-3-git-send-email-andros@netapp.com>
In-Reply-To: <1329501923-3999-1-git-send-email-andros@netapp.com>
References: <1329501923-3999-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4e37818..c1111a3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -212,7 +212,7 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 static int nfs4_wait_on_slot_tbl(struct nfs4_slot_table *tbl)
 {
 	spin_lock(&tbl->slot_tbl_lock);
-	if (tbl->highest_used_slotid != -1) {
+	if (tbl->highest_used_slotid != NFS4_NO_SLOT) {
 		INIT_COMPLETION(tbl->complete);
 		spin_unlock(&tbl->slot_tbl_lock);
 		return wait_for_completion_interruptible(&tbl->complete);
-- 
1.7.6.4

