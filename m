Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37828 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758342Ab0ELWeC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 May 2010 18:34:02 -0400
Date: Wed, 12 May 2010 18:34:01 -0400
From: "J. Bruce Fields" <bfields@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 8/9] nfsd4: keep a reference count on client while
	in use
Message-ID: <20100512223401.GF11389@fieldses.org>
References: <4BE9C7A2.8030801@panasas.com> <1273612434-13726-1-git-send-email-bhalevy@panasas.com> <20100512024030.GA27184@fieldses.org> <4BEA2E06.7070902@panasas.com> <4BEA4876.3030802@panasas.com> <20100512222946.GE11389@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100512222946.GE11389@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 12, 2010 at 06:29:46PM -0400, J. Bruce Fields wrote:
> The following works for me. If you don't see any objection, I'll squash
> this in and push out the result.

And then this will also go on top.

(With the nfsd4_reclaim_complete() code being the one part mildly
relevant to your patch series.)

--b.

commit 3746094a09914b8e380bf6273f7ceb478de79157
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Mon Apr 19 15:11:28 2010 -0400

    nfsd4: implement reclaim_complete
    
    This is a mandatory operation.  Also, here (not in open) is where we
    should be committing the reboot recovery information.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

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
index e2dc960..59ec449 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1312,6 +1312,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
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
index e563597..89b77fe 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1503,6 +1503,35 @@ out:
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
+	if (is_client_expired(cstate->session->se_client)) {
+		nfs4_unlock_state();
+		/*
+		 * The following error isn't really legal.
+		 * But we only get here if the client just explicitly
+		 * destroyed the client.  Surely it no longer cares what
+		 * error it gets back on an operation for the dead
+		 * client.
+		 */
+		return nfserr_stale_clientid;
+	}
+	nfsd4_create_clid_dir(cstate->session->se_client);
+	nfs4_unlock_state();
+	return nfs_ok;
+}
+
+__be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
@@ -2511,10 +2540,8 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
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
index 126d0ca..ac17a70 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1234,6 +1234,16 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
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
@@ -1346,7 +1356,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
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
