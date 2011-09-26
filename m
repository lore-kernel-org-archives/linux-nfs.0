Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48604 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526Ab1IZWjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:39:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 3/4] nfsd4: assume test_stateid always has session
Date: Mon, 26 Sep 2011 18:39:39 -0400
Message-Id: <1317076780-22309-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20110926223722.GB22140@fieldses.org>
References: <20110926223722.GB22140@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Test_stateid is 4.1-only and only allowed after a sequence operation, so
this check is unnecessary.

Cc: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 +++---
 fs/nfsd/nfs4xdr.c   |    2 +-
 fs/nfsd/state.h     |    2 +-
 fs/nfsd/xdr4.h      |    1 -
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a9e71cd..daf75fa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3256,7 +3256,7 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_sess
 	return nfserr_old_stateid;
 }
 
-__be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
+__be32 nfs4_validate_stateid(stateid_t *stateid)
 {
 	struct nfs4_stid *s;
 	struct nfs4_ol_stateid *ols;
@@ -3268,7 +3268,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 	s = find_stateid(stateid);
 	if (!s)
 		 return nfserr_stale_stateid;
-	status = check_stateid_generation(stateid, &s->sc_stateid, has_session);
+	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
 	if (status)
 		return status;
 	if (!(s->sc_type & (NFS4_OPEN_STID | NFS4_LOCK_STID)))
@@ -3374,7 +3374,7 @@ __be32
 nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   struct nfsd4_test_stateid *test_stateid)
 {
-	test_stateid->ts_has_session = nfsd4_has_session(cstate);
+	/* real work is done during encoding */
 	return nfs_ok;
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7bd57c2..2429fff 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3302,7 +3302,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
 	nfs4_lock_state();
 	for (i = 0; i < test_stateid->ts_num_ids; i++) {
 		nfsd4_decode_stateid(argp, &si);
-		valid = nfs4_validate_stateid(&si, test_stateid->ts_has_session);
+		valid = nfs4_validate_stateid(&si);
 		RESERVE_SPACE(4);
 		*p++ = htonl(valid);
 		resp->p = p;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 3ed5f99..55a4d6a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -508,7 +508,7 @@ extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
-extern __be32 nfs4_validate_stateid(stateid_t *, bool);
+extern __be32 nfs4_validate_stateid(stateid_t *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
 #endif   /* NFSD4_STATE_H */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index a767b57..c901214 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -343,7 +343,6 @@ struct nfsd4_saved_compoundargs {
 
 struct nfsd4_test_stateid {
 	__be32		ts_num_ids;
-	bool		ts_has_session;
 	struct nfsd4_compoundargs *ts_saved_args;
 	struct nfsd4_saved_compoundargs ts_savedp;
 };
-- 
1.7.4.1

