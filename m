Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:56530 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab2KVSnn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Nov 2012 13:43:43 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/20] NFSv4.1: Allow the server to recall all but one slot
Date: Wed, 21 Nov 2012 17:43:15 -0500
Message-Id: <1353537799-60488-17-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1353537799-60488-16-git-send-email-Trond.Myklebust@netapp.com>
References: <1353537799-60488-1-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-2-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-3-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-4-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-5-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-6-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-7-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-8-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-9-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-10-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-11-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-12-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-13-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-14-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-15-git-send-email-Trond.Myklebust@netapp.com>
 <1353537799-60488-16-git-send-email-Trond.Myklebust@netapp.com>
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

