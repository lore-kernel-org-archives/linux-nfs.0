From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 4/4] nfs41: Invoke RECLAIM_COMPLETE
Date: Sat,  5 Dec 2009 12:20:28 -0800
Message-ID: <1260044428-16341-5-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1260044428-16341-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260044428-16341-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260044428-16341-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1260044428-16341-4-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61724 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756414AbZLEU0H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2009 15:26:07 -0500
In-Reply-To: <1260044428-16341-4-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch invokes RECLAIM_COMPLETE after the client is done
reclaiming state.

There are interpretations of the spec that suggest that
RECLAIM_COMPLETE should also be issued after a new clientid
has been obtained from the server and even if there is no
state to reclaim.  This tells the server that the client
has no state to reclaim even if the client isn't aware the
server may have rebooted.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 fs/nfs/nfs4state.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e325b64..24bde5e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1025,6 +1025,9 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 	struct rb_node *pos;
 	struct nfs4_state *state;
 
+	nfs4_reclaim_complete(clp,
+		nfs4_reboot_recovery_ops[clp->cl_minorversion]);
+
 	if (!test_and_clear_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state))
 		return;
 
-- 
1.5.4.3

