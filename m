Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41939 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121Ab2JBSdY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 14:33:24 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFSv4.1: don't do two EXCHANGE_IDs on mount
Date: Tue,  2 Oct 2012 11:33:22 -0700
Message-Id: <1349202802-21250-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since the addition of NFSv4 server trunking detection the mount context
calls nfs4_proc_exchange_id then schedules the state manager, which also
calls nfs4_proc_exchange_id. Setting the NFS4CLNT_LEASE_CONFIRM bit
makes the state manager skip the unneeded EXCHANGE_ID and continue on
with session creation.

Reported-by: Jorge Mora <mora@netapp.com>
Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4state.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 24a3ab4..c351e6b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -351,6 +351,7 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	status = nfs4_proc_exchange_id(clp, cred);
 	if (status != NFS4_OK)
 		return status;
+	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 
 	return nfs41_walk_client_list(clp, result, cred);
 }
-- 
1.7.9.6 (Apple Git-31.1)

