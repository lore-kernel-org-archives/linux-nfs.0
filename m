Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:40471 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754617AbcHSR00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:26:26 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH Version-2 12/12] NFSD: extra stateid checking in read for interserver copy
Date: Fri, 19 Aug 2016 13:25:12 -0400
Message-ID: <1471627512-4102-13-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <kolga@netapp.com>

Expand stateid structure to store a mark signifying this stateid is a COPY
stateid and special to pass stateid check on READ operation coming from
a different clientid.

In COPY_NOTIFY, mark the stateid stored under the clientid as 'special' by
setting boolean is_copy field to true.

If we received a READ and check for the stateid fails, we need to look
for the stateid under all other clientid structures and their corresponding
stateid lists. Make sure the stateid was previously marked for use READ
from a COPY operation.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 15 ++++++++++++++-
 fs/nfsd/nfs4state.c | 40 +++++++++++++++++++++++++++++++++-------
 fs/nfsd/state.h     |  8 ++++++++
 3 files changed, 55 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 220db84..7c4895e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1427,6 +1427,7 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs42_netaddr *naddr;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nl4_server *ns;
+	struct nfs4_stid *stid = NULL;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&cn->cpn_src_stateid, RD_STATE, &src,
@@ -1440,7 +1441,19 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * connections from the destination e.g. what is returned in cpn_src,
 	 * to verify READ from dest server.
 	 */
-
+	/* mark the original open stateid special */
+	status = nfserr_bad_stateid;
+	stid = find_stateid_by_type(cstate->session->se_client,
+		&cn->cpn_src_stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|
+		NFS4_LOCK_STID);
+	if (stid) {
+		/* cnp_src_stateid is used for reply cnr_stateid */
+		stid->is_copy = 1;
+		nfs4_put_stid(stid);
+	} else {
+		dprintk("NFSD: %s can't find cpn_src_stateid\n", __func__);
+		goto out;
+	}
 	/**
 	 * For now, only return one server address in cpn_src, the
 	 * address used by the client to connect to this server.
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 003f624..5469e32 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1890,12 +1890,6 @@ same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
 	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
 }
 
-static int
-same_clid(clientid_t *cl1, clientid_t *cl2)
-{
-	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
-}
-
 static bool groups_equal(struct group_info *g1, struct group_info *g2)
 {
 	int i;
@@ -2000,7 +1994,7 @@ find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 	return ret;
 }
 
-static struct nfs4_stid *
+struct nfs4_stid *
 find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
@@ -4824,6 +4818,36 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
 	return 0;
 }
 
+/**
+ * If lookup for the stateid fails, we need to look for the stateid under
+ * all other clientid structures and their corresponding stateid lists.
+ * Make sure the stateid was previously marked for use from a COPY operation.
+ */
+static __be32
+nfs4_find_copy_stateid(stateid_t *stateid, struct nfs4_stid **spp,
+		       struct nfsd_net *nn)
+{
+	struct nfs4_client *clp = NULL;
+	struct nfs4_stid *s = NULL;
+	__be32 status = nfserr_bad_stateid;
+
+	spin_lock(&nn->client_lock);
+	list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+		if (same_clid(&clp->cl_clientid, &stateid->si_opaque.so_clid)) {
+			s = find_stateid_by_type(clp, stateid,
+						NFS4_DELEG_STID|NFS4_OPEN_STID|
+						NFS4_LOCK_STID);
+			if (s && s->is_copy)
+				dprintk("%s found COPY stateid\n", __func__);
+				*spp = s;
+				status = nfs_ok;
+				break;
+			}
+		}
+	spin_unlock(&nn->client_lock);
+	return status;
+}
+
 /*
  * Checks for stateid operations
  */
@@ -4854,6 +4878,8 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
+	if (status == nfserr_bad_stateid)
+		status = nfs4_find_copy_stateid(stateid, &s, nn);
 	if (status)
 		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b95adf9..6a97aab 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -94,6 +94,7 @@ struct nfs4_stid {
 #define NFS4_REVOKED_DELEG_STID 16
 #define NFS4_CLOSED_DELEG_STID 32
 #define NFS4_LAYOUT_STID 64
+	bool is_copy;
 	unsigned char		sc_type;
 	stateid_t		sc_stateid;
 	spinlock_t		sc_lock;
@@ -583,6 +584,13 @@ static inline bool nfsd4_stateid_generation_after(stateid_t *a, stateid_t *b)
 struct nfsd4_compound_state;
 struct nfsd_net;
 
+static inline int same_clid(clientid_t *cl1, clientid_t *cl2)
+{
+	return (cl1->cl_boot == cl2->cl_boot) && (cl1->cl_id == cl2->cl_id);
+}
+
+extern struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl,
+	stateid_t *t, char typemask);
 extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
 		stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
-- 
1.8.3.1

