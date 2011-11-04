Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63082 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab1KDUs1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 16:48:27 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 1/4] NFSv4.1: fix backchannel slotid off-by-one bug
Date: Fri,  4 Nov 2011 16:47:46 -0400
Message-Id: <1320439669-3411-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Cc:stable@kernel.org
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..54cea8a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -339,7 +339,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s enter. slotid %d seqid %d\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
+	if (args->csa_slotid >= NFS41_BC_MAX_CALLBACKS)
 		return htonl(NFS4ERR_BADSLOT);
 
 	slot = tbl->slots + args->csa_slotid;
-- 
1.7.6.4

