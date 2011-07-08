Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4740 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755116Ab1GHU2p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2011 16:28:45 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 2/2] NFSD: Added TEST_STATEID operation
Date: Fri,  8 Jul 2011 16:28:40 -0400
Message-Id: <1310156920-10065-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1310156920-10065-1-git-send-email-bjschuma@netapp.com>
References: <1310156920-10065-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

This operation is used by the client to check the validity of a list of
stateids.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4proc.c  |    5 +++
 fs/nfsd/nfs4state.c |   38 +++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c   |   85 +++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/state.h     |    1 +
 fs/nfsd/xdr4.h      |   17 ++++++++++
 5 files changed, 143 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7e00116..a856f30 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1412,6 +1412,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = OP_HANDLES_WRONGSEC,
 		.op_name = "OP_SECINFO_NO_NAME",
 	},
+	[OP_TEST_STATEID] = {
+		.op_func = (nfsd4op_func)nfsd4_test_stateid,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_TEST_STATEID",
+	},
 	[OP_FREE_STATEID] = {
 		.op_func = (nfsd4op_func)nfsd4_free_stateid,
 		.op_flags = ALLOWED_WITHOUT_FH,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5819a10..2ec1c26 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -37,6 +37,7 @@
 #include <linux/slab.h>
 #include <linux/namei.h>
 #include <linux/swap.h>
+#include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/clnt.h>
 #include "xdr4.h"
@@ -3145,6 +3146,32 @@ static int is_open_stateid(struct nfs4_stateid *stateid)
 	return stateid->st_openstp == NULL;
 }
 
+__be32 nfs4_validate_stateid(stateid_t *stateid, int flags)
+{
+	struct nfs4_stateid *stp = NULL;
+	__be32 status = nfserr_stale_stateid;
+
+	if (STALE_STATEID(stateid))
+		goto out;
+
+	status = nfserr_expired;
+	stp = search_for_stateid(stateid);
+	if (!stp)
+		goto out;
+	status = nfserr_bad_stateid;
+
+	if (!stp->st_stateowner->so_confirmed)
+		goto out;
+
+	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
+	if (status)
+		goto out;
+
+	status = nfs_ok;
+out:
+	return status;
+}
+
 /*
 * Checks for stateid operations
 */
@@ -3243,6 +3270,17 @@ nfsd4_free_lock_stateid(struct nfs4_stateid *stp)
 }
 
 /*
+ * Test if the stateid is valid
+ */
+__be32
+nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		   struct nfsd4_test_stateid *test_stateid)
+{
+	test_stateid->ts_has_session = nfsd4_has_session(cstate);
+	return nfs_ok;
+}
+
+/*
  * Free a state id
  */
 __be32
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ef9bd6f..e84f3ba 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -44,13 +44,14 @@
 #include <linux/namei.h>
 #include <linux/statfs.h>
 #include <linux/utsname.h>
+#include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
 
 #include "idmap.h"
 #include "acl.h"
 #include "xdr4.h"
 #include "vfs.h"
-
+#include "state.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
@@ -131,6 +132,22 @@ xdr_error:					\
 	}					\
 } while (0)
 
+static void save_buf(struct nfsd4_compoundargs *argp, struct nfsd4_saved_compoundargs *savep)
+{
+	savep->p        = argp->p;
+	savep->end      = argp->end;
+	savep->pagelen  = argp->pagelen;
+	savep->pagelist = argp->pagelist;
+}
+
+static void restore_buf(struct nfsd4_compoundargs *argp, struct nfsd4_saved_compoundargs *savep)
+{
+	argp->p        = savep->p;
+	argp->end      = savep->end;
+	argp->pagelen  = savep->pagelen;
+	argp->pagelist = savep->pagelist;
+}
+
 static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 {
 	/* We want more bytes than seem to be available.
@@ -1274,6 +1291,40 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 	DECODE_TAIL;
 }
 
+static __be32
+nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_stateid *test_stateid)
+{
+	unsigned int nbytes;
+	stateid_t si;
+	int i;
+	__be32 *p;
+	__be32 status;
+
+	READ_BUF(4);
+	test_stateid->ts_num_ids = ntohl(*p++);
+
+	nbytes = test_stateid->ts_num_ids * sizeof(stateid_t);
+	if (nbytes > (u32)((char *)argp->end - (char *)argp->p))
+		goto xdr_error;
+
+	test_stateid->ts_saved_args = argp;
+	save_buf(argp, &test_stateid->ts_savedp);
+
+	for (i = 0; i < test_stateid->ts_num_ids; i++) {
+		status = nfsd4_decode_stateid(argp, &si);
+		if (status)
+			return status;
+	}
+
+	status = 0;
+out:
+	return status;
+xdr_error:
+	dprintk("NFSD: xdr error (%s:%d)\n", __FILE__, __LINE__);
+	status = nfserr_bad_xdr;
+	goto out;
+}
+
 static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, struct nfsd4_reclaim_complete *rc)
 {
 	DECODE_HEAD;
@@ -1393,7 +1444,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_secinfo_no_name,
 	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
 	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_test_stateid,
 	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
@@ -3166,6 +3217,34 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
 	return 0;
 }
 
+__be32
+nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
+			  struct nfsd4_test_stateid *test_stateid)
+{
+	struct nfsd4_compoundargs *argp;
+	stateid_t si;
+	__be32 *p;
+	int i;
+	int valid;
+
+	restore_buf(test_stateid->ts_saved_args, &test_stateid->ts_savedp);
+	argp = test_stateid->ts_saved_args;
+
+	RESERVE_SPACE(4);
+	*p++ = htonl(test_stateid->ts_num_ids);
+	resp->p = p;
+
+	for (i = 0; i < test_stateid->ts_num_ids; i++) {
+		nfsd4_decode_stateid(argp, &si);
+		valid = nfs4_validate_stateid(&si, test_stateid->ts_has_session);
+		RESERVE_SPACE(4);
+		*p++ = htonl(valid);
+		resp->p = p;
+	}
+
+	return nfserr;
+}
+
 static __be32
 nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
 {
@@ -3234,7 +3313,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo_no_name,
 	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
 	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
-	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_test_stateid,
 	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6bd2f3c..4eefaf1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -482,6 +482,7 @@ extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
+extern __be32 nfs4_validate_stateid(stateid_t *, int);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ed1784d..02fb0e0 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -342,6 +342,20 @@ struct nfsd4_setclientid_confirm {
 	nfs4_verifier	sc_confirm;
 };
 
+struct nfsd4_saved_compoundargs {
+	__be32 *p;
+	__be32 *end;
+	int pagelen;
+	struct page **pagelist;
+};
+
+struct nfsd4_test_stateid {
+	__be32		ts_num_ids;
+	__be32		ts_has_session;
+	struct nfsd4_compoundargs *ts_saved_args;
+	struct nfsd4_saved_compoundargs ts_savedp;
+};
+
 struct nfsd4_free_stateid {
 	stateid_t	fr_stateid;         /* request */
 	__be32		fr_status;          /* response */
@@ -437,6 +451,7 @@ struct nfsd4_op {
 		struct nfsd4_destroy_session	destroy_session;
 		struct nfsd4_sequence		sequence;
 		struct nfsd4_reclaim_complete	reclaim_complete;
+		struct nfsd4_test_stateid	test_stateid;
 		struct nfsd4_free_stateid	free_stateid;
 	} u;
 	struct nfs4_replay *			replay;
@@ -570,6 +585,8 @@ extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
 extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
 			  struct nfsd4_compound_state *, clientid_t *clid);
+extern __be32 nfsd4_test_stateid(struct svc_rqst *rqstp,
+		struct nfsd4_compound_state *, struct nfsd4_test_stateid *test_stateid);
 extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
 #endif
-- 
1.7.6

