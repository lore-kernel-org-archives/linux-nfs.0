Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:57657 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974AbaIXQNY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Sep 2014 12:13:24 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Fixing lease renewal
Date: Wed, 24 Sep 2014 12:08:31 -0400
Message-ID: <1411574911-19269-1-git-send-email-kolga@netapp.com>
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
 fs/nfs/nfs4state.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 22fe351..4616598 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2340,11 +2340,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
-		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
+		if (!test_bit(NFS4CLNT_MOVED, &clp->cl_state) &&
+		     test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
 			section = "check lease";
 			status = nfs4_check_lease(clp);
 			if (status < 0)
 				goto out_error;
+			continue;
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
-- 
1.8.5.2 (Apple Git-48)

