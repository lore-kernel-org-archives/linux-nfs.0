Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:20327 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760474AbcLWQGs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:48 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 16/16] SUNRPC SVCAUTH_gss store gss3 child handles in parent rsc
Date: Fri, 23 Dec 2016 11:04:28 -0500
Message-ID: <1482509068-24516-17-git-send-email-andros@netapp.com>
In-Reply-To: <1482509068-24516-1-git-send-email-andros@netapp.com>
References: <1482509068-24516-1-git-send-email-andros@netapp.com>
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
 net/sunrpc/auth_gss/svcauth_gss.c | 125 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 119 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index c89ecca..d5d020f 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -336,9 +336,14 @@ struct gss_svc_seq_data {
  *
  * The parent handle rca entries:
  * - do not use the parent_handle nor assertions fields.
+ * - GSSv3 parent handles uses the children list field to hold
+ *   child handles created by successful RPCSEC_GSS_CREATE calls. This
+ *   list is used upon parent rca record destruction to lookup child rsc
+ *   cache entries so as to destroy the children. The net field is needed
+ *   for the lookup.
  *
  * The child handle rca entries:
- * - do not use the cred, seqdata, nor mechctx fields.
+ * - do not use the cred, seqdata, mechctx, net, ch_lock, nor children fields.
  *        - XXX perhaps use the seqdata?
  * - the parent_handle field is used to lookup the parent context
  * - the assertions field holds the established GSSv3 assertion that the
@@ -352,11 +357,20 @@ struct rsc {
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
@@ -367,6 +381,8 @@ static void rsc_free(struct rsc *rsci)
 	free_svc_cred(&rsci->cred);
 	if (rsci->assertions)
 		gss3_free_svc_assert(rsci->assertions);
+	if (!list_empty(&rsci->children))
+		gss3_free_rsc_children(rsci);
 }
 
 static void rsc_put(struct kref *ref)
@@ -393,6 +409,14 @@ static void rsc_put(struct kref *ref)
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
@@ -411,6 +435,9 @@ static void rsc_put(struct kref *ref)
 	new->mechctx = NULL;
 	init_svc_cred(&new->cred);
 	new->assertions = NULL;
+	new->net = NULL;
+	spin_lock_init(&new->ch_lock);
+	INIT_LIST_HEAD(&new->children);
 }
 
 static void
@@ -431,6 +458,16 @@ static void rsc_put(struct kref *ref)
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
@@ -455,7 +492,7 @@ static int rsc_parse(struct cache_detail *cd,
 	int status = -EINVAL;
 	struct gss_api_mech *gm = NULL;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	/* context handle */
 	len = qword_get(&mesg, buf, mlen);
 	if (len < 0) goto out;
@@ -607,7 +644,7 @@ static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct r
 	struct rsc rsci;
 	struct rsc *found;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
 		return NULL;
 	found = rsc_lookup(cd, &rsci);
@@ -1287,7 +1324,7 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 	time_t expiry;
 	int status = -EINVAL;
 
-	memset(&rsci, 0, sizeof(rsci));
+	init_rsc(&rsci);
 	/* context handle */
 	status = -ENOMEM;
 	/* the handle needs to be just a unique id,
@@ -1537,6 +1574,68 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
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
@@ -1558,8 +1657,7 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
 	long dummy;
 	long long ctxh;
 
-	memset(&child, 0, sizeof(child));
-
+	init_rsc(&child);
 	/* context handle */
 	ctxh = atomic64_inc_return(&ctxhctr);
 
@@ -1680,6 +1778,21 @@ static void gss3_free_svc_assert(struct gss3_svc_assert *g3a)
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
 	enc_len = 36 + child_handle.len + glp->la_label.len;
 	if (resv->iov_len + enc_len > PAGE_SIZE)
 		goto drop;
-- 
1.8.3.1

