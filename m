Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45502 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030772Ab2CFOyS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 09:54:18 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
        stable@vger.kernel.org
Subject: [PATCH 3/3] NFSv4.1 do not clear NFS_DELEAGED_STATE until stateid is tested
Date: Tue,  6 Mar 2012 09:54:12 -0500
Message-Id: <1331045652-3086-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs41_open_expired() will test the delegation stateid based on
NFS_DELEGATED_STATE being set. If the stateid is bad, nfs4_open_recover
will clear the NFS_DELEGATED_STATE bit recovering the delegation.

Signed-off-by: Andy Adamson <andros@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7bd9822..5c92185 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1097,7 +1097,7 @@ void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4
 {
 	struct nfs_client *clp = server->nfs_client;
 
-	if (test_and_clear_bit(NFS_DELEGATED_STATE, &state->flags))
+	if (test_bit(NFS_DELEGATED_STATE, &state->flags))
 		nfs_async_inode_return_delegation(state->inode, &state->stateid);
 	nfs4_state_mark_reclaim_nograce(clp, state);
 	nfs4_schedule_state_manager(clp);
-- 
1.7.6.4

