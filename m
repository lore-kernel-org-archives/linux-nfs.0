Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:2773 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752299AbdI1R3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:29:52 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 09/10] NFSD support OFFLOAD_STATUS
Date: Thu, 28 Sep 2017 13:29:44 -0400
Message-ID: <20170928172945.50780-10-kolga@netapp.com>
In-Reply-To: <20170928172945.50780-1-kolga@netapp.com>
References: <20170928172945.50780-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update number of bytes copied in the copy state and query that
value under lock if OFFLOAD_STATUS operation received.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 16 +++++++++++++++-
 fs/nfsd/state.h    |  1 +
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f4f3d93..74bfa4b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1154,6 +1154,8 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
 		if (!copy->cp_synchronous) {
 			spin_lock(&copy->cps->cp_lock);
 			cancelled = copy->cps->cp_cancelled;
+			copy->cps->cp_bytes_copied =
+				copy->cp_res.wr_bytes_written;
 			spin_unlock(&copy->cps->cp_lock);
 		}
 	} while (bytes_total > 0 && !copy->cp_synchronous && !cancelled);
@@ -1321,7 +1323,19 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 		     struct nfsd4_compound_state *cstate,
 		     union nfsd4_op_u *u)
 {
-	return nfserr_notsupp;
+	struct nfsd4_offload_status *os = &u->offload_status;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	__be32 status;
+	struct nfs4_cp_state *state = NULL;
+
+	status = find_cp_state(nn, &os->stateid, &state);
+
+	if (state) {
+		spin_lock(&state->cp_lock);
+		os->count = state->cp_bytes_copied;
+		spin_unlock(&state->cp_lock);
+	}
+	return status;
 }
 
 static __be32
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7a070d5..c31025c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -113,6 +113,7 @@ struct nfs4_cp_state {
 	struct nfs4_stid        *cp_p_stid;     /* pointer to parent */
 	bool                    cp_cancelled;   /* copy cancelled */
 	spinlock_t              cp_lock;
+	ssize_t                 cp_bytes_copied;/* copy progress */
 };
 
 /*
-- 
1.8.3.1

