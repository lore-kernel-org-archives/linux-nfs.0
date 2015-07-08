Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34615 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758312AbbGHSZ0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jul 2015 14:25:26 -0400
Received: by lbnk3 with SMTP id k3so61427538lbn.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2015 11:25:24 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] NFSv4.1: nfs41_sequence_done should handle sequence flag errors
Date: Wed,  8 Jul 2015 20:25:12 +0200
Message-Id: <1436379913-3338-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1436379913-3338-3-git-send-email-trond.myklebust@primarydata.com>
References: <1436379913-3338-1-git-send-email-trond.myklebust@primarydata.com>
 <1436379913-3338-2-git-send-email-trond.myklebust@primarydata.com>
 <1436379913-3338-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of just kicking off lease recovery, we should look into the
sequence flag errors and handle them.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6f228b5af819..1607b41a6d84 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -616,8 +616,7 @@ int nfs41_sequence_done(struct rpc_task *task, struct nfs4_sequence_res *res)
 		clp = session->clp;
 		do_renew_lease(clp, res->sr_timestamp);
 		/* Check sequence flags */
-		if (res->sr_status_flags != 0)
-			nfs4_schedule_lease_recovery(clp);
+		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
 		nfs41_update_target_slotid(slot->table, slot, res);
 		break;
 	case 1:
-- 
2.4.3

