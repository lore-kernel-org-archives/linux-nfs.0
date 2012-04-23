Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753753Ab2DWUhC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 16:37:02 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4: Ensure we do not reuse open owner names
Date: Mon, 23 Apr 2012 16:36:52 -0400
Message-Id: <1335213414-20826-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFSv4 spec is ambiguous about whether or not it is permissible
to reuse open owner names, so play it safe. This patch adds a timestamp
to the state_owner structure, and combines that with the IDA based
uniquifier.
Fixes a regression whereby the Linux server returns NFS4ERR_BAD_SEQID.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h        |    1 +
 fs/nfs/nfs4proc.c       |    6 +++---
 fs/nfs/nfs4state.c      |    1 +
 fs/nfs/nfs4xdr.c        |    9 +++++----
 include/linux/nfs_xdr.h |    7 ++++++-
 5 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 97ecc86..b6db9e3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -59,6 +59,7 @@ struct nfs_unique_id {
 
 #define NFS_SEQID_CONFIRMED 1
 struct nfs_seqid_counter {
+	ktime_t create_time;
 	int owner_id;
 	int flags;
 	u32 counter;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f875cf3..60d5f4c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -838,7 +838,8 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
-	p->o_arg.id = sp->so_seqid.owner_id;
+	p->o_arg.id.create_time = ktime_to_ns(sp->so_seqid.create_time);
+	p->o_arg.id.uniquifier = sp->so_seqid.owner_id;
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
@@ -1466,8 +1467,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 			goto unlock_no_action;
 		rcu_read_unlock();
 	}
-	/* Update sequence id. */
-	data->o_arg.id = sp->so_seqid.owner_id;
+	/* Update client id. */
 	data->o_arg.clientid = sp->so_server->nfs_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 0f43414..3b07f09 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -393,6 +393,7 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
 static void
 nfs4_init_seqid_counter(struct nfs_seqid_counter *sc)
 {
+	sc->create_time = ktime_get();
 	sc->flags = 0;
 	sc->counter = 0;
 	spin_lock_init(&sc->lock);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c74fdb1..77fc5f9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -74,7 +74,7 @@ static int nfs4_stat_to_errno(int);
 /* lock,open owner id:
  * we currently use size 2 (u64) out of (NFS4_OPAQUE_LIMIT  >> 2)
  */
-#define open_owner_id_maxsz	(1 + 1 + 4)
+#define open_owner_id_maxsz	(1 + 2 + 1 + 1 + 2)
 #define lock_owner_id_maxsz	(1 + 1 + 4)
 #define decode_lockowner_maxsz	(1 + XDR_QUADLEN(IDMAP_NAMESZ))
 #define compound_encode_hdr_maxsz	(3 + (NFS4_MAXTAGLEN >> 2))
@@ -1340,12 +1340,13 @@ static inline void encode_openhdr(struct xdr_stream *xdr, const struct nfs_opena
  */
 	encode_nfs4_seqid(xdr, arg->seqid);
 	encode_share_access(xdr, arg->fmode);
-	p = reserve_space(xdr, 32);
+	p = reserve_space(xdr, 36);
 	p = xdr_encode_hyper(p, arg->clientid);
-	*p++ = cpu_to_be32(20);
+	*p++ = cpu_to_be32(24);
 	p = xdr_encode_opaque_fixed(p, "open id:", 8);
 	*p++ = cpu_to_be32(arg->server->s_dev);
-	xdr_encode_hyper(p, arg->id);
+	*p++ = cpu_to_be32(arg->id.uniquifier);
+	xdr_encode_hyper(p, arg->id.create_time);
 }
 
 static inline void encode_createmode(struct xdr_stream *xdr, const struct nfs_openargs *arg)
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bfd0d1b..7ba3551 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -312,6 +312,11 @@ struct nfs4_layoutreturn {
 	int rpc_status;
 };
 
+struct stateowner_id {
+	__u64	create_time;
+	__u32	uniquifier;
+};
+
 /*
  * Arguments to the open call.
  */
@@ -321,7 +326,7 @@ struct nfs_openargs {
 	int			open_flags;
 	fmode_t			fmode;
 	__u64                   clientid;
-	__u64                   id;
+	struct stateowner_id	id;
 	union {
 		struct {
 			struct iattr *  attrs;    /* UNCHECKED, GUARDED */
-- 
1.7.7.6

