Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34790 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752952Ab1KIS7A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Nov 2011 13:59:00 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 3/7] NFSv4.1: change nfs4_free_slot parameters for dynamic slots
Date: Wed,  9 Nov 2011 13:58:22 -0500
Message-Id: <1320865106-1791-3-git-send-email-andros@netapp.com>
In-Reply-To: <1320865106-1791-1-git-send-email-andros@netapp.com>
References: <1320865106-1791-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ef098a8..2638291 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -361,9 +361,8 @@ static void renew_lease(const struct nfs_server *server, unsigned long timestamp
  * Must be called while holding tbl->slot_tbl_lock
  */
 static void
-nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *free_slot)
+nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 {
-	int free_slotid = free_slot - tbl->slots;
 	int slotid = free_slotid;
 
 	BUG_ON(slotid < 0 || slotid >= NFS4_MAX_SLOT_TABLE);
@@ -428,7 +427,7 @@ static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 	}
 
 	spin_lock(&tbl->slot_tbl_lock);
-	nfs4_free_slot(tbl, res->sr_slot);
+	nfs4_free_slot(tbl, res->sr_slot - tbl->slots);
 	nfs4_check_drain_fc_complete(res->sr_session);
 	spin_unlock(&tbl->slot_tbl_lock);
 	res->sr_slot = NULL;
-- 
1.7.6.4

