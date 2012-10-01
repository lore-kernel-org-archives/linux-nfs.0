Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab2JARqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 6/8] nfsd4: separate session allocation and initialization
Date: Mon,  1 Oct 2012 13:46:50 -0400
Message-Id: <1349113612-30374-7-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This will allow some further simplification.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   46 +++++++++++++++++++++++-----------------------
 1 file changed, 23 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 79f1fdb..1cd80d5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -946,21 +946,10 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
 	return new;
 }
 
-static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+static struct nfsd4_session *init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
-	struct nfsd4_session *new;
-	struct nfsd4_conn *conn;
 	int idx;
 
-	new = alloc_session(&cses->fore_channel);
-	if (!new)
-		return NULL;
-
-	conn = alloc_conn_from_crses(rqstp, cses);
-	if (!conn) {
-		__free_session(new);
-		return NULL;
-	}
 	new->se_client = clp;
 	gen_sessionid(new);
 
@@ -978,7 +967,6 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	spin_unlock(&clp->cl_lock);
 	spin_unlock(&client_lock);
 
-	nfsd4_init_conn(rqstp, conn, new);
 	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
 		/*
@@ -1766,6 +1754,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	struct sockaddr *sa = svc_addr(rqstp);
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_session *new;
+	struct nfsd4_conn *conn;
 	struct nfsd4_clid_slot *cs_slot = NULL;
 	bool confirm_me = false;
 	__be32 status = 0;
@@ -1774,6 +1763,13 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		return nfserr_inval;
 	if (check_forechannel_attrs(cr_ses->fore_channel))
 		return nfserr_toosmall;
+	new = alloc_session(&cr_ses->fore_channel);
+	if (!new)
+		return nfserr_jukebox;
+	status = nfserr_jukebox;
+	conn = alloc_conn_from_crses(rqstp, cr_ses);
+	if (!conn)
+		goto out_free_session;
 
 	nfs4_lock_state();
 	unconf = find_unconfirmed_client(&cr_ses->clientid, true);
@@ -1784,41 +1780,40 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status == nfserr_replay_cache) {
 			status = nfsd4_replay_create_session(cr_ses, cs_slot);
-			goto out;
+			goto out_free_conn;
 		} else if (cr_ses->seqid != cs_slot->sl_seqid + 1) {
 			status = nfserr_seq_misordered;
-			goto out;
+			goto out_free_conn;
 		}
 	} else if (unconf) {
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
 		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
-			goto out;
+			goto out_free_conn;
 		}
 		cs_slot = &unconf->cl_cs_slot;
 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
 		if (status) {
 			/* an unconfirmed replay returns misordered */
 			status = nfserr_seq_misordered;
-			goto out;
+			goto out_free_conn;
 		}
 		confirm_me = true;
 		conf = unconf;
 	} else {
 		status = nfserr_stale_clientid;
-		goto out;
+		goto out_free_conn;
 	}
+	status = nfs_ok;
 	/*
 	 * We do not support RDMA or persistent sessions
 	 */
 	cr_ses->flags &= ~SESSION4_PERSIST;
 	cr_ses->flags &= ~SESSION4_RDMA;
 
-	status = nfserr_jukebox;
-	new = alloc_init_session(rqstp, conf, cr_ses);
-	if (!new)
-		goto out;
-	status = nfs_ok;
+	init_session(rqstp, new, conf, cr_ses);
+	nfsd4_init_conn(rqstp, conn, new);
+
 	memcpy(cr_ses->sessionid.data, new->se_sessionid.data,
 	       NFS4_MAX_SESSIONID_LEN);
 	memcpy(&cr_ses->fore_channel, &new->se_fchannel,
@@ -1840,6 +1835,11 @@ out:
 	nfs4_unlock_state();
 	dprintk("%s returns %d\n", __func__, ntohl(status));
 	return status;
+out_free_conn:
+	free_conn(conn);
+out_free_session:
+	__free_session(new);
+	goto out;
 }
 
 static bool nfsd4_last_compound_op(struct svc_rqst *rqstp)
-- 
1.7.9.5

