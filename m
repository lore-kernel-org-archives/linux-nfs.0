Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61376 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756337Ab3DWS6I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Apr 2013 14:58:08 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] NFSv4.1: Don't do a delegated open for NFS4_OPEN_CLAIM_DELEG_CUR_FH modes
Date: Tue, 23 Apr 2013 14:58:02 -0400
Message-Id: <1366743483-59247-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1366743483-59247-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1366743483-59247-1-git-send-email-Trond.Myklebust@netapp.com>
 <1366743483-59247-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're in a delegation recall situation, we can't do a delegated open.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a411a53..ea50807 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1543,6 +1543,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		rcu_read_lock();
 		delegation = rcu_dereference(NFS_I(data->state->inode)->delegation);
 		if (data->o_arg.claim != NFS4_OPEN_CLAIM_DELEGATE_CUR &&
+		    data->o_arg.claim != NFS4_OPEN_CLAIM_DELEG_CUR_FH &&
 		    can_open_delegated(delegation, data->o_arg.fmode))
 			goto unlock_no_action;
 		rcu_read_unlock();
-- 
1.8.1.4

