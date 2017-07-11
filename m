Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:36346 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934054AbdGKQpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:45:05 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 40/42] NFSD support OFFLOAD_STATUS
Date: Tue, 11 Jul 2017 12:44:14 -0400
Message-ID: <20170711164416.1982-41-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update number of bytes copied in the copy state and query that
value under lock if OFFLOAD_STATUS operation received.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 15 ++++++++++++++-
 fs/nfsd/state.h    |  1 +
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c411887..1094286 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1375,6 +1375,8 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
 		if (!copy->cp_synchronous) {
 			spin_lock(&copy->cps->cp_lock);
 			cancelled = copy->cps->cp_cancelled;
+			copy->cps->cp_bytes_copied =
+				copy->cp_res.wr_bytes_written;
 			spin_unlock(&copy->cps->cp_lock);
 		}
 	} while (bytes_total > 0 && !copy->cp_synchronous && !cancelled);
@@ -1665,7 +1667,18 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 		     struct nfsd4_compound_state *cstate,
 		     struct nfsd4_offload_status *os)
 {
-	return nfserr_notsupp;
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
index 70ee3fe..25c5d82 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -117,6 +117,7 @@ struct nfs4_cp_state {
 	bool			cp_dst_async;	/* async copy on dst server */
 	bool			cp_cancelled;	/* copy cancelled */
 	spinlock_t		cp_lock;
+	ssize_t			cp_bytes_copied;/* copy progress */
 };
 
 /*
-- 
1.8.3.1

