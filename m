Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10920 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133Ab2BNVYL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 16:24:11 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv4: fix nfs4_find_slot() not found ret value
Date: Tue, 14 Feb 2012 16:23:57 -0500
Message-Id: <1329254637-1952-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The caller of nfs4_find_slot() expects NFS4_MAX_SLOT_TABLE when no slot is
available (also mentioned in the comment header for nfs4_find_slot()).

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
This fixes an OOPS that is easy to reproduce:

 dd if=/dev/zero of=./zerofile bs=10024 count=1

nfs4_find_slot() returns 2^32-1 which != NFS4_MAX_SLOT_TABLE, so it's used
as a valid slotid.

Note that NFS4_NO_SLOT is still used for nfs4_slot_table::highest_used_slotid

 fs/nfs/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index da985c3..b977fea 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -520,7 +520,7 @@ static u32
 nfs4_find_slot(struct nfs4_slot_table *tbl)
 {
 	u32 slotid;
-	u32 ret_id = NFS4_NO_SLOT;
+	u32 ret_id = NFS4_MAX_SLOT_TABLE;
 
 	dprintk("--> %s used_slots=%04lx highest_used=%u max_slots=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
@@ -533,7 +533,7 @@ nfs4_find_slot(struct nfs4_slot_table *tbl)
 		tbl->highest_used_slotid = slotid;
 	ret_id = slotid;
 out:
-	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
+	dprintk("<-- %s used_slots=%04lx highest_used=%u slotid=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid, ret_id);
 	return ret_id;
 }
-- 
1.7.4.4

