Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:55764 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbaFZTOE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:04 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so3516830qcx.25
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:03 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 012/117] nfsd: Cleanup nfs4svc_encode_compoundres
Date: Thu, 26 Jun 2014 15:11:52 -0400
Message-Id: <1403810017-16062-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Move the slot return, put session etc into a helper in fs/nfsd/nfs4state.c
instead of open coding in nfs4svc_encode_compoundres.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 35 ++++++++++++++++++++++-------------
 fs/nfsd/nfs4xdr.c   | 15 +--------------
 fs/nfsd/state.h     |  1 -
 fs/nfsd/xdr4.h      |  2 +-
 4 files changed, 24 insertions(+), 29 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3ce5dc30f767..ade15fcddd08 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -203,18 +203,6 @@ static void put_client_renew_locked(struct nfs4_client *clp)
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
@@ -1650,7 +1638,7 @@ out_err:
 /*
  * Cache a reply. nfsd4_check_resp_size() has bounded the cache size.
  */
-void
+static void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 {
 	struct xdr_buf *buf = resp->xdr.buf;
@@ -2422,6 +2410,27 @@ out_put_client:
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
index 83baf2bfe9e9..68ea99d389ad 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3999,7 +3999,6 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	/*
 	 * All that remains is to write the tag and operation count...
 	 */
-	struct nfsd4_compound_state *cs = &resp->cstate;
 	struct xdr_buf *buf = resp->xdr.buf;
 
 	WARN_ON_ONCE(buf->len != buf->head[0].iov_len + buf->page_len +
@@ -4013,19 +4012,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	p += XDR_QUADLEN(resp->taglen);
 	*p++ = htonl(resp->opcnt);
 
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
index 7d6ba06c1abe..24eec922685c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -477,7 +477,6 @@ extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 							struct nfsd_net *nn);
 extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
-extern void put_client_renew(struct nfs4_client *clp);
 
 /* nfs4recover operations */
 extern int nfsd4_client_tracking_init(struct net *net);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 18cbb6d9c8a9..7d8af164523b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -574,7 +574,6 @@ extern __be32 nfsd4_setclientid(struct svc_rqst *rqstp,
 extern __be32 nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *,
 		struct nfsd4_setclientid_confirm *setclientid_confirm);
-extern void nfsd4_store_cache_entry(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_exchange_id *);
 extern __be32 nfsd4_backchannel_ctl(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_backchannel_ctl *);
@@ -585,6 +584,7 @@ extern __be32 nfsd4_create_session(struct svc_rqst *,
 extern __be32 nfsd4_sequence(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_sequence *);
+extern void nfsd4_sequence_done(struct nfsd4_compoundres *resp);
 extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
-- 
1.9.3

