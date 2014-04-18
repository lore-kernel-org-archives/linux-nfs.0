Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f174.google.com ([209.85.213.174]:65508 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbaDRSpj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:39 -0400
Received: by mail-ig0-f174.google.com with SMTP id h18so941677igc.7
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:39 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 22/70] NFSd: Cleanup nfs4svc_encode_compoundres
Date: Fri, 18 Apr 2014 14:44:16 -0400
Message-Id: <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the slot return, put session etc into a helper in fs/nfsd/nfs4state.c
instead of open coding in nfs4svc_encode_compoundres.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 35 ++++++++++++++++++++++-------------
 fs/nfsd/nfs4xdr.c   | 15 +--------------
 fs/nfsd/state.h     |  1 -
 fs/nfsd/xdr4.h      |  2 +-
 4 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 38ca008c3d41..9421e56454a2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -202,18 +202,6 @@ static void put_client_renew_locked(struct nfs4_client *clp)
 		renew_client_locked(clp);
 }
 
-void put_client_renew(struct nfs4_client *clp)
-{
-	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
-
-	if (!atomic_dec_and_lock(&clp->cl_refcount, &nn->client_lock))
-		return;
-	if (!is_client_expired(clp))
-		renew_client_locked(clp);
-	spin_unlock(&nn->client_lock);
-}
-
-
 static inline u32
 opaque_hashval(const void *ptr, int nbytes)
 {
@@ -1657,7 +1645,7 @@ out_err:
 /*
  * Cache a reply. nfsd4_check_resp_size() has bounded the cache size.
  */
-void
+static void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct nfsd4_slot *slot = resp->cstate.slot;
@@ -2414,6 +2402,27 @@ out_put_client:
 	goto out_no_session;
 }
 
+void
+nfsd4_sequence_done(struct nfsd4_compoundres *resp)
+{
+	struct nfsd4_compound_state *cs = &resp->cstate;
+
+	if (nfsd4_has_session(cs)) {
+		struct nfs4_client *clp = cs->session->se_client;
+		struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+		if (cs->status != nfserr_replay_cache) {
+			nfsd4_store_cache_entry(resp);
+			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
+		}
+		/* Renew the clientid on success and on replay */
+		spin_lock(&nn->client_lock);
+		nfsd4_put_session(cs->session);
+		put_client_renew_locked(clp);
+		spin_unlock(&nn->client_lock);
+	}
+}
+
 __be32
 nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2723c1badd01..8f6e7a4dc8b0 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3727,7 +3727,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	/*
 	 * All that remains is to write the tag and operation count...
 	 */
-	struct nfsd4_compound_state *cs = &resp->cstate;
 	struct kvec *iov;
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
@@ -3741,19 +3740,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-	if (nfsd4_has_session(cs)) {
-		struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
-		struct nfs4_client *clp = cs->session->se_client;
-		if (cs->status != nfserr_replay_cache) {
-			nfsd4_store_cache_entry(resp);
-			cs->slot->sl_flags &= ~NFSD4_SLOT_INUSE;
-		}
-		/* Renew the clientid on success and on replay */
-		spin_lock(&nn->client_lock);
-		nfsd4_put_session(cs->session);
-		spin_unlock(&nn->client_lock);
-		put_client_renew(clp);
-	}
+	nfsd4_sequence_done(resp);
 	return 1;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 02fc6685ab3f..e5444e0aedad 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -452,7 +452,6 @@ extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
-extern void put_client_renew(struct nfs4_client *clp);
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2f887c944048..a617f1a3ba83 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -592,7 +592,6 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
-extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_exchange_id *);
 extern __be32 nfsd4_backchannel_ctl(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_backchannel_ctl *);
@@ -603,6 +602,7 @@ extern __be32 nfsd4_create_session(struct svc_rqst *,
 extern __be32 nfsd4_sequence(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_sequence *);
+extern void nfsd4_sequence_done(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
-- 
1.9.0

