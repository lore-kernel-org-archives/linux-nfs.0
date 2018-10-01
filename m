Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f196.google.com ([209.85.166.196]:37266 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729487AbeJAVUe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 17:20:34 -0400
Received: by mail-it1-f196.google.com with SMTP id m9-v6so11756973ita.2
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2018 07:42:25 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 06/15] SUNRPC: Lockless server RPCSEC_GSS context lookup
Date: Mon,  1 Oct 2018 10:41:48 -0400
Message-Id: <20181001144157.3515-7-trond.myklebust@hammerspace.com>
In-Reply-To: <20181001144157.3515-6-trond.myklebust@hammerspace.com>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
 <20181001144157.3515-2-trond.myklebust@hammerspace.com>
 <20181001144157.3515-3-trond.myklebust@hammerspace.com>
 <20181001144157.3515-4-trond.myklebust@hammerspace.com>
 <20181001144157.3515-5-trond.myklebust@hammerspace.com>
 <20181001144157.3515-6-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use RCU protection for looking up the RPCSEC_GSS context.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 32 +++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 87c71fb0f0ea..1ece4bc3eb8d 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -76,6 +76,7 @@ struct rsi {
 	struct xdr_netobj	in_handle, in_token;
 	struct xdr_netobj	out_handle, out_token;
 	int			major_status, minor_status;
+	struct rcu_head		rcu_head;
 };
 
 static struct rsi *rsi_update(struct cache_detail *cd, struct rsi *new, struct rsi *old);
@@ -89,13 +90,21 @@ static void rsi_free(struct rsi *rsii)
 	kfree(rsii->out_token.data);
 }
 
-static void rsi_put(struct kref *ref)
+static void rsi_free_rcu(struct rcu_head *head)
 {
-	struct rsi *rsii = container_of(ref, struct rsi, h.ref);
+	struct rsi *rsii = container_of(head, struct rsi, rcu_head);
+
 	rsi_free(rsii);
 	kfree(rsii);
 }
 
+static void rsi_put(struct kref *ref)
+{
+	struct rsi *rsii = container_of(ref, struct rsi, h.ref);
+
+	call_rcu(&rsii->rcu_head, rsi_free_rcu);
+}
+
 static inline int rsi_hash(struct rsi *item)
 {
 	return hash_mem(item->in_handle.data, item->in_handle.len, RSI_HASHBITS)
@@ -282,7 +291,7 @@ static struct rsi *rsi_lookup(struct cache_detail *cd, struct rsi *item)
 	struct cache_head *ch;
 	int hash = rsi_hash(item);
 
-	ch = sunrpc_cache_lookup(cd, &item->h, hash);
+	ch = sunrpc_cache_lookup_rcu(cd, &item->h, hash);
 	if (ch)
 		return container_of(ch, struct rsi, h);
 	else
@@ -330,6 +339,7 @@ struct rsc {
 	struct svc_cred		cred;
 	struct gss_svc_seq_data	seqdata;
 	struct gss_ctx		*mechctx;
+	struct rcu_head		rcu_head;
 };
 
 static struct rsc *rsc_update(struct cache_detail *cd, struct rsc *new, struct rsc *old);
@@ -343,12 +353,22 @@ static void rsc_free(struct rsc *rsci)
 	free_svc_cred(&rsci->cred);
 }
 
+static void rsc_free_rcu(struct rcu_head *head)
+{
+	struct rsc *rsci = container_of(head, struct rsc, rcu_head);
+
+	kfree(rsci->handle.data);
+	kfree(rsci);
+}
+
 static void rsc_put(struct kref *ref)
 {
 	struct rsc *rsci = container_of(ref, struct rsc, h.ref);
 
-	rsc_free(rsci);
-	kfree(rsci);
+	if (rsci->mechctx)
+		gss_delete_sec_context(&rsci->mechctx);
+	free_svc_cred(&rsci->cred);
+	call_rcu(&rsci->rcu_head, rsc_free_rcu);
 }
 
 static inline int
@@ -542,7 +562,7 @@ static struct rsc *rsc_lookup(struct cache_detail *cd, struct rsc *item)
 	struct cache_head *ch;
 	int hash = rsc_hash(item);
 
-	ch = sunrpc_cache_lookup(cd, &item->h, hash);
+	ch = sunrpc_cache_lookup_rcu(cd, &item->h, hash);
 	if (ch)
 		return container_of(ch, struct rsc, h);
 	else
-- 
2.17.1
