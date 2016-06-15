Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:53081 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752578AbcFOQ7D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 12:59:03 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH v3 2/3] nfsd: allow mach_creds_match to be used more broadly
Date: Wed, 15 Jun 2016 12:52:08 -0400
Message-Id: <1466009529-3421-3-git-send-email-aweits@rit.edu>
In-Reply-To: <1466009529-3421-1-git-send-email-aweits@rit.edu>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename mach_creds_match() to nfsd4_mach_creds_match() and un-staticify

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 14 +++++++-------
 fs/nfsd/xdr4.h      |  2 ++
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f5f82e145018..51db26811a14 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1972,7 +1972,7 @@ static bool svc_rqst_integrity_protected(struct svc_rqst *rqstp)
 	       service == RPC_GSS_SVC_PRIVACY;
 }
 
-static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
+bool nfsd4_mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
 {
 	struct svc_cred *cr = &rqstp->rq_cred;
 
@@ -2424,7 +2424,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 				status = nfserr_inval;
 				goto out;
 			}
-			if (!mach_creds_match(conf, rqstp)) {
+			if (!nfsd4_mach_creds_match(conf, rqstp)) {
 				status = nfserr_wrong_cred;
 				goto out;
 			}
@@ -2676,7 +2676,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 
 	if (conf) {
 		status = nfserr_wrong_cred;
-		if (!mach_creds_match(conf, rqstp))
+		if (!nfsd4_mach_creds_match(conf, rqstp))
 			goto out_free_conn;
 		cs_slot = &conf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
@@ -2692,7 +2692,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 			goto out_free_conn;
 		}
 		status = nfserr_wrong_cred;
-		if (!mach_creds_match(unconf, rqstp))
+		if (!nfsd4_mach_creds_match(unconf, rqstp))
 			goto out_free_conn;
 		cs_slot = &unconf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
@@ -2801,7 +2801,7 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 	if (!session)
 		goto out_no_session;
 	status = nfserr_wrong_cred;
-	if (!mach_creds_match(session->se_client, rqstp))
+	if (!nfsd4_mach_creds_match(session->se_client, rqstp))
 		goto out;
 	status = nfsd4_map_bcts_dir(&bcts->dir);
 	if (status)
@@ -2848,7 +2848,7 @@ nfsd4_destroy_session(struct svc_rqst *r,
 	if (!ses)
 		goto out_client_lock;
 	status = nfserr_wrong_cred;
-	if (!mach_creds_match(ses->se_client, r))
+	if (!nfsd4_mach_creds_match(ses->se_client, r))
 		goto out_put_session;
 	status = mark_session_dead_locked(ses, 1 + ref_held_by_me);
 	if (status)
@@ -3087,7 +3087,7 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		status = nfserr_stale_clientid;
 		goto out;
 	}
-	if (!mach_creds_match(clp, rqstp)) {
+	if (!nfsd4_mach_creds_match(clp, rqstp)) {
 		clp = NULL;
 		status = nfserr_wrong_cred;
 		goto out;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index d9554813e58a..74342a7c208a 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -654,6 +654,8 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 
 }
 
+
+bool nfsd4_mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp);
 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
 int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *,
 		struct nfsd4_compoundargs *);
-- 
2.6.3

