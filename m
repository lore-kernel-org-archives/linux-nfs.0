Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:47977 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753054Ab2EYWDm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 May 2012 18:03:42 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFSv4: When purging the lease, we must clear NFS4CLNT_LEASE_CONFIRM
Date: Fri, 25 May 2012 18:03:17 -0400
Message-Id: <1337983402-24677-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1337983402-24677-1-git-send-email-Trond.Myklebust@netapp.com>
 <1337983402-24677-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise we can end up not sending a new exchange-id/setclientid

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 758b9a8..604c600 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1647,6 +1647,7 @@ static void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
 		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
+		clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 		nfs4_state_start_reclaim_nograce(clp);
 		nfs4_schedule_state_manager(clp);
 	}
-- 
1.7.7.6

