Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755938Ab2KZURH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 15:17:07 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 17/28] NFSv4.1: Allow the server to recall all but one slot
Date: Mon, 26 Nov 2012 15:16:34 -0500
Message-Id: <1353961005-63874-18-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
References: <1353961005-63874-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-16-git-send-email-Trond.Myklebust@netapp.com>
 <1353961005-63874-17-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server wants to leave us with only one slot, or it wants
to "shrink" our slot table to something larger than we have now,
then so be it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ed0b446..a0546ec 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -567,11 +567,6 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 
 	fc_tbl = &cps->clp->cl_session->fc_slot_table;
 
-	status = htonl(NFS4ERR_BAD_HIGH_SLOT);
-	if (args->crsa_target_highest_slotid >= fc_tbl->max_slots ||
-	    args->crsa_target_highest_slotid < 1)
-		goto out;
-
 	status = htonl(NFS4_OK);
 
 	nfs41_set_target_slotid(fc_tbl, args->crsa_target_highest_slotid);
-- 
1.7.11.7

