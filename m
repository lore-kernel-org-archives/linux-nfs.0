Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21661 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628Ab2A0PXH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jan 2012 10:23:07 -0500
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v2] NFSD: Clean up the test_stateid function
Date: Fri, 27 Jan 2012 10:22:49 -0500
Message-Id: <1327677769-7554-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

When I initially wrote it, I didn't understand how lists worked so I
wrote something that didn't use them.  I think making a list of stateids
to test is a more straightforward implementation, especially compared to
especially compared to decoding stateids while simultaneously encoding
a reply to the client.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
v2: Use defer_free() to free kmalloc()ed memory.

 fs/nfsd/nfs4state.c |    9 ++++++-
 fs/nfsd/nfs4xdr.c   |   66 +++++++++++++++-----------------------------------
 fs/nfsd/xdr4.h      |    9 +++++-
 3 files changed, 35 insertions(+), 49 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e8c98f0..c59a3f6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3400,7 +3400,14 @@ __be32
 nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   struct nfsd4_test_stateid *test_stateid)
 {
-	/* real work is done during encoding */
+	struct nfsd4_test_stateid_id *stateid;
+	struct nfs4_client *cl = cstate->session->se_client;
+
+	nfs4_lock_state();
+	list_for_each_entry(stateid, &test_stateid->ts_stateid_list, ts_id_list)
+		stateid->ts_id_status = nfs4_validate_stateid(cl, &stateid->ts_id_stateid);
+	nfs4_unlock_state();
+
 	return nfs_ok;
 }
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0ec5a1b..5785a98 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -133,22 +133,6 @@ xdr_error:					\
 	}					\
 } while (0)
 
-static void save_buf(struct nfsd4_compoundargs *argp, struct nfsd4_saved_compoundargs *savep)
-{
-	savep->p        = argp->p;
-	savep->end      = argp->end;
-	savep->pagelen  = argp->pagelen;
-	savep->pagelist = argp->pagelist;
-}
-
-static void restore_buf(struct nfsd4_compoundargs *argp, struct nfsd4_saved_compoundargs *savep)
-{
-	argp->p        = savep->p;
-	argp->end      = savep->end;
-	argp->pagelen  = savep->pagelen;
-	argp->pagelist = savep->pagelist;
-}
-
 static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 {
 	/* We want more bytes than seem to be available.
@@ -1385,26 +1369,29 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 static __be32
 nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_stateid *test_stateid)
 {
-	unsigned int nbytes;
-	stateid_t si;
 	int i;
-	__be32 *p;
-	__be32 status;
+	__be32 *p, status;
+	struct nfsd4_test_stateid_id *stateid;
 
 	READ_BUF(4);
 	test_stateid->ts_num_ids = ntohl(*p++);
 
-	nbytes = test_stateid->ts_num_ids * sizeof(stateid_t);
-	if (nbytes > (u32)((char *)argp->end - (char *)argp->p))
-		goto xdr_error;
-
-	test_stateid->ts_saved_args = argp;
-	save_buf(argp, &test_stateid->ts_savedp);
+	INIT_LIST_HEAD(&test_stateid->ts_stateid_list);
 
 	for (i = 0; i < test_stateid->ts_num_ids; i++) {
-		status = nfsd4_decode_stateid(argp, &si);
+		stateid = kmalloc(sizeof(struct nfsd4_test_stateid_id), GFP_KERNEL);
+		if (!stateid) {
+			status = PTR_ERR(stateid);
+			goto out;
+		}
+
+		defer_free(argp, kfree, stateid);
+		INIT_LIST_HEAD(&stateid->ts_id_list);
+		list_add_tail(&stateid->ts_id_list, &test_stateid->ts_stateid_list);
+
+		status = nfsd4_decode_stateid(argp, &stateid->ts_id_stateid);
 		if (status)
-			return status;
+			goto out;
 	}
 
 	status = 0;
@@ -3391,30 +3378,17 @@ __be32
 nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
 			  struct nfsd4_test_stateid *test_stateid)
 {
-	struct nfsd4_compoundargs *argp;
-	struct nfs4_client *cl = resp->cstate.session->se_client;
-	stateid_t si;
+	struct nfsd4_test_stateid_id *stateid, *next;
 	__be32 *p;
-	int i;
-	int valid;
 
-	restore_buf(test_stateid->ts_saved_args, &test_stateid->ts_savedp);
-	argp = test_stateid->ts_saved_args;
-
-	RESERVE_SPACE(4);
+	RESERVE_SPACE(4 + (4 * test_stateid->ts_num_ids));
 	*p++ = htonl(test_stateid->ts_num_ids);
-	resp->p = p;
 
-	nfs4_lock_state();
-	for (i = 0; i < test_stateid->ts_num_ids; i++) {
-		nfsd4_decode_stateid(argp, &si);
-		valid = nfs4_validate_stateid(cl, &si);
-		RESERVE_SPACE(4);
-		*p++ = htonl(valid);
-		resp->p = p;
+	list_for_each_entry_safe(stateid, next, &test_stateid->ts_stateid_list, ts_id_list) {
+		*p++ = htonl(stateid->ts_id_status);
 	}
-	nfs4_unlock_state();
 
+	ADJUST_ARGS();
 	return nfserr;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 2364747..0a667e9 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -343,10 +343,15 @@ struct nfsd4_saved_compoundargs {
 	struct page **pagelist;
 };
 
+struct nfsd4_test_stateid_id {
+	__be32			ts_id_status;
+	stateid_t		ts_id_stateid;
+	struct list_head	ts_id_list;
+};
+
 struct nfsd4_test_stateid {
 	__be32		ts_num_ids;
-	struct nfsd4_compoundargs *ts_saved_args;
-	struct nfsd4_saved_compoundargs ts_savedp;
+	struct list_head ts_stateid_list;
 };
 
 struct nfsd4_free_stateid {
-- 
1.7.8.4

