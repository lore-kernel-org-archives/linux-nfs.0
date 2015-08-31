Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:36911 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105AbbHaTuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Aug 2015 15:50:54 -0400
From: <andros@netapp.com>
To: <Trond.Myklebust@primarydata.com>
CC: <Anna.Schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH 16/16] NFSD: extra stateid checking in read for interserver copy
Date: Mon, 31 Aug 2015 15:50:06 -0400
Message-ID: <1441050606-40897-17-git-send-email-andros@netapp.com>
In-Reply-To: <1441050606-40897-1-git-send-email-andros@netapp.com>
References: <1441050606-40897-1-git-send-email-andros@netapp.com>
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
 fs/nfsd/nfs4proc.c  | 43 ++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c |  8 +-------
 fs/nfsd/state.h     |  8 ++++++++
 3 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0213f91..38e8554 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -803,8 +803,37 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 					&read->rd_stateid, RD_STATE,
 					&read->rd_filp, &read->rd_tmp_file);
 	if (status) {
-		dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
-		goto out;
+		/* if clientid in rd_stateid is different from current,
+		 * find corresponding clientid and look for stateid there
+		 */
+		struct net *net = SVC_NET(rqstp);
+		struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+		struct nfs4_client *clp = NULL;
+
+		spin_lock(&nn->client_lock);
+		list_for_each_entry(clp, &nn->client_lru, cl_lru) {
+			if (same_clid(&clp->cl_clientid,
+			    &read->rd_stateid.si_opaque.so_clid)) {
+				struct nfs4_stid *stid = NULL;
+
+				stid = find_stateid_by_type(clp,
+						&read->rd_stateid,
+						NFS4_DELEG_STID|NFS4_OPEN_STID|
+						NFS4_LOCK_STID);
+				if (stid) {
+					nfs4_put_stid(stid);
+					if (stid->is_copy)
+						status = nfs_ok;
+					break;
+				}
+			}
+		}
+		spin_unlock(&nn->client_lock);
+		if (status != nfs_ok) {
+			dprintk("NFSD: %s: couldn't process stateid!\n",
+				__func__);
+			goto out;
+		}
 	}
 	status = nfs_ok;
 out:
@@ -1397,6 +1426,7 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct file *src = NULL;
 	struct nfs42_netaddr *naddr;
+	struct nfs4_stid *stid = NULL;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate,
 					&cstate->current_fh,
@@ -1412,7 +1442,14 @@ nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 * connections from the destination e.g. what is returned in cpn_src,
 	 * to verify READ from dest server.
 	 */
-
+	/* mark the original open stateid special */
+	stid = find_stateid_by_type(cstate->session->se_client,
+		&cp_notify->cpn_src_stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|
+		NFS4_LOCK_STID);
+	if (stid) {
+		stid->is_copy = 1;
+		nfs4_put_stid(stid);
+	}
 	/**
 	 * For now, only return one source server address, the address used
 	 * by the client in the static cpn_src.
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 96de0d3..109aecb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1809,12 +1809,6 @@ same_verf(nfs4_verifier *v1, nfs4_verifier *v2)
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
@@ -1916,7 +1910,7 @@ find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 	return ret;
 }
 
-static struct nfs4_stid *
+struct nfs4_stid *
 find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d3e81ce..5c98514 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -94,6 +94,7 @@ struct nfs4_stid {
 #define NFS4_REVOKED_DELEG_STID 16
 #define NFS4_CLOSED_DELEG_STID 32
 #define NFS4_LAYOUT_STID 64
+	bool is_copy;
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
@@ -583,6 +584,13 @@ enum nfsd4_cb_op {
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

