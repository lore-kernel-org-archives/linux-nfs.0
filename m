Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:23472 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946103AbbEOPzD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 11:55:03 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] fixing infinite OPEN loop in 4.0 stateid recovery
Date: Fri, 15 May 2015 11:45:31 -0400
Message-ID: <1431704731-1269-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Problem: When an operation like WRITE receives a BAD_STATEID, even though
recovery code clears the RECLAIM_NOGRACE recovery flag before recovering
the open state, because of clearing delegation state for the associated
inode, nfs_inode_find_state_and_recover() gets called and it makes the
same state with RECLAIM_NOGRACE flag again. As a results, when we restart
looking over the open states, we end up in the infinite loop instead of
breaking out in the next test of state flags.

Solution: unset the RECLAIM_NOGRACE set because of
calling of nfs_inode_find_state_and_recover() after returning from calling
recover_open() function.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2782cfc..e99e1f0 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1482,6 +1482,8 @@ restart:
 					spin_unlock(&state->state_lock);
 				}
 				nfs4_put_open_state(state);
+				test_and_clear_bit(NFS4CLNT_RECLAIM_NOGRACE,
+					&state->flags);
 				spin_lock(&sp->so_lock);
 				goto restart;
 			}
-- 
1.8.3.1

