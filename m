Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:26146 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752592AbdCBQN3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:13:29 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 17/18] NFSD support OFFLOAD_STATUS
Date: Thu, 2 Mar 2017 11:01:41 -0500
Message-ID: <20170302160142.30413-18-kolga@netapp.com>
In-Reply-To: <20170302160142.30413-1-kolga@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Update number of bytes copied in the copy state and query that
value under lock if OFFLOAD_STATUS operation received.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 14 +++++++++++++-
 fs/nfsd/state.h    |  1 +
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f07eae1..8a1860e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1390,6 +1390,7 @@ static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
 		dst_pos += bytes_copied;
 		spin_lock(&copy->cps->cp_lock);
 		cancelled = copy->cps->cp_cancelled;
+		copy->cps->cp_bytes_copied = copy->cp_res.wr_bytes_written;
 		spin_unlock(&copy->cps->cp_lock);
 	} while (bytes_total > 0 && !cancelled);
 	return bytes_copied;
@@ -1630,7 +1631,18 @@ static void nfsd4_do_async_copy(struct work_struct *work)
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

