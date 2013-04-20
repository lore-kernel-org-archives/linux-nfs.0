Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:5858 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952Ab3DTFlt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Apr 2013 01:41:49 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Ensure the LOCK call cannot use the delegation stateid
Date: Sat, 20 Apr 2013 01:41:46 -0400
Message-Id: <1366436506-25033-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1366436506-25033-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1366436506-25033-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Defensive patch to ensure that we copy the state->open_stateid, which
can never be set to the delegation stateid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3984936..ed01a66 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4793,7 +4793,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 		if (nfs_wait_on_sequence(data->arg.open_seqid, task) != 0) {
 			goto out_release_lock_seqid;
 		}
-		data->arg.open_stateid = &state->stateid;
+		data->arg.open_stateid = &state->open_stateid;
 		data->arg.new_lock_owner = 1;
 		data->res.open_seqid = data->arg.open_seqid;
 	} else
-- 
1.8.1.4

