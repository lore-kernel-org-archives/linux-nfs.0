Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:15018 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965585Ab3DPXKr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Apr 2013 19:10:47 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Record the OPEN create mode used in the nfs4_opendata structure
Date: Tue, 16 Apr 2013 19:10:45 -0400
Message-Id: <1366153845-40043-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're doing NFSv4.1 against a server that has persistent sessions,
then we should not need to call SETATTR in order to reset the file
attributes immediately after doing an exclusive create.

Note that since the create mode depends on the type of session that
has been negotiated with the server, we should not choose the
mode until after we've got a session slot.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c       | 16 ++++++++++++++--
 fs/nfs/nfs4xdr.c        | 37 ++++++++++++++++---------------------
 include/linux/nfs_xdr.h |  1 +
 3 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index af05df3..282d9fa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1525,6 +1525,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 	struct nfs4_state_owner *sp = data->owner;
+	struct nfs_client *clp = sp->so_server->nfs_client;
 
 	if (nfs_wait_on_sequence(data->o_arg.seqid, task) != 0)
 		goto out_wait;
@@ -1545,7 +1546,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		rcu_read_unlock();
 	}
 	/* Update client id. */
-	data->o_arg.clientid = sp->so_server->nfs_client->cl_clientid;
+	data->o_arg.clientid = clp->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
 		data->o_arg.open_bitmap = &nfs4_open_noattr_bitmap[0];
@@ -1557,6 +1558,16 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 				&data->o_res.seq_res,
 				task) != 0)
 		nfs_release_seqid(data->o_arg.seqid);
+
+	/* Set the create mode (note dependency on the session type) */
+	data->o_arg.createmode = NFS4_CREATE_UNCHECKED;
+	if (data->o_arg.open_flags & O_EXCL) {
+		data->o_arg.createmode = NFS4_CREATE_EXCLUSIVE;
+		if (nfs4_has_persistent_session(clp))
+			data->o_arg.createmode = NFS4_CREATE_GUARDED;
+		else if (clp->cl_mvops->minor_version > 0)
+			data->o_arg.createmode = NFS4_CREATE_EXCLUSIVE4_1;
+	}
 	return;
 unlock_no_action:
 	rcu_read_unlock();
@@ -2000,7 +2011,8 @@ static int _nfs4_do_open(struct inode *dir,
 	if (status != 0)
 		goto err_opendata_put;
 
-	if (opendata->o_arg.open_flags & O_EXCL) {
+	if ((opendata->o_arg.open_flags & O_EXCL) &&
+	    (opendata->o_arg.createmode != NFS4_CREATE_GUARDED)) {
 		nfs4_exclusive_attrset(opendata, sattr);
 
 		nfs_fattr_init(opendata->o_res.f_attr);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 0b74489..fef71cb 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1366,33 +1366,28 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
 {
+	struct iattr dummy;
 	__be32 *p;
-	struct nfs_client *clp;
 
 	p = reserve_space(xdr, 4);
-	switch(arg->open_flags & O_EXCL) {
-	case 0:
+	switch(arg->createmode) {
+	case NFS4_CREATE_UNCHECKED:
 		*p = cpu_to_be32(NFS4_CREATE_UNCHECKED);
 		encode_attrs(xdr, arg->u.attrs, arg->server);
 		break;
-	default:
-		clp = arg->server->nfs_client;
-		if (clp->cl_mvops->minor_version > 0) {
-			if (nfs4_has_persistent_session(clp)) {
-				*p = cpu_to_be32(NFS4_CREATE_GUARDED);
-				encode_attrs(xdr, arg->u.attrs, arg->server);
-			} else {
-				struct iattr dummy;
-
-				*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
-				encode_nfs4_verifier(xdr, &arg->u.verifier);
-				dummy.ia_valid = 0;
-				encode_attrs(xdr, &dummy, arg->server);
-			}
-		} else {
-			*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
-			encode_nfs4_verifier(xdr, &arg->u.verifier);
-		}
+	case NFS4_CREATE_GUARDED:
+		*p = cpu_to_be32(NFS4_CREATE_GUARDED);
+		encode_attrs(xdr, arg->u.attrs, arg->server);
+		break;
+	case NFS4_CREATE_EXCLUSIVE:
+		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE);
+		encode_nfs4_verifier(xdr, &arg->u.verifier);
+		break;
+	case NFS4_CREATE_EXCLUSIVE4_1:
+		*p = cpu_to_be32(NFS4_CREATE_EXCLUSIVE4_1);
+		encode_nfs4_verifier(xdr, &arg->u.verifier);
+		dummy.ia_valid = 0;
+		encode_attrs(xdr, &dummy, arg->server);
 	}
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 90a4aa1..bdc100f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -349,6 +349,7 @@ struct nfs_openargs {
 	const u32 *		bitmask;
 	const u32 *		open_bitmap;
 	__u32			claim;
+	enum createmode4	createmode;
 };
 
 struct nfs_openres {
-- 
1.8.1.4

