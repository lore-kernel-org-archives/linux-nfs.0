Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:5726 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751386AbdBXWUc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:32 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 17/17] SUNRPC SVCAUTH_gss store gss3 child handles in parent rsc
Date: Fri, 24 Feb 2017 17:19:53 -0500
Message-ID: <20170224221953.5502-18-andros@netapp.com>
In-Reply-To: <20170224221953.5502-1-andros@netapp.com>
References: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

GSSv3 parent handles use the new children list field protected
by the new ch_lock to hold child handles created by successful
RPCSEC_GSS_CREATE calls. This list is used upon parent rsc entry
destruction to lookup child rsc cache entries so as to reap the
children. The net field is needed for the lookup.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 129 +++++++++++++++++++++++++++++++++++---
 1 file changed, 121 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f4c4ea1..ab987e3 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -345,7 +345,12 @@ struct gss_svc_seq_data {
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
@@ -355,11 +360,20 @@ struct rsc {
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
@@ -370,6 +384,8 @@ static void rsc_free(struct rsc *rsci)
 	free_svc_cred(&rsci->cred);
 	if (rsci->assertions)
 		gss3_free_svc_assert(rsci->assertions);
+	if (!list_empty(&rsci->children))
+		gss3_free_rsc_children(rsci);
 }
 
 static void rsc_put(struct kref *ref)
@@ -396,6 +412,14 @@ rsc_match(struct cache_head *a, struct cache_head *b)
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
@@ -414,6 +438,9 @@ rsc_init(struct cache_head *cnew, struct cache_head *ctmp)
 	new->mechctx = NULL;
 	init_svc_cred(&new->cred);
 	new->assertions = NULL;
+	new->net = NULL;
+	spin_lock_init(&new->ch_lock);
+	INIT_LIST_HEAD(&new->children);
 }
 
 static void
@@ -434,6 +461,16 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
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
@@ -458,7 +495,7 @@ static int rsc_parse(struct cache_detail *cd,
 	int status = -EINVAL;
 	struct gss_api_mech *gm = NULL;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	/* context handle */
 	len = qword_get(&mesg, buf, mlen);
 	if (len < 0) goto out;
@@ -610,7 +647,7 @@ gss_svc_searchbyctx(struct cache_detail *cd, struct xdr_netobj *handle)
 	struct rsc rsci;
 	struct rsc *found;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
 		return NULL;
 	found = rsc_lookup(cd, &rsci);
@@ -1290,7 +1327,7 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 	time_t expiry;
 	int status = -EINVAL;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	/* context handle */
 	status = -ENOMEM;
 	/* the handle needs to be just a unique id,
@@ -1549,6 +1586,68 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	kfree(g3a);
 }
 
+static void gss3_free_rsc_children(struct rsc *rsci)
+{
+	struct rsc_child_entry *cep, *tmp;
+	LIST_HEAD(free);
+	struct sunrpc_net *sn = net_generic(rsci->net, sunrpc_net_id);
+	struct rsc *child;
+
+	spin_lock(&rsci->ch_lock);
+
+	list_for_each_entry_safe(cep, tmp, &rsci->children, ce_list)
+		list_move(&cep->ce_list, &free);
+
+	spin_unlock(&rsci->ch_lock);
+
+	list_for_each_entry_safe(cep, tmp, &free, ce_list) {
+		list_del(&cep->ce_list);
+		child = gss_svc_searchbyctx(sn->rsc_cache, &cep->ce_chandle);
+		if (child) {
+			/* balance gss_svc_searchbyctx cache_get */
+			cache_put(&child->h, sn->rsc_cache);
+			 /* reap the child */
+			sunrpc_cache_unhash(sn->rsc_cache, &child->h);
+		} else
+			pr_warn("RPC    %s child in children list not found\n",
+				__func__);
+	}
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
@@ -1570,8 +1669,7 @@ gss3_save_child_rsc(struct cache_detail *cd, uint64_t *handle,
 	long dummy;
 	long long ctxh;
 
-	memset(&child, 0, sizeof(child));
-
+	init_rsc(&child);
 	/* context handle */
 	ctxh = atomic64_inc_return(&ctxhctr);
 
@@ -1689,6 +1787,22 @@ gss3_handle_create_req(struct kvec *resv, struct kvec *argv, struct rsc *rsci,
 	child_handle.data = (u8 *)&c_handle;
 	child_handle.len = sizeof(c_handle);
 
+	ret = gss3_add_child_rsc(sn->rsc_cache, rsci, &child_handle);
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
@@ -1763,8 +1877,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	dprintk("RPC:       svcauth_gss: argv->iov_len = %zd\n",
 			argv->iov_len);
 
-	*authp = rpc_autherr_badcred;
-	if (!svcdata)
+	*authp = rpc_autherr_badcred; if (!svcdata)
 		svcdata = kmalloc(sizeof(*svcdata), GFP_KERNEL);
 	if (!svcdata)
 		goto auth_err;
-- 
2.9.3

