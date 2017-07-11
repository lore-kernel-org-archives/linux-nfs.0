Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:32928 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934050AbdGKQoy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:54 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 36/42] NFSD handle OFFLOAD_CANCEL op
Date: Tue, 11 Jul 2017 12:44:10 -0400
Message-ID: <20170711164416.1982-37-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Upon receiving OFFLOAD_CANCEL search the list of copy stateids,
if found remove it and it will lead to following READs failing
with ERR_PARTNER_NO_AUTH.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 11 +++++++++++
 fs/nfsd/nfs4state.c | 30 ++++++++++++++++++++----------
 fs/nfsd/state.h     |  2 ++
 3 files changed, 33 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a977142..7e7b416 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1579,6 +1579,17 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 		     struct nfsd4_compound_state *cstate,
 		     struct nfsd4_offload_status *os)
 {
+
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	__be32 status;
+	struct nfs4_cp_state *state = NULL;
+
+	status = find_cp_state(nn, &os->stateid, &state);
+	if (!status) {
+		list_del(&state->cp_list);
+		nfs4_free_cp_state(state);
+	}
+
 	return 0;
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d391ce5..bcd87c9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -743,6 +743,22 @@ static void nfs4_free_cp_statelist(struct nfs4_stid *stid)
 	}
 }
 
+__be32 find_cp_state(struct nfsd_net *nn, stateid_t *st,
+			    struct nfs4_cp_state **cps)
+{
+	struct nfs4_cp_state *state = NULL;
+
+	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
+		return nfserr_bad_stateid;
+	spin_lock(&nn->s2s_cp_lock);
+	state = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
+	spin_unlock(&nn->s2s_cp_lock);
+	if (!state)
+		return nfserr_bad_stateid;
+	*cps = state;
+	return 0;
+}
+
 /*
  * A READ from an inter server to server COPY will have a
  * copy stateid. Return the parent nfs4_stid.
@@ -750,18 +766,12 @@ static void nfs4_free_cp_statelist(struct nfs4_stid *stid)
 static __be32 find_cp_state_parent(struct nfsd_net *nn, stateid_t *st,
 				   struct nfs4_stid **stid)
 {
+	__be32 status;
 	struct nfs4_cp_state *cps = NULL;
 
-	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
-		return nfserr_bad_stateid;
-	spin_lock(&nn->s2s_cp_lock);
-	cps = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
-	spin_unlock(&nn->s2s_cp_lock);
-	if (!cps) {
-		pr_info("NFSD: find_cp_state cl_id %d so_id %d NOT FOUND\n",
-			st->si_opaque.so_clid.cl_id, st->si_opaque.so_id);
-		return nfserr_bad_stateid;
-	}
+	status = find_cp_state(nn, st, &cps);
+	if (status)
+		return status;
 
 	/* Did the inter server to server copy start in time? */
 	if (cps->cp_active == false && !time_after(cps->cp_timeout, jiffies))
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2acea23..ebf968d 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -651,6 +651,8 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
 extern int nfsd4_create_copy_queue(void);
 extern void nfsd4_destroy_copy_queue(void);
+extern __be32 find_cp_state(struct nfsd_net *nn, stateid_t *st,
+			struct nfs4_cp_state **cps);
 
 struct nfs4_file *find_file(struct knfsd_fh *fh);
 void put_nfs4_file(struct nfs4_file *fi);
-- 
1.8.3.1

