Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:65293 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934858Ab3FSUlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Jun 2013 16:41:11 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4.1 end back channel session draining
Date: Wed, 19 Jun 2013 16:39:44 -0400
Message-Id: <1371674384-2421-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5244ffd..e20d86d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -246,6 +246,8 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 		nfs41_wake_slot_table(tbl);
 		spin_unlock(&tbl->slot_tbl_lock);
 	}
+	tbl = &ses->bc_slot_table;
+	test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
 }
 
 /*
-- 
1.7.11.7

