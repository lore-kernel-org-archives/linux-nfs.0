Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:35955 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135AbbGHSZW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:25:22 -0400
Received: by lagc2 with SMTP id c2so228193506lag.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:25:20 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/5] NFSv4.1: Handle SEQ4_STATUS_RECALLABLE_STATE_REVOKED status bit correctly
Date: Wed,  8 Jul 2015 20:25:10 +0200
Message-Id: <1436379913-3338-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436379913-3338-1-git-send-email-trond.myklebust@primarydata.com>
References: <1436379913-3338-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Try to handle this for now by invalidating all outstanding layouts for this
server and then testing all the open+lock+delegation stateids.
At some later stage, we may want to optimise by separating out the testing of
delegation stateids only, and adding testing of layout stateids.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4state.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index f76916169b5f..469452996154 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2207,8 +2207,10 @@ static void nfs41_handle_some_state_revoked(struct nfs_client *clp)
 
 static void nfs41_handle_recallable_state_revoked(struct nfs_client *clp)
 {
-	/* This will need to handle layouts too */
-	nfs_expire_all_delegations(clp);
+	/* FIXME: For now, we destroy all layouts. */
+	pnfs_destroy_all_layouts(clp);
+	/* FIXME: For now, we test all delegations+open state+locks. */
+	nfs41_handle_some_state_revoked(clp);
 	dprintk("%s: Recallable state revoked on server %s!\n", __func__,
 			clp->cl_hostname);
 }
-- 
2.4.3

