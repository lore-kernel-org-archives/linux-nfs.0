Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:24148 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754256AbdC3OAz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 10:00:55 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFSv4.1 fix infinite loop on IO BAD_STATEID error
Date: Thu, 30 Mar 2017 10:00:51 -0400
Message-ID: <20170330140051.61886-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 02bfab0414d7 "NFSv4.1: Don't recheck delegations that
have already been checked" introduced a regression where when a
client received BAD_STATEID error it would not send any TEST_STATEID
and instead go into an infinite loop of resending the IO that caused
the BAD_STATEID.

Fixes: 02bfab0414d7 ("NFSv4.1: Don't recheck delegations that have already been checked")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dfa46e4..fb6d981 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2460,6 +2460,7 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	}
 
 	if (!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags)) {
+		nfs_finish_clear_delegation_stateid(state, &stateid);
 		rcu_read_unlock();
 		return;
 	}
-- 
1.8.3.1

