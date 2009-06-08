From: andros@netapp.com
Subject: [PATCH 30/30] nfsd41: only reference the session on non-replay sequence
Date: Mon,  8 Jun 2009 14:21:11 -0400
Message-ID: <1244485271-7461-31-git-send-email-andros@netapp.com>
References: <>
 <1244485271-7461-1-git-send-email-andros@netapp.com>
 <1244485271-7461-2-git-send-email-andros@netapp.com>
 <1244485271-7461-3-git-send-email-andros@netapp.com>
 <1244485271-7461-4-git-send-email-andros@netapp.com>
 <1244485271-7461-5-git-send-email-andros@netapp.com>
 <1244485271-7461-6-git-send-email-andros@netapp.com>
 <1244485271-7461-7-git-send-email-andros@netapp.com>
 <1244485271-7461-8-git-send-email-andros@netapp.com>
 <1244485271-7461-9-git-send-email-andros@netapp.com>
 <1244485271-7461-10-git-send-email-andros@netapp.com>
 <1244485271-7461-11-git-send-email-andros@netapp.com>
 <1244485271-7461-12-git-send-email-andros@netapp.com>
 <1244485271-7461-13-git-send-email-andros@netapp.com>
 <1244485271-7461-14-git-send-email-andros@netapp.com>
 <1244485271-7461-15-git-send-email-andros@netapp.com>
 <1244485271-7461-16-git-send-email-andros@netapp.com>
 <1244485271-7461-17-git-send-email-andros@netapp.com>
 <1244485271-7461-18-git-send-email-andros@netapp.com>
 <1244485271-7461-19-git-send-email-andros@netapp.com>
 <1244485271-7461-20-git-send-email-andros@netapp.com>
 <1244485271-7461-21-git-send-email-andros@netapp.com>
 <1244485271-7461-22-git-send-email-andros@netapp.com>
 <1244485271-7461-23-git-send-email-andros@netapp.com>
 <1244485271-7461-24-git-send-email-andros@netapp.com>
 <1244485271-7461-25-git-send-email-andros@netapp.com>
 <1244485271-7461-26-git-send-email-andros@netapp.com>
 <1244485271-7461-27-git-send-email-andros@netapp.com>
 <1244485271-7461-28-git-send-email-andros@netapp.com>
 <1244485271-7461-29-git-send-email-andros@netapp.com>
 <1244485271-7461-30-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38770 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbZFHSVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:21:43 -0400
In-Reply-To: <1244485271-7461-30-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Solo CREATE_SESSION replays used to share the logic in nfsdsvc_enc_compound_res
and use nfsd4_store_cache_entry, but not set the cstate session nor take a
reference on the session. CREATE_SESSION now uses it's own cache structure
and logic inside nfsd4_create_session.

The SEQUENCE operation only needs to reference the session to call
nfsd4_store_cache_entry.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    9 ++++-----
 fs/nfsd/nfs4xdr.c   |   14 ++++++--------
 2 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 424b2da..0b12cf3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1436,13 +1436,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	cstate->slot = slot;
 	cstate->session = session;
 
+	/* Hold a session reference until done caching the response */
+	nfsd4_get_session(session);
+
 replay_cache:
-	/* Renew the clientid on success and on replay.
-	 * Hold a session reference until done processing the compound:
-	 * nfsd4_put_session called only if the cstate slot is set.
-	 */
+	/* Renew the clientid on success and on replay */
 	renew_client(session->se_client);
-	nfsd4_get_session(session);
 out:
 	spin_unlock(&sessionid_lock);
 	dprintk("%s: return %d\n", __func__, ntohl(status));
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d09bb9d..7bff6a3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3320,6 +3320,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 	/*
 	 * All that remains is to write the tag and operation count...
 	 */
+	struct nfsd4_compound_state *cs = &resp->cstate;
 	struct kvec *iov;
 	p = resp->tagp;
 	*p++ = htonl(resp->taglen);
@@ -3333,14 +3334,11 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, __be32 *p, struct nfsd4_compo
 		iov = &rqstp->rq_res.head[0];
 	iov->iov_len = ((char*)resp->p) - (char*)iov->iov_base;
 	BUG_ON(iov->iov_len > PAGE_SIZE);
-	if (nfsd4_has_session(&resp->cstate)) {
-		if (resp->cstate.status != nfserr_replay_cache) {
-			nfsd4_store_cache_entry(resp);
-			dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
-			resp->cstate.slot->sl_inuse = 0;
-		}
-		if (resp->cstate.session)
-			nfsd4_put_session(resp->cstate.session);
+	if (nfsd4_has_session(cs) && cs->status != nfserr_replay_cache) {
+		nfsd4_store_cache_entry(resp);
+		dprintk("%s: SET SLOT STATE TO AVAILABLE\n", __func__);
+		cs->slot->sl_inuse = 0;
+		nfsd4_put_session(cs->session);
 	}
 	return 1;
 }
-- 
1.5.4.3

