From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 25/69] NFSv4: Ensure that nfs4_reclaim_open_state() doesn't
 depend on cl_sem
Date: Tue, 23 Dec 2008 18:02:12 -0500
Message-ID: <20081223230212.13743.33907.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549AbYLWXXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:49 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFt006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:43 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4state.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 7dcca23..beade55 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -893,11 +893,15 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	 * recovering after a network partition or a reboot from a
 	 * server that doesn't support a grace period.
 	 */
+restart:
+	spin_lock(&sp->so_lock);
 	list_for_each_entry(state, &sp->so_states, open_states) {
 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
 			continue;
 		if (state->state == 0)
 			continue;
+		atomic_inc(&state->count);
+		spin_unlock(&sp->so_lock);
 		status = ops->recover_open(sp, state);
 		if (status >= 0) {
 			status = nfs4_reclaim_locks(state, ops);
@@ -907,7 +911,8 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 						printk("%s: Lock reclaim failed!\n",
 							__func__);
 				}
-				continue;
+				nfs4_put_open_state(state);
+				goto restart;
 			}
 		}
 		switch (status) {
@@ -935,9 +940,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			case -NFS4ERR_STALE_CLIENTID:
 				goto out_err;
 		}
+		nfs4_put_open_state(state);
+		goto restart;
 	}
+	spin_unlock(&sp->so_lock);
 	return 0;
 out_err:
+	nfs4_put_open_state(state);
 	return status;
 }
 

