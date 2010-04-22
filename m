From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] nfsd4: implement reclaim_complete
Date: Thu, 22 Apr 2010 10:32:24 -0400
Message-ID: <1271946744-5877-2-git-send-email-bfields@citi.umich.edu>
References: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48713 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754964Ab0DVOcY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 10:32:24 -0400
In-Reply-To: <1271946744-5877-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a mandatory operation.  Also, here (not in open) is where we
should be committing the reboot recovery information.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 Documentation/filesystems/nfs/nfs41-server.txt |    2 +-
 fs/nfsd/nfs4proc.c                             |    5 +++++
 fs/nfsd/nfs4state.c                            |   22 +++++++++++++++++++---
 fs/nfsd/nfs4xdr.c                              |   12 +++++++++++-
 fs/nfsd/xdr4.h                                 |    6 ++++++
 5 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfs41-server.txt b/Documentation/filesystems/nfs/nfs41-server.txt
index 6a53a84..0488491 100644
--- a/Documentation/filesystems/nfs/nfs41-server.txt
+++ b/Documentation/filesystems/nfs/nfs41-server.txt
@@ -137,7 +137,7 @@ NS*| OPENATTR             | OPT        |              | Section 18.17  |
    | READ                 | REQ        |              | Section 18.22  |
    | READDIR              | REQ        |              | Section 18.23  |
    | READLINK             | OPT        |              | Section 18.24  |
-NS | RECLAIM_COMPLETE     | REQ        |              | Section 18.51  |
+   | RECLAIM_COMPLETE     | REQ        |              | Section 18.51  |
    | RELEASE_LOCKOWNER    | MNI        |              | N/A            |
    | REMOVE               | REQ        |              | Section 18.25  |
    | RENAME               | REQ        |              | Section 18.26  |
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index e147dbc..fd01b33 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1310,6 +1310,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
 	},
+	[OP_RECLAIM_COMPLETE] = {
+		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
+		.op_flags = ALLOWED_WITHOUT_FH,
+		.op_name = "OP_RECLAIM_COMPLETE",
+	},
 };
 
 static const char *nfsd4_op_name(unsigned opnum)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e444829..b9d9c04 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1482,6 +1482,24 @@ out:
 }
 
 __be32
+nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_reclaim_complete *rc)
+{
+	if (rc->rca_one_fs) {
+		if (!cstate->current_fh.fh_dentry)
+			return nfserr_nofilehandle;
+		/*
+		 * We don't take advantage of the rca_one_fs case.
+		 * That's OK, it's optional, we can safely ignore it.
+		 */
+		 return nfs_ok;
+	}
+	nfs4_lock_state();
+	nfsd4_create_clid_dir(cstate->session->se_client);
+	nfs4_unlock_state();
+	return nfs_ok;
+}
+
+__be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
@@ -2492,10 +2510,8 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	}
 	memcpy(&open->op_stateid, &stp->st_stateid, sizeof(stateid_t));
 
-	if (nfsd4_has_session(&resp->cstate)) {
+	if (nfsd4_has_session(&resp->cstate))
 		open->op_stateowner->so_confirmed = 1;
-		nfsd4_create_clid_dir(open->op_stateowner->so_client);
-	}
 
 	/*
 	* Attempt to hand out a delegation. No error return, because the
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fb27b1d..bc4b86d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1233,6 +1233,16 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, struct nfsd4_reclaim_complete *rc)
+{
+	DECODE_HEAD;
+
+	READ_BUF(4);
+	READ32(rc->rca_one_fs);
+
+	DECODE_TAIL;
+}
+
 static __be32
 nfsd4_decode_noop(struct nfsd4_compoundargs *argp, void *p)
 {
@@ -1345,7 +1355,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
 };
 
 struct nfsd4_minorversion_ops {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index c28958e..4d476ff 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -381,6 +381,10 @@ struct nfsd4_destroy_session {
 	struct nfs4_sessionid	sessionid;
 };
 
+struct nfsd4_reclaim_complete {
+	u32 rca_one_fs;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -421,6 +425,7 @@ struct nfsd4_op {
 		struct nfsd4_create_session	create_session;
 		struct nfsd4_destroy_session	destroy_session;
 		struct nfsd4_sequence		sequence;
+		struct nfsd4_reclaim_complete	reclaim_complete;
 	} u;
 	struct nfs4_replay *			replay;
 };
@@ -523,6 +528,7 @@ extern __be32 nfsd4_sequence(struct svc_rqst *,
 extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
 		struct nfsd4_destroy_session *);
+__be32 nfsd4_reclaim_complete(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_reclaim_complete *);
 extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
 		struct nfsd4_open *open);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
-- 
1.6.3.3

