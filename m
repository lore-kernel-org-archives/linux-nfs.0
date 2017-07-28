Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52446 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752660AbdG1UWe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:22:34 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 12/12] SUNRPC SVCAUTH_gss store gss3 child handles in parent rsc
Date: Fri, 28 Jul 2017 16:21:58 -0400
Message-ID: <1501273318-14200-13-git-send-email-andros@netapp.com>
In-Reply-To: <1501273318-14200-1-git-send-email-andros@netapp.com>
References: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Keep a parent list of associated child rsc cache entries used upon parent
destruction to lookup and reap child rsc cache entries

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 182 +++++++++++++++++++++++++++++++++++---
 1 file changed, 172 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 2a48aa0..1d61345 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -348,7 +348,12 @@ struct gss_svc_seq_data {
  *     the parent.
  *     2) assertions: set on a child rsc cache entry to hold the
  *     RPCSEC_GSS_CREATE data to assert.
- *
+ *     3) net:  set on the parent rsc cache entry and is required for the
+ *     lookup associated child rsc cache entries upon parent destruction.
+ *     4) ch_lock: used by the parent; protects the children list
+ *     5) children: used by the parent rsc cache entry to hold a list of
+ *     associated child rsc cache entries and used upon parent destruction
+ *     to lookup child rsc cache entries so as to destroy the children.
  */
 struct rsc {
 	struct cache_head	h;
@@ -358,11 +363,20 @@ struct rsc {
 	struct gss_svc_seq_data	seqdata;
 	struct gss_ctx		*mechctx;
 	struct gss3_svc_assert  *assertions;
+	struct net		*net;
+	spinlock_t		ch_lock; /* for children */
+	struct list_head	children;
+};
+
+struct rsc_child_entry {
+	struct list_head	ce_list;
+	struct xdr_netobj	ce_chandle;
 };
 
 static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct rsc *old);
 static struct rsc *rsc_lookup(struct cache_detail *cd, struct rsc *item);
 static void gss3_free_svc_assert(struct gss3_svc_assert *g3a);
+static void gss3_free_rsc_children(struct rsc *rsci);
 
 static void rsc_free(struct rsc *rsci)
 {
@@ -373,6 +387,8 @@ static void rsc_free(struct rsc *rsci)
 	free_svc_cred(&rsci->cred);
 	if (rsci->assertions)
 		gss3_free_svc_assert(rsci->assertions);
+	if (!list_empty(&rsci->children))
+		gss3_free_rsc_children(rsci);
 }
 
 static void rsc_put(struct kref *ref)
@@ -399,6 +415,14 @@ static void rsc_put(struct kref *ref)
 }
 
 static void
+init_rsc(struct rsc *rsci)
+{
+	memset(rsci, 0, sizeof(struct rsc));
+	spin_lock_init(&rsci->ch_lock);
+	INIT_LIST_HEAD(&rsci->children);
+}
+
+static void
 rsc_init(struct cache_head *cnew, struct cache_head *ctmp)
 {
 	struct rsc *new = container_of(cnew, struct rsc, h);
@@ -417,6 +441,9 @@ static void rsc_put(struct kref *ref)
 	new->mechctx = NULL;
 	init_svc_cred(&new->cred);
 	new->assertions = NULL;
+	new->net = NULL;
+	spin_lock_init(&new->ch_lock);
+	INIT_LIST_HEAD(&new->children);
 }
 
 static void
@@ -437,6 +464,16 @@ static void rsc_put(struct kref *ref)
 	new->assertions = tmp->assertions;
 	tmp->assertions = NULL;
 	init_svc_cred(&tmp->cred);
+	new->net = tmp->net;
+	tmp->net = NULL;
+	spin_lock_init(&new->ch_lock);
+	INIT_LIST_HEAD(&new->children);
+	spin_lock(&tmp->ch_lock);
+	if (!list_empty(&tmp->children)) {
+		list_move(&tmp->children, &new->children);
+		INIT_LIST_HEAD(&tmp->children);
+	}
+	spin_unlock(&tmp->ch_lock);
 }
 
 static struct cache_head *
@@ -461,7 +498,7 @@ static int rsc_parse(struct cache_detail *cd,
 	int status = -EINVAL;
 	struct gss_api_mech *gm = NULL;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	/* context handle */
 	len = qword_get(&mesg, buf, mlen);
 	if (len < 0) goto out;
@@ -613,7 +650,7 @@ static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct r
 	struct rsc rsci;
 	struct rsc *found;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
 		return NULL;
 	found = rsc_lookup(cd, &rsci);
@@ -1285,7 +1322,7 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 	time_t expiry;
 	int status = -EINVAL;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	/* context handle */
 	status = -ENOMEM;
 	/* the handle needs to be just a unique id,
@@ -1544,6 +1581,101 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	kfree(g3a);
 }
 
+static void
+gss3_free_child(struct rsc_child_entry *cep, struct sunrpc_net *sn)
+{
+	struct rsc *child;
+
+	child = gss_svc_searchbyctx(sn->rsc_cache, &cep->ce_chandle);
+	if (!child) {
+		pr_warn("RPC    %s child in children list not found\n",
+			__func__);
+		goto out_free;
+	}
+	/* balance gss_svc_searchbyctx cache_get */
+	cache_put(&child->h, sn->rsc_cache);
+	/* reap the child */
+	sunrpc_cache_unhash(sn->rsc_cache, &child->h);
+out_free:
+	kfree(cep);
+}
+
+static void gss3_free_rsc_children(struct rsc *parent_rsc)
+{
+	struct rsc_child_entry *cep, *tmp;
+	LIST_HEAD(free);
+	struct sunrpc_net *sn = net_generic(parent_rsc->net, sunrpc_net_id);
+
+	spin_lock(&parent_rsc->ch_lock);
+	list_for_each_entry_safe(cep, tmp, &parent_rsc->children, ce_list) {
+		list_move(&cep->ce_list, &free);
+		/* balance cache_get in gss3_add_child_rsc */
+		cache_put(&parent_rsc->h, sn->rsc_cache);
+	}
+	spin_unlock(&parent_rsc->ch_lock);
+
+	list_for_each_entry_safe(cep, tmp, &free, ce_list) {
+		list_del(&cep->ce_list);
+		gss3_free_child(cep, sn);
+	}
+}
+
+static void
+gss3_free_child_entry(struct rsc *p_rsci, struct xdr_netobj *chandle)
+{
+	struct sunrpc_net *sn = net_generic(p_rsci->net, sunrpc_net_id);
+	struct rsc_child_entry *cep, *tmp;
+
+	spin_lock(&p_rsci->ch_lock);
+	list_for_each_entry_safe(cep, tmp, &p_rsci->children, ce_list) {
+		if (netobj_equal(chandle, &cep->ce_chandle)) {
+			list_del(&cep->ce_list);
+			spin_unlock(&p_rsci->ch_lock);
+			/* balance cache_get in gss3_add_child_rsc */
+			cache_put(&p_rsci->h, sn->rsc_cache);
+			kfree(cep);
+			return;
+		}
+	}
+	spin_unlock(&p_rsci->ch_lock);
+}
+
+/**
+ * After a gss3 child rsc is created, add it's context handle to the
+ * children list of the parent rsc.
+ * Required: gss_svc_searchbyctx has already been called on parent_rsc.
+ */
+static int
+gss3_add_child_rsc(struct cache_detail *cd, struct rsc *parent_rsc,
+		   struct xdr_netobj *chandle)
+{
+	struct rsc_child_entry *cep;
+	int status = -ENOMEM;
+
+	cep = kmalloc(sizeof(*cep), GFP_KERNEL);
+	if (!cep)
+		goto out;
+
+	/* child handle */
+	if (dup_netobj(&cep->ce_chandle, chandle))
+		goto out_free;
+
+	parent_rsc->net = cd->net;
+	INIT_LIST_HEAD(&cep->ce_list);
+	spin_lock(&parent_rsc->ch_lock);
+	list_add(&cep->ce_list, &parent_rsc->children);
+	spin_unlock(&parent_rsc->ch_lock);
+	/* balanced by cache_put in free children routines */
+	cache_get(&parent_rsc->h);
+
+	status = 0;
+out:
+	return status;
+out_free:
+	kfree(cep);
+	goto out;
+}
+
 /**
  * gss3_save_child_rsc()
  * Create a child handle, set the parent handle, assertions, and add to
@@ -1565,8 +1697,7 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	long dummy;
 	long long ctxh;
 
-	memset(&child, 0, sizeof(child));
-
+	init_rsc(&child);
 	/* context handle */
 	ctxh = atomic64_inc_return(&ctxhctr);
 
@@ -1673,8 +1804,10 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 		       struct sunrpc_net *sn)
 {
 	struct kvec *resv = &rqstp->rq_res.head[0];
+	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
 	struct gss3_svc_assert *g3a;
 	struct gss3_label *glp;
+	struct rsc *p_rsci = svcdata->rsci;
 	u64 c_handle;
 	struct xdr_netobj child_handle;
 	int enc_len, assert_len, ret = 0;
@@ -1689,6 +1822,22 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	child_handle.data = (u8 *)&c_handle;
 	child_handle.len = sizeof(c_handle);
 
+	ret = gss3_add_child_rsc(sn->rsc_cache, p_rsci, &child_handle);
+	if (ret < 0) {
+		struct rsc *child;
+
+		pr_warn("%s failed to add child rsc to parent\n", __func__);
+		/* delete child */
+		child = gss_svc_searchbyctx(sn->rsc_cache, &child_handle);
+		if (child) {
+			/* balance gss_svc_searchbyctx cache_get */
+			cache_put(&child->h, sn->rsc_cache);
+			 /* reap the child */
+			sunrpc_cache_unhash(sn->rsc_cache, &child->h);
+		}
+		goto auth_err;
+	}
+
 	/* calculate the assert length. Support one assert per request */
 	switch (g3a->sa_assert.au_type) {
 	case GSS3_LABEL:
@@ -1762,8 +1911,7 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	dprintk("RPC:       svcauth_gss: argv->iov_len = %zd\n",
 			argv->iov_len);
 
-	*authp = rpc_autherr_badcred;
-	if (!svcdata)
+	*authp = rpc_autherr_badcred; if (!svcdata)
 		svcdata = kmalloc(sizeof(*svcdata), GFP_KERNEL);
 	if (!svcdata)
 		goto auth_err;
@@ -1823,6 +1971,7 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 		if (rsci->parent_handle.len != 0) { /* GSSv3 child handle */
 
 			rsci_ch = rsci;
+			/* take reference on child rsc entry */
 			rsci = gss_svc_searchbyctx(sn->rsc_cache,
 						   &rsci_ch->parent_handle);
 			if (!rsci) {
@@ -1854,6 +2003,15 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc, gc->gc_seq))
 			goto auth_err;
+
+		/* Destroying child, remove from parent list */
+		if (rsci_ch)
+			gss3_free_child_entry(rsci, &rsci_ch->handle);
+
+		/* Destroying parent. Remove all children from list */
+		else if (!list_empty(&rsci->children))
+			gss3_free_rsc_children(rsci);
+
 		/* Delete the entry from the cache_list and call cache_put */
 		sunrpc_cache_unhash(sn->rsc_cache, &rsci->h);
 		if (resv->iov_len + 4 > PAGE_SIZE)
@@ -1934,10 +2092,14 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 drop:
 	ret = SVC_CLOSE;
 out:
+	if (rsci_ch) {
+		if (rsci)
+			cache_put(&rsci_ch->h, sn->rsc_cache);
+		else
+			WARN_ON_ONCE(!rsci);
+	}
 	if (rsci)
 		cache_put(&rsci->h, sn->rsc_cache);
-	if (rsci_ch)
-		cache_put(&rsci_ch->h, sn->rsc_cache);
 	return ret;
 }
 
-- 
1.8.3.1

