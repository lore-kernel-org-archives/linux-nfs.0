Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:6551 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbaIXWLb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 18:11:31 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Fixing lease renewal
Date: Wed, 24 Sep 2014 18:11:28 -0400
Message-ID: <1411596688-21347-1-git-send-email-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit c9fdeb28 removed a 'continue' after checking if the lease needs
to be renewed. However, if client hasn't moved, the code falls down to
starting reboot recovery erroneously (ie., sends open reclaim and gets
back stale_clientid error) before recovering from getting stale_clientid
on the renew operation.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 22fe351..6678769 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2345,6 +2345,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			status = nfs4_check_lease(clp);
 			if (status < 0)
 				goto out_error;
+			continue;
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
-- 
1.8.5.2 (Apple Git-48)

