Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:38055 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934016AbdGKQoy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:54 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 30/42] NFSD Unique stateid_t for inter server to server COPY authentication
Date: Tue, 11 Jul 2017 12:44:04 -0400
Message-ID: <20170711164416.1982-31-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A per COPY unique stateid_t is required to authenticate the READ from
the destination server (acting as a client) on the source server.

Multiple concurrent inter server to server copies of the same source file
are also supported.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/netns.h     |   8 ++++
 fs/nfsd/nfs4proc.c  |  25 ++++++++----
 fs/nfsd/nfs4state.c | 108 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c   |   2 +-
 fs/nfsd/nfsctl.c    |   2 +
 fs/nfsd/state.h     |  18 +++++++++
 fs/nfsd/xdr4.h      |   2 +-
 7 files changed, 156 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 3714231..2c88a95 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -119,6 +119,14 @@ struct nfsd_net {
 	u32 clverifier_counter;
 
 	struct svc_serv *nfsd_serv;
+
+	/*
+	 * clientid and stateid data for construction of net unique COPY
+	 * stateids.
+	 */
+	u32		s2s_cp_cl_id;
+	struct idr	s2s_cp_stateids;
+	spinlock_t	s2s_cp_lock;
 };
 
 /* Simple check to find out if a given net was properly initialized */
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c6edf01..3d8ed3f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1402,6 +1402,13 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 	return 0;
 }
 
+/*
+ * Use a unique stateid_t as the cnr_stateid so that the source server
+ * can authenticate the inter server to server copy READ from the
+ * destination server.
+ *
+ * Set the cnr_leasetime to the nfsd4_lease.
+ */
 static __be32
 nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_copy_notify *cn)
@@ -1409,6 +1416,7 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 	struct nfs4_stid *stid;
+	struct nfs4_cp_state *cps;
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					&cn->cpn_src_stateid, RD_STATE, NULL,
@@ -1419,12 +1427,11 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 	cn->cpn_sec = nn->nfsd4_lease;
 	cn->cpn_nsec = 0;
 
-
-	/** XXX Save cpn_src_statid, cpn_src, and any other returned source
-	 * server addresses on which the source server is williing to accept
-	 * connections from the destination e.g. what is returned in cpn_src,
-	 * to verify READ from dest server.
-	 */
+	status = nfserrno(-ENOMEM);
+	cps = nfs4_alloc_init_cp_state(nn, nn->nfsd4_lease, stid);
+	if (!cps)
+		return status;
+	memcpy(&cn->cpn_cnr_stateid, &cps->cp_stateid, sizeof(stateid_t));
 
 	/**
 	 * For now, only return one server address in cpn_src, the
@@ -1432,7 +1439,11 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 	 */
 	cn->cpn_src.nl_nsvr = 1;
 
-	return nfsd4_set_src_nl4_netaddr(rqstp, &cn->cpn_src);
+	status = nfsd4_set_src_nl4_netaddr(rqstp, &cn->cpn_src);
+	if (status != 0)
+		nfs4_free_cp_state(cps);
+
+	return status;
 }
 
 static __be32
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8425735..b019fc8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -658,6 +658,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	/* Will be incremented before return to client: */
 	atomic_set(&stid->sc_count, 1);
 	spin_lock_init(&stid->sc_lock);
+	INIT_LIST_HEAD(&stid->sc_cp_list);
 
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
@@ -674,6 +675,106 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	return NULL;
 }
 
+/*
+ * Create a unique stateid_t to represent each COPY - returned by
+ * COPY_NOTIFY cnr_stateid and used in the copy READ from the
+ * destination server. Hang the copy stateids off the OPEN/LOCK/DELEG
+ * stateid from the client open of the source file. Bookeep other
+ * copy state such as the cnr_leasetime.
+ */
+struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
+						u64 cpn_sec,
+						struct nfs4_stid *p_stid)
+{
+	struct nfs4_cp_state *cps;
+	int new_id;
+
+	cps = kzalloc(sizeof(struct nfs4_cp_state), GFP_KERNEL);
+	if (!cps)
+		return NULL;
+	idr_preload(GFP_KERNEL);
+	spin_lock(&nn->s2s_cp_lock);
+	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, cps, 0, 0, GFP_NOWAIT);
+	spin_unlock(&nn->s2s_cp_lock);
+	idr_preload_end();
+	if (new_id < 0)
+		goto out_free;
+	cps->cp_stateid.si_opaque.so_id = new_id;
+	cps->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
+	cps->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
+	cps->cp_p_stid = p_stid;
+	cps->cp_active = false;
+	INIT_LIST_HEAD(&cps->cp_list);
+	cps->cp_timeout = jiffies + (cpn_sec * HZ);
+	list_add(&cps->cp_list, &p_stid->sc_cp_list);
+
+	return cps;
+out_free:
+	kfree(cps);
+	return NULL;
+}
+
+void nfs4_free_cp_state(struct nfs4_cp_state *cps)
+{
+	struct nfsd_net *nn;
+
+	dprintk("--> %s freeing cp_state so_id %d\n", __func__,
+		cps->cp_stateid.si_opaque.so_id);
+
+	nn = net_generic(cps->cp_p_stid->sc_client->net, nfsd_net_id);
+	spin_lock(&nn->s2s_cp_lock);
+	idr_remove(&nn->s2s_cp_stateids, cps->cp_stateid.si_opaque.so_id);
+	spin_unlock(&nn->s2s_cp_lock);
+
+	kfree(cps);
+}
+
+static void nfs4_free_cp_statelist(struct nfs4_stid *stid)
+{
+	struct nfs4_cp_state *cps;
+
+	might_sleep();
+
+	while (!list_empty(&stid->sc_cp_list)) {
+		cps = list_first_entry(&stid->sc_cp_list, struct nfs4_cp_state,
+				       cp_list);
+		list_del(&cps->cp_list);
+		nfs4_free_cp_state(cps);
+	}
+}
+
+/*
+ * A READ from an inter server to server COPY will have a
+ * copy stateid. Return the parent nfs4_stid.
+ */
+static __be32 find_cp_state_parent(struct nfsd_net *nn, stateid_t *st,
+				   struct nfs4_stid **stid)
+{
+	struct nfs4_cp_state *cps = NULL;
+
+	if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
+		return nfserr_bad_stateid;
+	spin_lock(&nn->s2s_cp_lock);
+	cps = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
+	spin_unlock(&nn->s2s_cp_lock);
+	if (!cps) {
+		pr_info("NFSD: find_cp_state cl_id %d so_id %d NOT FOUND\n",
+			st->si_opaque.so_clid.cl_id, st->si_opaque.so_id);
+		return nfserr_bad_stateid;
+	}
+
+	/* Did the inter server to server copy start in time? */
+	if (cps->cp_active == false && !time_after(cps->cp_timeout, jiffies))
+		return nfserr_partner_no_auth;
+	else
+		cps->cp_active = true;
+
+	*stid = cps->cp_p_stid;
+	atomic_inc(&cps->cp_p_stid->sc_count);
+
+	return nfs_ok;
+}
+
 static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
 {
 	struct nfs4_stid *stid;
@@ -819,6 +920,9 @@ static void block_delegations(struct knfsd_fh *fh)
 	}
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
 	spin_unlock(&clp->cl_lock);
+
+	nfs4_free_cp_statelist(s);
+
 	s->sc_free(s);
 	if (fp)
 		put_nfs4_file(fp);
@@ -4957,6 +5061,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
+	if (status == nfserr_bad_stateid)
+		status = find_cp_state_parent(nn, stateid, &s);
 	if (status)
 		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid,
@@ -6930,6 +7036,8 @@ static int nfs4_state_create_net(struct net *net)
 	INIT_LIST_HEAD(&nn->close_lru);
 	INIT_LIST_HEAD(&nn->del_recall_lru);
 	spin_lock_init(&nn->client_lock);
+	spin_lock_init(&nn->s2s_cp_lock);
+	idr_init(&nn->s2s_cp_stateids);
 
 	spin_lock_init(&nn->blocked_locks_lock);
 	INIT_LIST_HEAD(&nn->blocked_locks_lru);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2896a11..c4438ac 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4458,7 +4458,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	*p++ = cpu_to_be32(cn->cpn_nsec);
 
 	/* cnr_stateid */
-	nfserr = nfsd4_encode_stateid(xdr, &cn->cpn_src_stateid);
+	nfserr = nfsd4_encode_stateid(xdr, &cn->cpn_cnr_stateid);
 	if (nfserr)
 		return nfserr;
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6493df6..6ef5790 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1241,6 +1241,8 @@ static __net_init int nfsd_init_net(struct net *net)
 	nn->nfsd4_grace = 90;
 	nn->clverifier_counter = prandom_u32();
 	nn->clientid_counter = prandom_u32();
+	nn->s2s_cp_cl_id = nn->clientid_counter++;
+	pr_info("%s s2s_cp_cl_id %d\n", __func__, nn->s2s_cp_cl_id);
 	return 0;
 
 out_idmap_error:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f5ab89a..c084c57 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -93,6 +93,7 @@ struct nfs4_stid {
 #define NFS4_REVOKED_DELEG_STID 16
 #define NFS4_CLOSED_DELEG_STID 32
 #define NFS4_LAYOUT_STID 64
+	struct list_head	sc_cp_list;
 	unsigned char		sc_type;
 	stateid_t		sc_stateid;
 	spinlock_t		sc_lock;
@@ -102,6 +103,20 @@ struct nfs4_stid {
 };
 
 /*
+ * An inter server to server copy stateid that is unique per nfsd_net.
+ * cp_stateid is returned as the COPY_NOTIFY cnr_stateid and presented
+ * by the destination server to the source server as a COPY authenticator.
+ * Used to lookup the parent COPY_NOTIFY cna_src_stateid nfs4_stid.
+ */
+struct nfs4_cp_state {
+	stateid_t		cp_stateid;
+	struct list_head	cp_list;	/* per parent nfs4_stid */
+	struct nfs4_stid	*cp_p_stid;	/* pointer to parent */
+	bool			cp_active;	/* has the copy started */
+	unsigned long		cp_timeout;	/* copy timeout */
+};
+
+/*
  * Represents a delegation stateid. The nfs4_client holds references to these
  * and they are put when it is being destroyed or when the delegation is
  * returned by the client:
@@ -606,6 +621,9 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
 				  void (*sc_free)(struct nfs4_stid *));
+struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn, u64 cpn_sec,
+					       struct nfs4_stid *p_stid);
+void nfs4_free_cp_state(struct nfs4_cp_state *cps);
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index aa94295..5b38f0a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -549,7 +549,7 @@ struct nfsd4_copy_notify {
 	struct nl4_server	cpn_dst;
 
 	/* response */
-	/* Note: cpn_src_stateid is used for cnr_stateid */
+	stateid_t		cpn_cnr_stateid;
 	u64			cpn_sec;
 	u32			cpn_nsec;
 	struct nl4_servers	cpn_src;
-- 
1.8.3.1

