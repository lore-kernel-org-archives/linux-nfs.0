Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285Ab1KDO3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 10:29:19 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH (resend) Version 2 3/3] NFSv4.1: fix backchennel bug
Date: Tue, 18 Oct 2011 02:39:39 -0400
Message-Id: <1318919979-14606-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Slotid's start from 0 which means we check against
NFS41_BC_MAX_CALLBACKS - 1.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 98ff5fc..12bd9d0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -339,7 +339,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s enter. slotid %d seqid %d\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
+	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS - 1)
 		return htonl(NFS4ERR_BADSLOT);
 
 	slot = nfs4_lookup_slot_locked(tbl, args->csa_slotid);
-- 
1.7.6.4

