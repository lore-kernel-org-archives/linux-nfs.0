Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57231 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754186Ab2KHAo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:44:26 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] nfsd4: implement backchannel_ctl operation
Date: Wed,  7 Nov 2012 19:44:21 -0500
Message-Id: <1352335463-29084-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1352335463-29084-1-git-send-email-bfields@redhat.com>
References: <1352335463-29084-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This operation is mandatory for servers to implement.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 Documentation/filesystems/nfs/nfs41-server.txt |    7 +------
 fs/nfsd/nfs4proc.c                             |    6 ++++++
 fs/nfsd/nfs4state.c                            |   14 ++++++++++++++
 fs/nfsd/nfs4xdr.c                              |   13 ++++++++++++-
 fs/nfsd/state.h                                |    5 +++++
 fs/nfsd/xdr4.h                                 |    2 ++
 6 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfs41-server.txt b/Documentation/filesystems/nfs/nfs41-server.txt
index 092fad9..f5ddff2 100644
--- a/Documentation/filesystems/nfs/nfs41-server.txt
+++ b/Documentation/filesystems/nfs/nfs41-server.txt
@@ -39,11 +39,6 @@ interoperability problems with future clients.  Known issues:
 	  from a linux client are possible, but we aren't really
 	  conformant with the spec (for example, we don't use kerberos
 	  on the backchannel correctly).
-	- Incomplete backchannel support: incomplete backchannel gss
-	  support and no support for BACKCHANNEL_CTL mean that
-	  callbacks (hence delegations and layouts) may not be
-	  available and clients confused by the incomplete
-	  implementation may fail.
 	- We do not support SSV, which provides security for shared
 	  client-server state (thus preventing unauthorized tampering
 	  with locks and opens, for example).  It is mandatory for
@@ -89,7 +84,7 @@ Operations
    |                      | MNI        | or OPT)      |                |
    +----------------------+------------+--------------+----------------+
    | ACCESS               | REQ        |              | Section 18.1   |
-NS | BACKCHANNEL_CTL      | REQ        |              | Section 18.33  |
+I  | BACKCHANNEL_CTL      | REQ        |              | Section 18.33  |
 I  | BIND_CONN_TO_SESSION | REQ        |              | Section 18.34  |
    | CLOSE                | REQ        |              | Section 18.2   |
    | COMMIT               | REQ        |              | Section 18.3   |
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6c9a4b2..f955176 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1666,6 +1666,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_name = "OP_EXCHANGE_ID",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_exchange_id_rsize,
 	},
+	[OP_BACKCHANNEL_CTL] = {
+		.op_func = (nfsd4op_func)nfsd4_backchannel_ctl,
+		.op_flags = ALLOWED_WITHOUT_FH | OP_MODIFIES_SOMETHING,
+		.op_name = "OP_BACKCHANNEL_CTL",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+	},
 	[OP_BIND_CONN_TO_SESSION] = {
 		.op_func = (nfsd4op_func)nfsd4_bind_conn_to_session,
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dbbbd2f..4023e77 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1865,6 +1865,20 @@ static __be32 nfsd4_map_bcts_dir(u32 *dir)
 	return nfserr_inval;
 }
 
+__be32 nfsd4_backchannel_ctl(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_backchannel_ctl *bc)
+{
+	struct nfsd4_session *session = cstate->session;
+
+	spin_lock(&client_lock);
+	session->se_cb_prog = bc->bc_cb_program;
+	session->se_cb_sec = bc->bc_cb_sec;
+	spin_unlock(&client_lock);
+
+	nfsd4_probe_callback(session->se_client);
+
+	return nfs_ok;
+}
+
 __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
 		     struct nfsd4_compound_state *cstate,
 		     struct nfsd4_bind_conn_to_session *bcts)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 511f980..d7e7c11 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -483,6 +483,17 @@ static __be32 nfsd4_decode_cb_sec(struct nfsd4_compoundargs *argp, struct nfsd4_
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_backchannel_ctl(struct nfsd4_compoundargs *argp, struct nfsd4_backchannel_ctl *bc)
+{
+	DECODE_HEAD;
+
+	READ_BUF(4);
+	READ32(bc->bc_cb_program);
+	nfsd4_decode_cb_sec(argp, &bc->bc_cb_sec);
+
+	DECODE_TAIL;
+}
+
 static __be32 nfsd4_decode_bind_conn_to_session(struct nfsd4_compoundargs *argp, struct nfsd4_bind_conn_to_session *bcts)
 {
 	DECODE_HEAD;
@@ -1536,7 +1547,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
 	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_notsupp,
 
 	/* new operations for NFSv4.1 */
-	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_backchannel_ctl,
 	[OP_BIND_CONN_TO_SESSION]= (nfsd4_dec)nfsd4_decode_bind_conn_to_session,
 	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
 	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index bff856c..758bc9c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -166,6 +166,11 @@ struct nfsd4_create_session {
 	struct nfsd4_cb_sec		cb_sec;
 };
 
+struct nfsd4_backchannel_ctl {
+	u32	bc_cb_program;
+	struct nfsd4_cb_sec		bc_cb_sec;
+};
+
 struct nfsd4_bind_conn_to_session {
 	struct nfs4_sessionid		sessionid;
 	u32				dir;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index acd127d..71c5c47 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -462,6 +462,7 @@ struct nfsd4_op {
 
 		/* NFSv4.1 */
 		struct nfsd4_exchange_id	exchange_id;
+		struct nfsd4_backchannel_ctl	backchannel_ctl;
 		struct nfsd4_bind_conn_to_session bind_conn_to_session;
 		struct nfsd4_create_session	create_session;
 		struct nfsd4_destroy_session	destroy_session;
@@ -566,6 +567,7 @@ extern __be32 nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		struct nfsd4_sequence *seq);
 extern __be32 nfsd4_exchange_id(struct svc_rqst *rqstp,
 		struct nfsd4_compound_state *, struct nfsd4_exchange_id *);
+extern __be32 nfsd4_backchannel_ctl(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_backchannel_ctl *);
 extern __be32 nfsd4_bind_conn_to_session(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_bind_conn_to_session *);
 extern __be32 nfsd4_create_session(struct svc_rqst *,
 		struct nfsd4_compound_state *,
-- 
1.7.9.5

