Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:39138 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933150AbdC3RyJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 13:54:09 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFSv4.1 fix infinite loop on IO BAD_STATEID error
Date: Thu, 30 Mar 2017 13:49:03 -0400
Message-ID: <20170330174903.63175-1-kolga@netapp.com>
In-Reply-To: <367ad3d3-8aec-baeb-04a6-06348c2eb5b7@Netapp.com>
References: <367ad3d3-8aec-baeb-04a6-06348c2eb5b7@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 63d63cbf5e03 "NFSv4.1: Don't recheck delegations that
have already been checked" introduced a regression where when a
client received BAD_STATEID error it would not send any TEST_STATEID
and instead go into an infinite loop of resending the IO that caused
the BAD_STATEID.

Fixes: 63d63cbf5e03 ("NFSv4.1: Don't recheck delegations that have already been checked")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dfa46e4..bd1e4f6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2453,17 +2453,14 @@ static void nfs41_check_delegation_stateid(struct nfs4_state *state)
 	}
 
 	nfs4_stateid_copy(&stateid, &delegation->stateid);
-	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags)) {
+	if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) ||
+		!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED,
+			&delegation->flags)) {
 		rcu_read_unlock();
 		nfs_finish_clear_delegation_stateid(state, &stateid);
 		return;
 	}
 
-	if (!test_and_clear_bit(NFS_DELEGATION_TEST_EXPIRED, &delegation->flags)) {
-		rcu_read_unlock();
-		return;
-	}
-
 	cred = get_rpccred(delegation->cred);
 	rcu_read_unlock();
 	status = nfs41_test_and_free_expired_stateid(server, &stateid, cred);
-- 
1.8.3.1

