Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32999 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbcLAWHz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:07:55 -0500
Received: by mail-io0-f195.google.com with SMTP id j92so3875933ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:07:55 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Fred Isaman <fred.isaman@gmail.com>
Subject: [PATCH] NFSv4.1: Fix regression in callback retry handling
Date: Thu,  1 Dec 2016 17:07:53 -0500
Message-Id: <20161201220753.12854-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <fred.isaman@gmail.com>

When initializing a freshly created slot for the calllback channel,
the seq_nr needs to be 0, not 1.  Otherwise validate_seqid
and nfs4_slot_wait_on_seqid get confused and believe that the
mpty slot corresponds to a previously sent reply.

Signed-off-by: Fred Isaman <fred.isaman@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4session.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index a61350f75c74..769b85655c4b 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -169,7 +169,7 @@ bool nfs4_try_to_lock_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 struct nfs4_slot *nfs4_lookup_slot(struct nfs4_slot_table *tbl, u32 slotid)
 {
 	if (slotid <= tbl->max_slotid)
-		return nfs4_find_or_create_slot(tbl, slotid, 1, GFP_NOWAIT);
+		return nfs4_find_or_create_slot(tbl, slotid, 0, GFP_NOWAIT);
 	return ERR_PTR(-E2BIG);
 }
 
-- 
2.9.3

