Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f44.google.com ([209.85.216.44]:33956 "EHLO
	mail-qa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:36 -0400
Received: by mail-qa0-f44.google.com with SMTP id j7so4653499qaq.10
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:35 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 25/49] pnfsd: layout state per client tracking
Date: Thu, 26 Sep 2013 14:41:33 -0400
Message-Id: <1380220893-13824-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

List the layout state on the respective file and client structures and
list all layout segments associated with the layout state on the respective
layout state structure.

Use the layout state list (lo_layouts) for looking up the layout.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 40 +++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c |  3 +++
 fs/nfsd/pnfsd.h     |  4 ++++
 fs/nfsd/state.h     |  3 +++
 4 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index e28c396..2d5ddf7 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -130,6 +130,11 @@ struct sbid_tracker {
 		return new;
 	kref_init(&new->ls_ref);
 	new->ls_stid.sc_type = NFS4_LAYOUT_STID;
+	INIT_LIST_HEAD(&new->ls_perclnt);
+	new->ls_client = clp;
+	spin_lock(&layout_lock);
+	list_add(&new->ls_perclnt, &clp->cl_lo_states);
+	spin_unlock(&layout_lock);
 	return new;
 }
 
@@ -139,6 +144,13 @@ struct sbid_tracker {
 	kref_get(&ls->ls_ref);
 }
 
+static void
+unhash_layout_state(struct nfs4_layout_state *ls)
+{
+	ASSERT_LAYOUT_LOCKED();
+	list_del_init(&ls->ls_perclnt);
+}
+
 /*
  * Note: must be called under the state lock
  */
@@ -149,6 +161,11 @@ struct sbid_tracker {
 			container_of(kref, struct nfs4_layout_state, ls_ref);
 
 	nfsd4_remove_stid(&ls->ls_stid);
+	if (!list_empty(&ls->ls_perclnt)) {
+		spin_lock(&layout_lock);
+		unhash_layout_state(ls);
+		spin_unlock(&layout_lock);
+	}
 	nfsd4_free_stid(layout_state_slab, &ls->ls_stid);
 }
 
@@ -234,13 +251,30 @@ struct sbid_tracker {
 	kmem_cache_free(pnfs_layout_slab, lp);
 }
 
+static void update_layout_stateid_locked(struct nfs4_layout_state *ls, stateid_t *sid)
+{
+	update_stateid(&(ls)->ls_stid.sc_stateid);
+	memcpy((sid), &(ls)->ls_stid.sc_stateid, sizeof(stateid_t));
+	dprintk("%s Updated ls_stid to %d on layoutstate %p\n",
+		__func__, sid->si_generation, ls);
+}
+
 static void
 init_layout(struct nfs4_layout *lp,
-	    struct nfsd4_layout_seg *seg)
+	    struct nfs4_layout_state *ls,
+	    struct svc_fh *current_fh,
+	    struct nfsd4_layout_seg *seg,
+	    stateid_t *stateid)
 {
-	dprintk("pNFS %s: lp %p\n", __func__, lp);
+	dprintk("pNFS %s: lp %p ls %p\n", __func__,
+		lp, ls);
 
 	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
+	get_layout_state(ls);		/* put on destroy_layout */
+	lp->lo_state = ls;
+	spin_lock(&layout_lock);
+	update_layout_stateid_locked(ls, stateid);
+	spin_unlock(&layout_lock);
 	dprintk("pNFS %s end\n", __func__);
 }
 
@@ -443,7 +477,7 @@ struct super_block *
 	lgp->lg_seg = res.lg_seg;
 	lgp->lg_roc = res.lg_return_on_close;
 
-	init_layout(lp, &res.lg_seg);
+	init_layout(lp, ls, lgp->lg_fhp, &res.lg_seg, &lgp->lg_sid);
 out_unlock:
 	if (ls)
 		put_layout_state(ls);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fa292bb..0e2266f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1363,6 +1363,9 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
 	INIT_LIST_HEAD(&clp->cl_delegations);
+#if defined(CONFIG_PNFSD)
+	INIT_LIST_HEAD(&clp->cl_lo_states);
+#endif /* CONFIG_PNFSD */
 	INIT_LIST_HEAD(&clp->cl_lru);
 	INIT_LIST_HEAD(&clp->cl_callbacks);
 	INIT_LIST_HEAD(&clp->cl_revoked);
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index c2360e4..a0363a7 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -44,10 +44,14 @@
 struct nfs4_layout_state {
 	struct nfs4_stid	ls_stid; /* must be first field */
 	struct kref		ls_ref;
+	struct list_head	ls_perclnt;
+	struct nfs4_client	*ls_client;
 };
 
 /* outstanding layout */
 struct nfs4_layout {
+	struct list_head		lo_perstate;
+	struct nfs4_layout_state	*lo_state;
 	struct nfsd4_layout_seg		lo_seg;
 };
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 8c6e097..187d169 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -291,6 +291,9 @@ struct nfs4_client {
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
 	struct net		*net;
+#if defined(CONFIG_PNFSD)
+	struct list_head	cl_lo_states;	/* outstanding layout states */
+#endif /* CONFIG_PNFSD */
 };
 
 /* struct nfs4_client_reset
-- 
1.8.3.1

