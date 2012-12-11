Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:31223 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676Ab2LKSo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 13:44:29 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/7] NFSD: Don't call nfsd4_sequence_adjust_slot_table under the client_lock
Date: Tue, 11 Dec 2012 13:44:18 -0500
Message-Id: <1355251459-18034-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355251459-18034-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1355251459-18034-1-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-2-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-3-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-4-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We may have to grow the session table.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4state.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a380a61..ed937c8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2224,10 +2224,6 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	else
 		slot->sl_flags &= ~NFSD4_SLOT_CACHETHIS;
 
-	/* Adjust slot table, and retrieve new target/highest slotid values */
-	nfsd4_sequence_adjust_slot_table(session, slot,
-			seq->highest_slotid, seq);
-
 	cstate->slot = slot;
 	cstate->session = session;
 
@@ -2251,6 +2247,11 @@ out:
 	}
 	kfree(conn);
 	spin_unlock(&client_lock);
+	/* Adjust slot table, and retrieve new target/highest slotid values */
+	if (cstate->session)
+		nfsd4_sequence_adjust_slot_table(cstate->session,
+				cstate->slot, seq->highest_slotid, seq);
+
 	dprintk("%s: return %d\n", __func__, ntohl(status));
 	return status;
 }
-- 
1.7.11.7

