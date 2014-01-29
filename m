Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:44638 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbaA2Rg0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jan 2014 12:36:26 -0500
Received: by mail-ie0-f176.google.com with SMTP id tp5so2304257ieb.7
        for <linux-nfs@vger.kernel.org>; Wed, 29 Jan 2014 09:36:25 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFSv4: Fix a slot leak in nfs40_sequence_done
Date: Wed, 29 Jan 2014 12:36:20 -0500
Message-Id: <1391016982-10562-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The check for whether or not we sent an RPC call in nfs40_sequence_done
is insufficient to decide whether or not we are holding a session slot,
and thus should not be used to decide when to free that slot.

This patch replaces the RPC_WAS_SENT() test with the correct test for
whether or not slot == NULL.

Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@vger.kernel.org # 3.12+
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ae00c3ed733f..493e9cce1f11 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -539,7 +539,7 @@ static int nfs40_sequence_done(struct rpc_task *task,
 	struct nfs4_slot *slot = res->sr_slot;
 	struct nfs4_slot_table *tbl;
 
-	if (!RPC_WAS_SENT(task))
+	if (slot == NULL)
 		goto out;
 
 	tbl = slot->table;
-- 
1.8.5.3

