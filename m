Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755913Ab2KZUQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:16:59 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/28] NFSv4.1: clean up nfs4_recall_slot to use nfs4_alloc_slots
Date: Mon, 26 Nov 2012 15:16:23 -0500
Message-Id: <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   | 2 ++
 fs/nfs/nfs4proc.c  | 2 +-
 fs/nfs/nfs4state.c | 3 +--
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a525fde..36880b9 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -258,6 +258,8 @@ extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 extern int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data,
 				  bool sync);
 
+extern struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags);
+
 static inline bool
 is_ds_only_client(struct nfs_client *clp)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0402ebb..5e5cc5a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5656,7 +5656,7 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	return status;
 }
 
-static struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags)
+struct nfs4_slot *nfs4_alloc_slots(u32 max_slots, gfp_t gfp_flags)
 {
 	return kmalloc_array(max_slots, sizeof(struct nfs4_slot), gfp_flags);
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f3d1bc4..96fcbb9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2033,8 +2033,7 @@ static int nfs4_recall_slot(struct nfs_client *clp)
 		return 0;
 	nfs4_begin_drain_session(clp);
 	fc_tbl = &clp->cl_session->fc_slot_table;
-	new = kmalloc(fc_tbl->target_max_slots * sizeof(struct nfs4_slot),
-		      GFP_NOFS);
+	new = nfs4_alloc_slots(fc_tbl->target_max_slots, GFP_NOFS);
         if (!new)
 		return -ENOMEM;
 
-- 
1.7.11.7

