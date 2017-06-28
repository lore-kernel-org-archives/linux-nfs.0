Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34491 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752633AbdF1C10 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 22:27:26 -0400
Received: by mail-it0-f67.google.com with SMTP id o202so2072406itc.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Jun 2017 19:27:20 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: nfs4_callback_free_slot() cannot call nfs4_slot_tbl_drain_complete()
Date: Tue, 27 Jun 2017 22:27:16 -0400
Message-Id: <20170628022716.16785-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current code works only for the case where we have exactly one slot,
which is no longer true.
nfs4_free_slot() will automatically declare the callback channel to be
drained when all slots have been returned.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_xdr.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c14758e08d73..390ac9c39c59 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -753,7 +753,6 @@ static void nfs4_callback_free_slot(struct nfs4_session *session,
 	 * A single slot, so highest used slotid is either 0 or -1
 	 */
 	nfs4_free_slot(tbl, slot);
-	nfs4_slot_tbl_drain_complete(tbl);
 	spin_unlock(&tbl->slot_tbl_lock);
 }
 
-- 
2.9.4

