From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 4/5] NFSv4: Add support for the RELEASE_LOCKOWNER operation
Date: Wed, 30 Jun 2010 17:25:36 -0400
Message-ID: <1277933137-6955-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1277933137-6955-1-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-2-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-3-git-send-email-Trond.Myklebust@netapp.com>
 <1277933137-6955-4-git-send-email-Trond.Myklebust@netapp.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757299Ab0F3VZ4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 17:25:56 -0400
In-Reply-To: <1277933137-6955-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is needed by NFSv4.0 servers in order to keep the number of locking
stateids at a manageable level.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4proc.c       |   28 ++++++++++++++++++++++++
 fs/nfs/nfs4state.c      |    2 +
 fs/nfs/nfs4xdr.c        |   55 +++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs4.h    |    1 +
 include/linux/nfs_xdr.h |    4 +++
 6 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index cee8714..deaf37f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -236,6 +236,7 @@ extern int nfs4_open_revalidate(struct inode *, struct dentry *, int, struct nam
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
 
 #if defined(CONFIG_NFS_V4_1)
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index de9ff15..5d3e8a2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4414,6 +4414,34 @@ out:
 	return err;
 }
 
+static void nfs4_release_lockowner_release(void *calldata)
+{
+	kfree(calldata);
+}
+
+const struct rpc_call_ops nfs4_release_lockowner_ops = {
+	.rpc_release = nfs4_release_lockowner_release,
+};
+
+void nfs4_release_lockowner(const struct nfs4_lock_state *lsp)
+{
+	struct nfs_server *server = lsp->ls_state->owner->so_server;
+	struct nfs_release_lockowner_args *args;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RELEASE_LOCKOWNER],
+	};
+
+	if (server->nfs_client->cl_mvops->minor_version != 0)
+		return;
+	args = kmalloc(sizeof(*args), GFP_NOFS);
+	if (!args)
+		return;
+	args->lock_owner.clientid = server->nfs_client->cl_clientid;
+	args->lock_owner.id = lsp->ls_id.id;
+	msg.rpc_argp = args;
+	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, args);
+}
+
 #define XATTR_NAME_NFSV4_ACL "system.nfs4_acl"
 
 int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 13e17e3..13a4f27 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -701,6 +701,8 @@ void nfs4_put_lock_state(struct nfs4_lock_state *lsp)
 	if (list_empty(&state->lock_states))
 		clear_bit(LK_STATE_IN_USE, &state->flags);
 	spin_unlock(&state->state_lock);
+	if (lsp->ls_flags & NFS_LOCK_INITIALIZED)
+		nfs4_release_lockowner(lsp);
 	nfs4_free_lock_state(lsp);
 }
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 49df05a..b3e9180 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -220,6 +220,11 @@ static int nfs4_stat_to_errno(int);
 				 4)
 #define decode_locku_maxsz	(op_decode_hdr_maxsz + \
 				 decode_stateid_maxsz)
+#define encode_release_lockowner_maxsz \
+				(op_encode_hdr_maxsz + \
+				 encode_lockowner_maxsz)
+#define decode_release_lockowner_maxsz \
+				(op_decode_hdr_maxsz)
 #define encode_access_maxsz	(op_encode_hdr_maxsz + 1)
 #define decode_access_maxsz	(op_decode_hdr_maxsz + 2)
 #define encode_symlink_maxsz	(op_encode_hdr_maxsz + \
@@ -474,6 +479,12 @@ static int nfs4_stat_to_errno(int);
 				decode_sequence_maxsz + \
 				decode_putfh_maxsz + \
 				decode_locku_maxsz)
+#define NFS4_enc_release_lockowner_sz \
+				(compound_encode_hdr_maxsz + \
+				 encode_lockowner_maxsz)
+#define NFS4_dec_release_lockowner_sz \
+				(compound_decode_hdr_maxsz + \
+				 decode_lockowner_maxsz)
 #define NFS4_enc_access_sz	(compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
@@ -1116,6 +1127,17 @@ static void encode_locku(struct xdr_stream *xdr, const struct nfs_locku_args *ar
 	hdr->replen += decode_locku_maxsz;
 }
 
+static void encode_release_lockowner(struct xdr_stream *xdr, const struct nfs_lowner *lowner, struct compound_hdr *hdr)
+{
+	__be32 *p;
+
+	p = reserve_space(xdr, 4);
+	*p++ = cpu_to_be32(OP_RELEASE_LOCKOWNER);
+	encode_lockowner(xdr, lowner);
+	hdr->nops++;
+	hdr->replen += decode_release_lockowner_maxsz;
+}
+
 static void encode_lookup(struct xdr_stream *xdr, const struct qstr *name, struct compound_hdr *hdr)
 {
 	int len = name->len;
@@ -2056,6 +2078,20 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 	return 0;
 }
 
+static int nfs4_xdr_enc_release_lockowner(struct rpc_rqst *req, __be32 *p, struct nfs_release_lockowner_args *args)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr = {
+		.minorversion = 0,
+	};
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_compound_hdr(&xdr, req, &hdr);
+	encode_release_lockowner(&xdr, &args->lock_owner, &hdr);
+	encode_nops(&hdr);
+	return 0;
+}
+
 /*
  * Encode a READLINK request
  */
@@ -3981,6 +4017,11 @@ static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
 	return status;
 }
 
+static int decode_release_lockowner(struct xdr_stream *xdr)
+{
+	return decode_op_hdr(xdr, OP_RELEASE_LOCKOWNER);
+}
+
 static int decode_lookup(struct xdr_stream *xdr)
 {
 	return decode_op_hdr(xdr, OP_LOOKUP);
@@ -5267,6 +5308,19 @@ out:
 	return status;
 }
 
+static int nfs4_xdr_dec_release_lockowner(struct rpc_rqst *rqstp, __be32 *p, void *dummy)
+{
+	struct xdr_stream xdr;
+	struct compound_hdr hdr;
+	int status;
+
+	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
+	status = decode_compound_hdr(&xdr, &hdr);
+	if (!status)
+		status = decode_release_lockowner(&xdr);
+	return status;
+}
+
 /*
  * Decode READLINK response
  */
@@ -5874,6 +5928,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
   PROC(GETACL,		enc_getacl,	dec_getacl),
   PROC(SETACL,		enc_setacl,	dec_setacl),
   PROC(FS_LOCATIONS,	enc_fs_locations, dec_fs_locations),
+  PROC(RELEASE_LOCKOWNER, enc_release_lockowner, dec_release_lockowner),
 #if defined(CONFIG_NFS_V4_1)
   PROC(EXCHANGE_ID,	enc_exchange_id,	dec_exchange_id),
   PROC(CREATE_SESSION,	enc_create_session,	dec_create_session),
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9b8299a..07e40c6 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -523,6 +523,7 @@ enum {
 	NFSPROC4_CLNT_GETACL,
 	NFSPROC4_CLNT_SETACL,
 	NFSPROC4_CLNT_FS_LOCATIONS,
+	NFSPROC4_CLNT_RELEASE_LOCKOWNER,
 
 	/* nfs41 */
 	NFSPROC4_CLNT_EXCHANGE_ID,
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 87202c7..fc46192 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -315,6 +315,10 @@ struct nfs_lockt_res {
 	struct nfs4_sequence_res	seq_res;
 };
 
+struct nfs_release_lockowner_args {
+	struct nfs_lowner	lock_owner;
+};
+
 struct nfs4_delegreturnargs {
 	const struct nfs_fh *fhandle;
 	const nfs4_stateid *stateid;
-- 
1.7.0.1

